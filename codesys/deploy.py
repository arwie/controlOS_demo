# SPDX-FileCopyrightText: 2026 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

# Compile CODESYS boot applications for all devices in the project for packaging.
# See docs/codesys_application_packaging.md

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

	for dev in project.get_children():
		if dev.is_device:
			for app in dev.get_children(True):
				if app.is_application:
					deploy(app, dir=dev.get_name())

	print('All done!')
