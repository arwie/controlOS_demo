# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

from pathlib import Path
import web
from shared import system
from shared.conf import Conf


web.document.imports.add('system/network/lan')


@web.handler
class network(web.RequestHandler):
	confFile = Path('/etc/systemd/network/lan.network.d/local.conf')
	
	def get(self):
		self.write(Conf(self.confFile).dict())
	
	def post(self):
		Conf(self.confFile, self.read_json()).save()
		system.restart('systemd-networkd.service')

