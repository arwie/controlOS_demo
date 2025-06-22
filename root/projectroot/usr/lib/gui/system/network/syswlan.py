# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

from pathlib import Path
import web
from shared import system
from shared.conf import Conf


web.document.imports.add('system/network/syswlan')


@web.handler
class hostapd(web.RequestHandler):
	confFile = Path('/etc/hostapd/local.conf')
	
	def get(self):
		self.write(Conf(self.confFile, section='x').dict('x') if self.confFile.is_file() else None)
	
	def post(self):
		if data := self.read_json():
			if not data['wpa_passphrase'].strip():
				del data['wpa_passphrase']
			Conf(self.confFile, data, section='x').save('x')
		else:
			self.confFile.unlink(True)
		system.restart('hostapd.service')
