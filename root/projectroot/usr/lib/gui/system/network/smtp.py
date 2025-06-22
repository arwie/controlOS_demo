# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

import web
from shared.conf import Conf
from shared import network


web.document.imports.add('system/network/smtp')


@web.handler
class conf(web.RequestHandler):
	def get(self):
		if network.smtpEnabled():
			data = Conf(network.smtpConfFile).dict()
			del data['smtp']['pass'] #type:ignore
			self.write(data)
		else:
			self.write(None)
	
	def post(self):
		if data := self.read_json():
			Conf(network.smtpConfFile, data).save()
		else:
			network.smtpConfFile.unlink(True)
