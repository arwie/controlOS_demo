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
	from collections.abc import Callable, Coroutine

from contextlib import asynccontextmanager, suppress
from functools import partial
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
		if origin := self.request.headers.get('Origin'):
			self.set_header('Access-Control-Allow-Origin', origin)
	
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
			self.connected_event = asyncio.Event()

		def add(self, connection):
			super().add(connection)
			self.connected_event.set()

		def discard(self, connection):
			super().discard(connection)
			if not self:
				self.connected_event.clear()

		def write_message(self, msg: bytes | Any, **kwargs):
			if not isinstance(msg, bytes):
				msg = json.dumps(msg).encode()
			for conn in self:
				conn.write_message(msg, **kwargs)

		def write_update(self, *args):
			if self:
				self.write_message(self.Handler.update(*args))

	@classmethod
	def __init_subclass__(cls):
		cls.all = WebSocketHandler.Connections(cls)

	@classmethod
	@asynccontextmanager
	async def exec(cls, *, update_period: float | app.Trigger | Callable[[], Coroutine] = 0.25):
		async with app.task_group() as cls.task_group:

			if cls.update.__func__ is not WebSocketHandler.update.__func__:	#update() was overriden in subclass

				if isinstance(update_period, (float, int)):
					update_period = partial(asyncio.sleep, update_period)
				elif isinstance(update_period, app.Trigger):
					update_period = update_period.wait

				@cls.task_group
				async def all_update_loop():
					while True:
						await cls.all.connected_event.wait()
						await update_period()
						cls.all.write_update()

			cls.canceled = False
			try:
				yield
			finally:
				cls.canceled = True
				for conn in cls.all:
					conn.close()

	@classmethod
	def update(cls, *args):
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
		with suppress(WebSocketClosedError):
			super().write_message(msg, **kwargs).cancel()

	def write_update(self, *args):
		self.write_message(self.update(*args))

	def on_message(self, msg):
		self.on_message_json(json.loads(msg))

	def on_message_json(self, msg:dict):
		raise NotImplemented
	
	@property
	def connected(self):
		return len(self.all)



class Placeholder(RequestHandler):
	Handler = None
	target: str

	def __new__(cls, *args, **kwargs):
		return super().__new__(cls) if cls.Handler is None else cls.Handler(*args, **kwargs)

	@classmethod
	@asynccontextmanager
	async def handle(cls, Handler: type[RequestHandler] | type[WebSocketHandler], **kwargs):
		async with (
			Handler.exec(**kwargs),
			app.target(cls.target),
		):
			cls.Handler = Handler
			try:
				yield
			finally:
				cls.Handler = None



handlers = []

def placeholder(name, **kwargs):
	class NewPlaceholder(Placeholder):
		target = name
	handlers.append((f'/{name}', NewPlaceholder, kwargs))
	return NewPlaceholder



@app.context
async def server():
	srv = tornado.httpserver.HTTPServer(
		tornado.web.Application(
			handlers,
			websocket_ping_interval=10,
		)
	)
	systemdSocket = socket.fromfd(3, socket.AF_INET6, socket.SOCK_STREAM)
	systemdSocket.setblocking(False)
	srv.add_socket(systemdSocket)
	try:
		yield
	finally:
		srv.stop()
		await srv.close_all_connections()
