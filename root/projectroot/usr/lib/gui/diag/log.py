# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

import asyncio
import web


web.document.imports.add('diag/log')



cmd = ['journalctl', '--file=/var/log/journal/*/*', '--merge']

def journalctl_subprocess(*args, lines, output):
	return asyncio.create_subprocess_exec(*cmd, *args, f'--lines={lines}', f'--output={output}', stdout=asyncio.subprocess.PIPE, stderr=asyncio.subprocess.PIPE)


@web.handler
class feed(web.WebSocketHandler):
	
	async def readJournal(self, args, lines):
		proc = await journalctl_subprocess(*args, lines=lines, output='json')
		try:
			while proc.stdout and (msg := await proc.stdout.readline()):
				self.write_message(msg, send_unchanged=True)
			await proc.wait()
		finally:
			self.close()
			proc.terminate()


	def open(self):
		args = [f"--priority={self.get_query_argument('priority', 'notice')}"]
		
		lines = int(self.get_query_argument('lines', '50'))
		if lines < 0:
			args.append('--reverse')
		
		if cursor := self.get_query_argument('cursor', None):
			args.append('--after-cursor='+cursor)
		else:
			if date := self.get_query_argument('date', None):
				args.append('--since='+date)
				args.append(f'--until={date} 23:59:59')
			else:
				if lines > 0:
					args.append('--follow')
		
		if identifier := self.get_query_argument('identifier', None):
			args.append('--identifier='+identifier)
		
		if grep := self.get_query_argument('grep', None):
			args.append('--grep='+grep)
		
		if filter := self.get_query_argument('filter', None):
			for arg in filter.split():
				args.append(arg.lstrip('-'))
		
		self.task = asyncio.create_task(self.readJournal(args, abs(lines)))


	def on_close(self):
		self.task.cancel()



async def journalctl(args, lines:int|str='all'):
	proc = await journalctl_subprocess(*args, lines=lines, output='cat')
	stdout, stderr = await proc.communicate()
	return stdout


async def get_field(field):
	values = await journalctl([f'--field={field}'])
	return values.decode().splitlines()


@web.handler
class field(web.RequestHandler):
	async def get(self):
		self.write(await get_field(self.get_query_argument('field')))


@web.handler
class cat(web.RequestHandler):
	async def get(self):
		field  = self.get_query_argument('field')
		cursor = self.get_query_argument('cursor')
		self.set_header('Content-Type', 'application/octet-stream')
		self.set_header('Content-Disposition', f'attachment; filename={field}')
		self.write(await journalctl([f'--output-fields={field}', f'--cursor={cursor}'], lines=1))



@web.handler
class config(web.ModuleHandler):
	extlog = False
	hosts = list()
	async def export_default(self):
		if not self.hosts:
			self.hosts.extend(await get_field('_HOSTNAME'))
		return {
			'hosts': self.hosts,
			'extlog': self.extlog,
		}
