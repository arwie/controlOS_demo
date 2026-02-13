# SPDX-FileCopyrightText: 2026 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

# Export a CODESYS project as plain text files for version control.
#
# CODESYS projects are stored as opaque binary files that produce useless
# git diffs. This script walks the project tree and writes each object as
# a readable .txt or .xml file into a shadow directory (<project>.txt/).
# Commit this directory alongside the project file to get meaningful diffs,
# code reviews and change history.
#
# Works best with Structured Text (ST) because ST programs are fully textual.
# Graphical languages (FBD, LD, CFC) fall back to XML export which is less
# diff-friendly but still better than nothing.
#
# Run from the CODESYS Script Engine (Scripting > Run Script).

from __future__ import print_function
from scriptengine import projects	#type:ignore
from os import path, mkdir
from shutil import rmtree
import re

project = projects.primary

# Output directory sits next to the project file.
txt_path = project.path + '.txt'
print('txt path:', txt_path)
rmtree(txt_path, True)

# Strip XML boilerplate (<?xml?>, fileHeader, contentHeader) to reduce noise in diffs.
xml_filter = re.compile(r'.?<\?xml.*?\?>\r\n| *<fileHeader.*?/>\r\n| *<contentHeader.*?/contentHeader>\r\n', re.DOTALL)


def txtfy(obj, obj_path):
	obj_name = obj.get_name().strip('<>')
	obj_path = path.join(obj_path, obj_name)

	# Skip internal and placeholder objects.
	if obj_name.startswith('_') or obj_name.startswith('Empty'):
		return

	# Recurse into children, mirroring the project structure as directories.
	children = obj.get_children()
	if children:
		mkdir(obj_path)
		for child in children:
			txtfy(child, obj_path)

	print('txtfy: {} into {}'.format(obj_name, obj_path))

	if obj.is_folder:
		return

	# ST programs/functions: write declaration + implementation as plain text.
	if obj.has_textual_declaration:
		with open(obj_path+'.txt', 'w') as f:
			f.write(obj.textual_declaration.text)
			if obj.has_textual_implementation:
				f.writelines(['\n', '////////////////////////////////\n', '\n'])
				f.write(obj.textual_implementation.text)
		return

	# Project info: dump as key-value pairs.
	if obj.is_project_info:
		info = obj.values
		with open(obj_path+'.txt', 'w') as f:
			for k in info.Keys:
				f.write('{}: {}\n'.format(k, info[k]))
		return

	if obj.is_task_configuration:
		return

	# Everything else (visualizations, device config, ...): export as XML.
	obj_xml = xml_filter.sub('', obj.export_xml(recursive=False))
	with open(obj_path+'.xml', 'wb') as f:
		f.write(obj_xml.encode('utf8'))


mkdir(txt_path)
for obj in project.get_children():
	txtfy(obj, txt_path)

print('All done!')
