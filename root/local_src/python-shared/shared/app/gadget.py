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


import logging
import asyncio
import json


class UdpMaster(asyncio.DatagramProtocol):
	def __init__(self, host, port, cycle_time, timeout=3):
		self.address = (host, port)
		self.cycle_time = cycle_time
		self.timeout = timeout

		self.connected = False
		self.cmd = {}
		self.fbk = {}

	def connection_made(self, transport):
		pass

	def datagram_received(self, data, addr):
		self.fbk.update(json.loads(data.decode()))
		self.connected = True
		self.on_receive()
		self._on_timeout = asyncio.get_running_loop().time() + self.timeout

	def start(self):
		self._task = asyncio.create_task(self._run())

	def on_send(self):
		pass

	def on_receive(self):
		pass

	def on_timeout(self):
		logging.warning('gadget disconnected')

	async def _run(self):
		transport,_ = await asyncio.get_running_loop().create_datagram_endpoint(lambda:self, remote_addr=self.address)
		while True:
			await asyncio.sleep(self.cycle_time)
			self.on_send()
			transport.sendto(json.dumps(self.cmd).encode())
			if self.connected and asyncio.get_running_loop().time() > self._on_timeout:
				self.connected = False
				self.on_timeout()
