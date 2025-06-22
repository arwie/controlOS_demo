# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

import web
from asyncio import to_thread
from shared import system


web.document.imports.add('system/remote')


@web.handler
class service(web.RequestHandler):
	
	async def get(self):
		status = await to_thread(system.status_text, 'remote@*.service')
		self.write(status.encode())
	
	def post(self):
		system.stop('remote@*.service')
		if port := self.get_query_argument('port', None):
			port = int(port)
			if 60000 <= port <= 65500:
				system.restart(f'remote@{port}.service')
