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


GUID_TYPE_STRUCT = '2db5746d-d284-4425-9f7f-2663a34b0ebc'


project = projects.primary

deploy_path = path.join(path.dirname(project.path), 'PlcLogic')
print('PlcLogic path', deploy_path)


def deploy_application(name, app):
	print('Deploying:', name, app.get_name())

	app_path = path.join(deploy_path, name)

	rmtree(app_path, True)
	mkdir(app_path)

	app.create_boot_application(path.join(app_path, 'Application.app'))

	#fix Application.crc (codesys truncates it to 20 bytes at first load for whatever reason)
	with open(path.join(app_path, 'Application.crc'), 'r+b') as f:
		f.truncate(20)

	for struct in project.get_children():
		if str(struct.type) == GUID_TYPE_STRUCT:
			with open(path.join(app_path, struct.get_name()+'.struct'), 'w') as f:
				f.write(struct.textual_declaration.text)


def deploy(multi):
	for dev in project.get_children():
		if dev.is_device:
			for app in dev.get_children(True):
				if app.is_application:
					if multi:
						deploy_application(dev.get_name(), app)
					else:
						if app.is_active_application:
							deploy_application('Application', app)
	print('All done!')


if __name__ == '__main__':
	deploy(True)
