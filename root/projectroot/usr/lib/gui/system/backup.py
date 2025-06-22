# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

import web
from asyncio import to_thread
from shared import system


web.document.imports.add('system/backup')


@web.handler
class restore(web.RequestHandler):
	async def put(self):
		await to_thread(
			system.run,
			['backup','--restore'],
			input=self.request.body
		)
