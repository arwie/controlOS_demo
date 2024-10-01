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


import re
from pathlib import Path
import server
from shared import system
from shared.conf import Conf
from shared.utils import import_all_in_package



pages = list[str]()

def add_page(page:str):
	pages.append(page)

import_all_in_package(__file__, __name__)



class SyswlanHandler(server.RequestHandler):
	confFile = Path('/etc/hostapd/local.conf')
	
	def get(self):
		self.writeJson(Conf(self.confFile, section='x').dict('x') if self.confFile.is_file() else None)
	
	def post(self):
		if self.request.body:
			data = self.readJson()
			if not data['wpa_passphrase'].strip():
				del data['wpa_passphrase']
			Conf(self.confFile, data, section='x').save('x')
		else:
			self.confFile.unlink(True)
		system.restart('hostapd.service')



class LanHandler(server.RequestHandler):
	confFile = Path('/etc/systemd/network/lan.network.d/local.conf')
	
	def get(self):
		self.write(Conf(self.confFile).dict())
	
	def post(self):
		Conf(self.confFile, self.readJson()).save()
		system.restart('systemd-networkd.service')



class WlanHandler(server.RequestHandler):
	confFile = Path('/etc/wpa_supplicant.conf.d/local.conf')
	re_ssid = re.compile(r'ssid="(.*)"')
	
	def get(self):
		if self.confFile.is_file():
			match = self.re_ssid.search(self.confFile.read_text())
			self.write({'ssid': match.group(1) if match else ''})
		else:
			self.writeJson(None)
	
	def post(self):
		if self.request.body:
			data = self.readJson()
			with open(self.confFile, 'wb') as f:
				system.run(['wpa_passphrase', data['ssid'].encode(), data['psk'].encode()], stdout=f)
		else:
			self.confFile.unlink(True)
		system.restart('wpa_supplicant.service')



class WlanLanHandler(LanHandler):
	confFile = Path('/etc/systemd/network/wlan.network.d/local.conf')



server.addAjax(__name__+'/syswlan',		SyswlanHandler)
server.addAjax(__name__+'/lan',			LanHandler)
server.addAjax(__name__+'/wlan',		WlanHandler)
server.addAjax(__name__+'/wlan/lan',	WlanLanHandler)
