# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

import web
from pathlib import Path
from contextlib import suppress
from asyncio import to_thread
from shared import system


web.document.imports.append('system/update')


@web.handler
class release(web.RequestHandler):
	def get(self):
		with open('/etc/os-release') as release:
			self.write({ k: v.strip('"\n') for k,v in (l.split('=') for l in release if '=' in l) })
	
	async def put(self):
		await to_thread(
			system.run,
			['update'],
			input=self.request.body
		)


@web.handler
class revert(web.RequestHandler):
	def get(self):
		with suppress(Exception):
			self.write(Path('/var/revert').stat().st_mtime)
	
	async def post(self):
		await to_thread(
			system.run,
			['update','--revert']
		)
