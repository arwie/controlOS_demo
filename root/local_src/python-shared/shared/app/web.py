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


from __future__ import annotations
from typing import TYPE_CHECKING
if TYPE_CHECKING:
	from typing import Any

from contextlib import asynccontextmanager
import asyncio
import json
import socket
import tornado.web
import tornado.websocket
import tornado.httpserver
from . import app

from tornado.websocket import WebSocketClosedError



class RequestHandler(tornado.web.RequestHandler):

	@classmethod
	@asynccontextmanager
	async def exec(cls):
		yield

	def prepare(self):
		self.set_header('Access-Control-Allow-Origin', self.request.headers['Origin'])
	
	def read_json(self):
		return json.loads(self.request.body.decode())
	
	def write(self, msg: bytes | Any):
		if not isinstance(msg, bytes):
			msg = json.dumps(msg).encode()
			self.set_header("Content-Type", "application/json; charset=UTF-8")
		super().write(msg)



class WebSocketHandler(tornado.websocket.WebSocketHandler):

	class Connections(set[tornado.websocket.WebSocketHandler]):
		def __init__(self, Handler:type[WebSocketHandler]):
			super().__init__()
			self.Handler = Handler
			self.connected = asyncio.Event()

		def add(self, connection):
			super().add(connection)
			self.connected.set()

		def discard(self, connection):
			super().discard(connection)
			if not self:
				self.connected.clear()

		def write_message(self, msg: bytes | Any, **kwargs):
			if not isinstance(msg, bytes):
				msg = json.dumps(msg).encode()
			for conn in self:
				conn.write_message(msg, **kwargs)

		def write_update(self):
			self.write_message(self.Handler.update())

		async def update_loop(self, period:float=0.25):
			while True:
				await self.connected.wait()
				await asyncio.sleep(period)
				self.write_update()

	@classmethod
	def __init_subclass__(cls):
		cls.canceled = False
		cls.all = WebSocketHandler.Connections(cls)

	@classmethod
	@asynccontextmanager
	async def exec(cls):
		cls.canceled = False
		try:
			yield
		finally:
			cls.canceled = True
			for conn in cls.all:
				conn.close()

	@classmethod
	def update(cls):
		raise NotImplemented

	def check_origin(self, origin):
		return True

	def open(self):
		if self.canceled:
			raise tornado.web.HTTPError(405)
		self.set_nodelay(True)
		self.on_open()
		self.all.add(self)

	def on_open(self):
		self.write_update()

	def on_close(self):
		self.all.discard(self)
	
	def write_message(self, msg: bytes | Any, **kwargs):
		if not isinstance(msg, bytes):
			msg = json.dumps(msg).encode()
		super().write_message(msg, **kwargs)

	def write_update(self):
		self.write_message(self.update())

	def on_message(self, msg):
		self.on_message_json(json.loads(msg))

	def on_message_json(self, msg:dict):
		raise NotImplemented



class Placeholder(RequestHandler):
	Handler = None
	target: str

	def __new__(cls, *args, **kwargs):
		return super().__new__(cls) if cls.Handler is None else cls.Handler(*args, **kwargs)

	@classmethod
	@asynccontextmanager
	async def handle(cls, Handler: type[RequestHandler] | type[WebSocketHandler]):
		async with Handler.exec(), app.target(cls.target):
			cls.Handler = Handler
			try:
				yield
			finally:
				cls.Handler = None



handlers = []

def placeholder(name, params={}):
	class NewPlaceholder(Placeholder):
		target = name
	handlers.append((f'/{name}', NewPlaceholder, params))
	return NewPlaceholder

def handler(name, params={}):
	def add_handler(Handler):
		handlers.append((f'/{name}', Handler, params))
		return Handler
	return add_handler



@app.context
async def server():
	srv = tornado.httpserver.HTTPServer(tornado.web.Application(handlers))
	systemdSocket = socket.fromfd(3, socket.AF_INET6, socket.SOCK_STREAM)
	systemdSocket.setblocking(False)
	srv.add_socket(systemdSocket)
	try:
		yield
	finally:
		srv.stop()
		await srv.close_all_connections()
