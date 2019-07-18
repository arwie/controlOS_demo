# Copyright (c) 2017 Artur Wiebe <artur@4wiebe.de>
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


import server, asyncio
from shared.conf import Conf
from shared import network, system
from tornado import websocket
import os, subprocess, re



class StatusHandler(server.WebSocketHandler):
	async def sendStatus(self):
		try:
			while not self.task.cancelled():
				self.write_message(await server.run_in_executor(network.status))
				await asyncio.sleep(3)
		except asyncio.CancelledError:
			pass

	def open(self):
		self.task = asyncio.create_task(self.sendStatus())

	def on_close(self):
		self.task.cancel()



class SyswlanHandler(server.RequestHandler):
	def initialize(self):
		self.confFile = '/etc/hostapd.conf.d/local.conf'
	
	def get(self):
		if os.path.isfile(self.confFile):
			self.write(Conf(self.confFile, section='x').dict('x'))
		else:
			self.write({})
	
	def post(self):
		if self.request.body:
			Conf(self.confFile, self.readJson(), section='x').save('x')
		else:
			try: os.remove(self.confFile)
			except OSError: pass
		system.restart('hostapd.service')



class LanHandler(server.RequestHandler):
	def initialize(self):
		self.confFile = '/etc/systemd/network/lan.network.d/local.conf'
	
	def get(self):
		self.write(Conf(self.confFile).dict())
	
	def post(self):
		Conf(self.confFile, self.readJson()).save()
		system.restart('systemd-networkd.service')



class WlanHandler(server.RequestHandler):
	def initialize(self):
		self.confFile = '/etc/wpa_supplicant.conf.d/local.conf'
	
	def get(self):
		if os.path.isfile(self.confFile):
			match = re.compile(r'ssid="(.*)"').search(open(self.confFile, encoding='utf8').read())
			if match:
				self.write({'ssid':match.group(1)})
		else:
			self.write({})
	
	def post(self):
		if self.request.body:
			data = self.readJson()
			with open(self.confFile, 'wb') as f:
				subprocess.run(['wpa_passphrase', data['ssid'].encode(), data['psk'].encode()], stdout=f, check=True)
		else:
			try: os.remove(self.confFile)
			except OSError: pass
		system.restart('wpa_supplicant.service')


class WlanLanHandler(LanHandler):
	def initialize(self):
		self.confFile = '/etc/systemd/network/wlan.network.d/local.conf'



class SmtpHandler(server.RequestHandler):
	def get(self):
		if network.smtpEnabled():
			self.write(Conf(network.smtpConfFile).dict())
		else:
			self.write({})
	
	def post(self):
		if self.request.body:
			Conf(network.smtpConfFile, self.readJson()).save()
		else:
			try: os.remove(network.smtpConfFile)
			except OSError: pass



server.addAjax(__name__+'/status',		StatusHandler)
server.addAjax(__name__+'/syswlan',		SyswlanHandler)
server.addAjax(__name__+'/lan',			LanHandler)
server.addAjax(__name__+'/wlan',		WlanHandler)
server.addAjax(__name__+'/wlan/lan',	WlanLanHandler)
server.addAjax(__name__+'/smtp',		SmtpHandler)
