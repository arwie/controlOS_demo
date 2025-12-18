# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

from __future__ import annotations
from typing import Any
from collections.abc import Callable, Coroutine

from contextlib import asynccontextmanager
from functools import partial
import asyncio

from shared import tornado
from . import app



class RequestHandler(tornado.RequestHandler):

	@classmethod
	@asynccontextmanager
	async def exec(cls):
		yield

	def prepare(self):
		if origin := self.request.headers.get('Origin'):
			self.set_header('Access-Control-Allow-Origin', origin)



class WebSocketHandler(tornado.WebSocketHandler):

	class Connections(tornado.WebSocketConnections):
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

		def write_update(self, *args):
			if self:
				self.write_message(self.Handler.update(*args))

	@classmethod
	def __init_subclass__(cls):
		cls.all = WebSocketHandler.Connections(cls)

	@classmethod
	@asynccontextmanager
	async def exec(cls, *, update_period: float | app.Trigger | Callable[[], Coroutine] = 0.25):
		async with app.AuxTaskGroup() as cls.task_group:

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
			raise tornado.HTTPError(405)
		self.set_nodelay(True)
		self.on_open()
		self.all.add(self)

	def on_open(self):
		self.write_update()

	def on_close(self):
		self.all.discard(self)

	def write_update(self, *args):
		self.write_message(self.update(*args))

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
	srv = tornado.HTTPServer(
		tornado.Application(
			handlers,
			websocket_ping_interval=10,
		)
	)
	srv.add_socket(tornado.systemd_socket(3))
	try:
		yield
	finally:
		srv.stop()
		await srv.close_all_connections()
