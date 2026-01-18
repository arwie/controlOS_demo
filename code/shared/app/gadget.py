# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

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
		self.fbk.update(json.loads(data))
		self.connected = True
		self.timeout.reset()


	@asynccontextmanager
	async def exec(self):
		transport,_ = await asyncio.get_running_loop().create_datagram_endpoint(lambda:self, remote_addr=self.address)
		with closing(transport):

			@app.aux_task
			async def sync_loop():
				while True:
					await asyncio.sleep(self.period)
					transport.sendto(json.dumps(self.cmd).encode())
					if self.connected and self.timeout:
						self.connected = False
						app.log.warning(f'gadget {self.address} disconnected')

			async with sync_loop():
				yield
