# Copyright (c) 2024 Artur Wiebe <artur@4wiebe.de>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
# associated documentation files (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


from __future__ import print_function
from scriptengine import projects	#type:ignore
from os import path
from itertools import chain
import re


project = projects.primary

export_path = path.join(path.dirname(project.path), 'codesys_types')
print('codesys_types path:', export_path)


export_types = ['AppCfg','AppCmd','AppFbk']

types = {
	'BOOL':		('c_bool',		'bool'),
	'SINT':		('c_int8',		'int'),
	'INT':		('c_int16',		'int'),
	'DINT':		('c_int32',		'int'),
	'LINT':		('c_int64',		'int'),
	'USINT':	('c_uint8',		'int'),
	'BYTE':		('c_uint8',		'int'),
	'UINT':		('c_uint16',	'int'),
	'WORD':		('c_uint16',	'int'),
	'UDINT':	('c_uint32',	'int'),
	'DWORD':	('c_uint32',	'int'),
	'ULINT':	('c_uint64',	'int'),
	'LWORD':	('c_uint64',	'int'),
	'REAL':		('c_float',		'float'),
	'LREAL':	('c_double',	'float'),
}


for struct_name in export_types:
	print('exporting:', struct_name)

	struct_text = project.find(struct_name)[0].textual_declaration.text

	imports = []
	fields  = []

	for match in re.findall(r'^\s*(\w+)\s*:\s*(.+)\s*;', struct_text, re.MULTILINE):
		field_name, field_type = match[0], match[1]

		field_array = None
		array_match = re.search(r'ARRAY \[(\d+)\.\.(\d+)\] OF (\w+)', field_type)
		if array_match:
			field_type = array_match.group(3)
			field_array = int(array_match.group(2)) - int(array_match.group(1)) + 1

		if field_type in types:
			field_ctype, field_ptype = types[field_type]
		else:
			field_ctype = field_ptype = field_type
			imports.append(field_type)
			if not field_type in export_types:
				export_types.append(field_type)

		if field_array:
			field_ctype = '{} * {}'.format(field_ctype, field_array)
			field_ptype = 'list[{}]'.format(field_ptype)

		fields.append((field_name, field_ctype, field_ptype))

	with open(path.join(export_path, struct_name+'.py'), 'w') as file:
		file.write('\n'.join(
			chain.from_iterable((part,) if isinstance(part, str) else part for part in (
				'from ctypes import *  #type:ignore',
				('from .{} import {}'.format(m, m) for m in imports),
				'class {}(Structure):'.format(struct_name),
					('\t{}: {}'.format(f[0], f[2]) for f in fields),
					'\t_fields_ = [',
						("\t\t('{}', {}),".format(f[0], f[1]) for f in fields),
					'\t]',
			))
		))


print('All done!')
