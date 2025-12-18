# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

from asyncio import to_thread
import web
from shared import system


web.document.imports.append('system/timedate')



def timedatectl(*args:str, **kwargs):
	return to_thread(system.run, ['timedatectl','--no-pager', *args], **kwargs)



@web.handler
class status(web.RequestHandler):

	async def get(self):
		status:bytes = await timedatectl('status', text=False)
		self.write(status.rstrip())



@web.handler
class time(web.RequestHandler):

	async def get(self):
		show:str = await timedatectl('show', text=True)
		self.write(dict(line.split('=', 1) for line in show.splitlines()))

	async def post(self):
		await timedatectl('set-ntp', 'false')
		await timedatectl('set-time', f'@{self.read_json()}')



@web.handler
class timezone(web.RequestHandler):

	async def get(self):
		timezones:str = await timedatectl('list-timezones', text=True)
		self.write(timezones.splitlines())

	async def post(self):
		await timedatectl('set-timezone', self.read_json())
		await to_thread(system.run, ['systemctl', '--no-block', 'try-restart', 'cog.service'])


