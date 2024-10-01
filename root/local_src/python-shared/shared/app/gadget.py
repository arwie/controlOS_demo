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


from contextlib import asynccontextmanager, closing
import asyncio
import json
from . import app
from shared.condition import Timeout



class UdpMaster(asyncio.DatagramProtocol):
	def __init__(self, host:str, port:int, period:float, timeout:float=3):
		self.address = (host, port)
		self.period = period
		self.timeout = Timeout(timeout)

		self.connected = False
		self.cmd = {}
		self.fbk = {}


	def connection_made(self, transport):
		pass


	def datagram_received(self, data, addr):
		self.fbk.update(json.loads(data.decode()))
		self.connected = True
		self.timeout.reset()


	@asynccontextmanager
	async def exec(self):
		transport,_ = await asyncio.get_running_loop().create_datagram_endpoint(lambda:self, remote_addr=self.address)
		with closing(transport):

			async def loop():
				while True:
					await asyncio.sleep(self.period)
					transport.sendto(json.dumps(self.cmd).encode())
					if self.connected and self.timeout:
						self.connected = False
						app.log.warning(f'gadget {self.address} disconnected')

			async with app.task_group(loop()):
				yield
