# Copyright (c) 2019 Artur Wiebe <artur@4wiebe.de>
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
from shared import state



class Handler(server.WebSocketHandler):
	def post(self):
		pass	# connection test
	
	def open(self):
		self.set_nodelay(True)
		self.observer = state.subscribe()
		self.task = asyncio.create_task(self.sendState())
	
	def on_close(self):
		self.task.cancel()
		state.unsubscribe(self.observer)
	
	async def sendState(self):
		while not self.task.cancelled():
			try:
				msg = list(await asyncio.wait_for(state.update(self.observer), 1))
			except asyncio.TimeoutError:
				msg = None	# watchdog
			except asyncio.CancelledError:
				break
			self.write_messageJson(msg)



server.addAjax(__name__, Handler)
