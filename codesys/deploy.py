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
from scriptengine import projects	#type:ignore
from os import path, mkdir


project = projects.primary


def deploy(app, plc_logic='PlcLogic', dir='Application', name='Application'):

	app_path = path.join(path.dirname(project.path), plc_logic, dir)
	print('Deploying: {} > {} to {}'.format(app.parent.parent.get_name(), app.get_name(), app_path))

	if not path.exists(app_path):
		mkdir(app_path)

	app.create_boot_application(path.join(app_path, name+'.app'))

	#fix Application.crc (codesys truncates it to 20 bytes at first load for whatever reason)
	with open(path.join(app_path, name+'.crc'), 'r+b') as f:
		f.truncate(20)


if __name__ == '__main__':
	deploy(project.active_application)
	print('All done!')
