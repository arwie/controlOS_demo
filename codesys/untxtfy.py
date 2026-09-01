# SPDX-FileCopyrightText: 2026 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

# Import a plain text project tree back into a CODESYS project - the inverse of txtfy.py.
#
# Reads <project>.txt/ and creates the objects it finds in the primary project:
# POUs, DUTs, GVLs, folders, and the methods, properties and property accessors
# below them. The object name comes from the file name and the object kind from
# the declaration itself (FUNCTION_BLOCK, TYPE, METHOD, ...), which is exactly
# what txtfy.py wrote.
#
# An object that already exists keeps its identity and only gets its text
# replaced, so the script can be run again to pull changes from git into an open
# project. Objects that are in the project but not in the text tree are left
# alone - this imports, it does not synchronize.
#
# Only textual objects round trip. txtfy.py strips <?xml?>, fileHeader and
# contentHeader from its .xml exports, so devices, task configuration and
# visualizations cannot be read back and are skipped.
#
# Object properties that live outside the declaration text are not restored
# either, most notably the build property "External implementation" that the
# IOX2 Native functions need.
#
# Run from the CODESYS Script Engine (Scripting > Run Script).

from __future__ import print_function
from scriptengine import projects, PouType, ImplementationLanguages	#type:ignore
from os import path, listdir
from functools import partial
import re

project = projects.primary

# Text tree sits next to the project file.
txt_path = project.path + '.txt'
print('txt path:', txt_path)


def constant(obj, *names):
	# Script engine constants are spelled differently across CODESYS versions.
	for name in names:
		if hasattr(obj, name):
			return getattr(obj, name)
	print('none of {} in {}'.format(names, [n for n in dir(obj) if not n.startswith('_')]))


ST = constant(ImplementationLanguages, 'structured_text', 'st', 'structuredtext', 'ST')

pou_types = {
	'PROGRAM':			constant(PouType, 'Program', 'program'),
	'FUNCTION':			constant(PouType, 'Function', 'function'),
	'FUNCTION_BLOCK':	constant(PouType, 'FunctionBlock', 'functionblock', 'function_block'),
}

# txtfy.py joins declaration and implementation with this line.
separator = re.compile(r'\r?\n////////////////////////////////\r?\n')

# Header comments and pragmas stand in front of the keyword.
noise = re.compile(r'//[^\n]*|\(\*.*?\*\)|\{[^}]*\}', re.DOTALL)

modifiers = ('PUBLIC', 'PRIVATE', 'PROTECTED', 'INTERNAL', 'FINAL', 'ABSTRACT')


def parse(declaration):
	# Keyword and return type: 'METHOD PROTECTED Check: BOOL' -> ('METHOD', 'BOOL').
	words = noise.sub('', declaration).replace(':', ' : ').split()
	if not words:
		return '', None

	keyword = words.pop(0).upper()
	while words and words[0].upper() in modifiers:
		words.pop(0)
	if words:
		words.pop(0)	# object name, the file name is authoritative

	return keyword, words[1] if len(words) > 1 and words[0] == ':' else None


def get_name(obj):
	# The project itself is not a named object, it only has a path.
	return obj.get_name().strip('<>') if hasattr(obj, 'get_name') else path.basename(obj.path)


def find(container, name):
	for obj in container.get_children():
		if get_name(obj).lower() == name.lower():
			return obj


def created(container, name):
	# Not every create_* call returns the object it created, so look it up.
	obj = find(container, name)
	if obj is None:
		print('untxtfy: {} was not created in {}'.format(name, get_name(container)))
	return obj


def call(factory, *arguments):
	# Name and position of the optional create_* arguments differ across CODESYS
	# versions, so pass them by name and drop the ones a factory rejects. The
	# declaration text that follows is authoritative anyway.
	arguments = [a for a in arguments if a[1] is not None]

	while True:
		try:
			return factory(**dict(arguments))
		except Exception:
			if not arguments:
				raise
			print('untxtfy: dropped argument {}'.format(arguments[-1][0]))
			arguments.pop()


def create(container, name, keyword, return_type):
	# A FUNCTION is rejected without its return type, the others do not have one.
	if keyword in pou_types:
		call(partial(container.create_pou, name, pou_types[keyword]),
			('return_type', return_type), ('language', ST))

	# Structure, enumeration, union and alias are all DUTs, the text decides which.
	elif keyword == 'TYPE':
		container.create_dut(name)

	elif keyword == 'VAR_GLOBAL':
		container.create_gvl(name)

	elif keyword == 'METHOD':
		call(partial(container.create_method, name), ('return_type', return_type), ('language', ST))

	elif keyword == 'PROPERTY':
		call(partial(container.create_property, name), ('return_type', return_type), ('language', ST))

	else:
		return None

	return created(container, name)


def folder(container, name):
	if find(container, name) is None:
		container.create_folder(name)
	return created(container, name)


def write(container, name, file_path):
	with open(file_path) as f:
		parts = separator.split(f.read(), 1)

	declaration = parts[0]
	implementation = parts[1] if len(parts) > 1 else None
	if implementation and implementation.startswith('\n'):
		implementation = implementation[1:]	# blank line txtfy.py adds after the separator

	keyword, return_type = parse(declaration)

	obj = find(container, name) or create(container, name, keyword, return_type)
	if obj is None:
		print('untxtfy: {} is not a supported object, skipped'.format(file_path))
		return None

	print('untxtfy: {} {} into {}'.format(keyword, name, get_name(container)))

	obj.textual_declaration.replace(declaration)
	if implementation is not None and obj.has_textual_implementation:
		obj.textual_implementation.replace(implementation)

	return obj


def prune(obj, dir_path):
	# A new property comes with a Get and a Set accessor, the text tree decides which stay.
	names = [f[:-4].lower() for f in listdir(dir_path) if f.endswith('.txt')]
	if not ('get' in names or 'set' in names):
		return

	for accessor in list(obj.get_children()):
		name = get_name(accessor).lower()
		if name in ('get', 'set') and name not in names:
			print('untxtfy: removing {} of {}'.format(name, get_name(obj)))
			accessor.remove()


def untxtfy(container, dir_path):
	# Same objects txtfy.py skips, plus whatever git, editors and tools leave behind.
	entries = sorted(e for e in listdir(dir_path)
		if not (e.startswith('.') or e.startswith('_') or e.startswith('Empty')))

	# A directory that has no object file of the same name is a plain folder.
	objects = set(path.splitext(e)[0].lower() for e in entries if e.endswith('.txt') or e.endswith('.xml'))

	for entry in entries:
		entry_path = path.join(dir_path, entry)

		if entry.endswith('.xml'):
			print('untxtfy: {} cannot be imported back, skipped'.format(entry_path))

		elif entry.endswith('.txt'):
			obj = write(container, entry[:-4], entry_path)
			children = path.join(dir_path, entry[:-4])
			if obj is not None and path.isdir(children):
				untxtfy(obj, children)
				prune(obj, children)

		elif path.isdir(entry_path) and entry.lower() not in objects:
			print('untxtfy: folder {} into {}'.format(entry, get_name(container)))
			obj = folder(container, entry)
			if obj is not None:
				untxtfy(obj, entry_path)


untxtfy(project, txt_path)

print('All done! Check the objects and save the project.')
