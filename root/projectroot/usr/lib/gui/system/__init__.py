# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

import web
from shared import system



@web.handler
class poweroff(web.RequestHandler):
	def post(self):
		system.poweroff()
