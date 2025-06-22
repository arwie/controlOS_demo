# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

import re
from pathlib import Path
import web
from shared import system
from .lan import network as lan_network


web.document.imports.add('system/network/wlan')



@web.handler
class wpa(web.RequestHandler):
	confFile = Path('/etc/wpa_supplicant.conf.d/local.conf')
	re_ssid = re.compile(r'ssid="(.*)"')
	
	def get(self):
		if self.confFile.is_file():
			match = self.re_ssid.search(self.confFile.read_text())
			self.write({'ssid': match.group(1) if match else ''})
		else:
			self.write(None)
	
	def post(self):
		if data := self.read_json():
			with open(self.confFile, 'wb') as f:
				system.run(['wpa_passphrase', data['ssid'].encode(), data['psk'].encode()], stdout=f)
		else:
			self.confFile.unlink(True)
		system.restart('wpa_supplicant.service')



@web.handler
class network(lan_network):
	confFile = Path('/etc/systemd/network/wlan.network.d/local.conf')
