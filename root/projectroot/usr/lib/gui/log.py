# Copyright (c) 2016 Artur Wiebe <artur@4wiebe.de>
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
import shlex, json
from tornado import process, iostream



def setArgs(journalFile):
	global journalArgs
	journalArgs = ['/usr/bin/journalctl', '--file='+journalFile]

setArgs('/var/log/journal/*/*')



class Handler(server.WebSocketHandler):
	
	async def readJournal(self, args):
		journalProc = process.Subprocess(args, stdout=process.Subprocess.STREAM)
		try:
			while not self.task.cancelled():
				msg = await journalProc.stdout.read_until(b'\n')
				msg = json.loads(msg.decode())
				
				if not '_SOURCE_REALTIME_TIMESTAMP' in msg:
					msg['_SOURCE_REALTIME_TIMESTAMP'] = msg['__REALTIME_TIMESTAMP']
				msg = {k: v for k,v in msg.items() if not k.startswith('__')}
				
				self.write_messageJson(msg)
				
		except (iostream.StreamClosedError, asyncio.CancelledError):
			pass
		finally:
			self.close()
			journalProc.proc.terminate()
			await journalProc.wait_for_exit(raise_error=False)
	
	
	def open(self):
		args = journalArgs.copy()
		args.extend(shlex.split(self.get_argument('args')))
		args.append('--lines=300')
		args.append('--output=json')
		args.append('--all')
		args.append('--follow')
		args.append('--merge')
		
		self.task = asyncio.create_task(self.readJournal(args))

	def on_close(self):
		self.task.cancel()




class LogFieldHandler(server.RequestHandler):
	
	async def get(self, field):
		args = journalArgs.copy()
		args.append('--field={}'.format(field))
		journalProc = process.Subprocess(args, stdout=process.Subprocess.STREAM)
		
		values = await journalProc.stdout.read_until_close()
		self.writeJson(values.decode().splitlines())

		await journalProc.wait_for_exit(raise_error=False)



server.addAjax(__name__,			Handler)
server.addAjax(__name__+'/(.*)',	LogFieldHandler)
