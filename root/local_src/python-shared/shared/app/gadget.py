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


from contextlib import asynccontextmanager
import asyncio
import json
from . import app



class UdpMaster(asyncio.DatagramProtocol):
	def __init__(self, host:str, port:int, cycle_time:float, timeout:float=3):
		self.address = (host, port)
		self.cycle_time = cycle_time
		self.timeout = app.Timeout(timeout)

		self.connected = False
		self.cmd = {}
		self.fbk = {}

		self.sync_event = app.Event()
		self.sync = self.sync_event.wait

	def connection_made(self, transport):
		pass

	def on_timeout(self):
		app.log.warning('gadget disconnected')

	def datagram_received(self, data, addr):
		self.fbk.update(json.loads(data.decode()))
		self.connected = True
		self.sync_event.trigger()
		self.timeout.reset()

	@asynccontextmanager
	async def exec(self):
		transport,_ = await asyncio.get_running_loop().create_datagram_endpoint(lambda:self, remote_addr=self.address)

		async def loop():
			while True:
				await asyncio.sleep(self.cycle_time)
				transport.sendto(json.dumps(self.cmd).encode())
				if self.connected and self.timeout():
					self.connected = False
					self.on_timeout()

		async with app.task_group(loop()):
			yield