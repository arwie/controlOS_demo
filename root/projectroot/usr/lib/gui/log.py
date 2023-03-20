# Copyright (c) 2023 Artur Wiebe <artur@4wiebe.de>
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


import server, asyncio, json
from tornado import process, iostream



cmd = ['journalctl', '--file=/var/log/journal/*/*', '--merge']


async def journalctl(args, lines='all', output='cat', wait=True):
	proc = process.Subprocess([*cmd, '--lines='+str(lines), '--output='+output, *args], stdout=process.Subprocess.STREAM)
	if wait:
		stdout = await proc.stdout.read_until_close()
		await proc.wait_for_exit(raise_error=False)
		return stdout
	else:
		return proc


class Handler(server.WebSocketHandler):
	
	async def readJournal(self, args, lines):
		journalProc = await journalctl(args, lines, 'json', False)
		try:
			while not self.task.cancelled():
				self.write_message(await journalProc.stdout.read_until(b'\n'))
		except (iostream.StreamClosedError, asyncio.CancelledError):
			pass
		finally:
			self.close()
			journalProc.proc.terminate()
			await journalProc.wait_for_exit(raise_error=False)
	
	def open(self):
		args = ['--priority='+self.get_query_argument('priority', 'notice')]
		
		lines = int(self.get_query_argument('lines', 50))
		if lines < 0:
			args.append('--reverse')
		
		cursor = self.get_query_argument('cursor', None)
		if cursor:
			args.append('--after-cursor='+cursor)
		else:
			date = self.get_query_argument('date', None)
			if date:
				args.append('--since='+date)
				args.append('--until={} 23:59:59'.format(date))
			else:
				if lines > 0:
					args.append('--follow')
		
		identifier = self.get_query_argument('identifier', None)
		if identifier:
			args.append('--identifier='+identifier)
		
		grep = self.get_query_argument('grep', None)
		if grep:
			args.append('--grep='+grep)
		
		filter = self.get_query_argument('filter', '')
		for arg in filter.split():
			args.append(arg.lstrip('-'))
		
		self.task = asyncio.create_task(self.readJournal(args, abs(lines)))

	def on_close(self):
		self.task.cancel()



class FieldHandler(server.RequestHandler):
	async def get(self, field):
		values = await journalctl(['--field={}'.format(field)])
		self.writeJson(values.decode().splitlines())


class CatHandler(server.RequestHandler):
	async def get(self, field, cursor):
		self.set_header('Content-Type', 'application/octet-stream')
		self.set_header('Content-Disposition', 'attachment; filename='+field.replace('_','.'))
		self.write(await journalctl(['--output-fields='+field, '--cursor='+cursor], 1))



server.addAjax(__name__,					Handler)
server.addAjax(__name__+'/field/(.*)',		FieldHandler)
server.addAjax(__name__+'/cat/(.*)/(.*)',	CatHandler)
