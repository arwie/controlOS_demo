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


import asyncio
import server



cmd = ['journalctl', '--file=/var/log/journal/*/*', '--merge']

def journalctl_subprocess(*args, lines, output):
	return asyncio.create_subprocess_exec(*cmd, *args, f'--lines={lines}', f'--output={output}', stdout=asyncio.subprocess.PIPE, stderr=asyncio.subprocess.PIPE)



class Handler(server.WebSocketHandler):
	
	async def readJournal(self, args, lines):
		proc = await journalctl_subprocess(*args, lines=lines, output='json')
		try:
			while proc.stdout and (msg := await proc.stdout.readline()):
				self.write_message(msg)
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


class FieldHandler(server.RequestHandler):
	async def get(self, field:str):
		values = await journalctl(['--field='+field])
		self.writeJson(values.decode().splitlines())


class CatHandler(server.RequestHandler):
	async def get(self, field:str, cursor:str):
		self.set_header('Content-Type', 'application/octet-stream')
		self.set_header('Content-Disposition', 'attachment; filename='+field.replace('_','.'))
		self.write(await journalctl(['--output-fields='+field, '--cursor='+cursor], lines=1))



server.addAjax(__name__,					Handler)
server.addAjax(__name__+'/field/(.*)',		FieldHandler)
server.addAjax(__name__+'/cat/(.*)/(.*)',	CatHandler)
