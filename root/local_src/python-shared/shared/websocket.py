# Copyright (c) 2018 Artur Wiebe <artur@4wiebe.de>
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


import asyncio, json, logging
from tornado import websocket



class Client:
	def initialize(self, host, port, messageTimeout=None):
		self.url = 'ws://{}:{}'.format(host,port)
		self.messageTimeout = messageTimeout
	
	def __enter__(self):
		return self
	
	def __exit__(self, exc_type, exc_value, traceback):
		self.close()
	
	async def connect(self):
		self.ws = await websocket.websocket_connect(self.url)
		await self.onOpen()
		
	async def execute(self):
		while self.ws:
			try:
				msg = await asyncio.wait_for(self.ws.read_message(), self.messageTimeout)
			except asyncio.TimeoutError:
				msg = False
			
			if msg is False:
				await self.onMessageTimeout()
				continue
			
			if msg is None:
				await self.onClose()
				break
				
			await self.onMessage(msg)
	
	
	def close(self):
		if self.ws:
			self.ws.close()
			self.ws = None
	
	def writeMessageJson(self, data):
		self.ws.write_message(json.dumps(data))
	
	async def onMessage(self, data):
		await self.onMessageJson(json.loads(data))
	
	async def onMessageJson(self, data):
		pass
	
	async def onMessageTimeout(self):
		logging.error('websocket: message timeout')
		self.close()
	
	async def onInit(self):
		pass
	
	async def onOpen(self):
		pass
	
	async def onClose(self):
		pass



def run(client):
	async def execute():
		await client.onInit()
		await client.connect()
		with client:
			await client.execute()
	
	try:
		asyncio.run(execute())
	except:
		logging.exception('websocket: error in client')
		exit(1)
