# SPDX-FileCopyrightText: 2026 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

from __future__ import print_function
from deploy import project, deploy


for dev in project.get_children():
	if dev.is_device:
		for app in dev.get_children(True):
			if app.is_application:
				deploy(app, dir=dev.get_name())

print('All done!')
