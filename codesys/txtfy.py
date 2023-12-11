# Copyright (c) 2023 Artur Wiebe <artur@4wiebe.de>
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
from scriptengine import projects
from os import path, mkdir
from shutil import rmtree
import re


project = projects.primary

txt_path = project.path + '.txt'
print('txt path:', txt_path)
rmtree(txt_path, True)


xml_filter = re.compile(r'.?<\?xml.*?\?>\r\n| *<fileHeader.*?/>\r\n| *<contentHeader.*?/contentHeader>\r\n', re.DOTALL)


def txtfy(obj, obj_path):
	obj_name = obj.get_name()
	obj_path = path.join(obj_path, obj_name)

	if obj_name.startswith('_'):
		return

	children = obj.get_children()
	if children:
		mkdir(obj_path)
		for child in children:
			txtfy(child, obj_path)

	print('txtfy: {} into {}'.format(obj_name, obj_path))

	if obj.is_folder:
		return

	if obj.has_textual_declaration:
		with open(obj_path+'.txt', 'w') as f:
			f.write(obj.textual_declaration.text)
			if obj.has_textual_implementation:
				f.writelines(['\n', '////////////////////////////////\n', '\n'])
				f.write(obj.textual_implementation.text)
		return

	if obj.is_project_info:
		info = obj.values
		with open(obj_path+'.txt', 'w') as f:
			for k in info.Keys:
				f.write('{}: {}\n'.format(k, info[k]))
		return
	
	if obj.is_task_configuration:
		return

	obj_xml = xml_filter.sub('', obj.export_xml(recursive=False))
	with open(obj_path+'.xml', 'wb') as f:
		f.write(obj_xml.encode('utf8'))


mkdir(txt_path)
for obj in project.get_children():
	txtfy(obj, txt_path)

print('All done!')
