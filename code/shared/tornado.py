# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

from __future__ import annotations
from typing import Any
from contextlib import suppress
import asyncio
import json
import socket
from shared import log

import tornado.web
import tornado.websocket

from tornado.web import Application, RedirectHandler, StaticFileHandler, HTTPError
from tornado.httpserver import HTTPServer
from tornado.websocket import WebSocketClosedError

import logging
logging.getLogger('tornado.access').setLevel(logging.WARNING)



class RequestHandler(tornado.web.RequestHandler):

	def initialize(self):
		self.set_header('Cache-Control', 'no-store, must-revalidate')

	def read_json(self):
		return json.loads(self.request.body)

	def write(self, msg: bytes | Any):
		if not isinstance(msg, bytes):
			msg = json.dumps(msg).encode()
		super().write(msg)



class WebSocketHandler(tornado.websocket.WebSocketHandler):

	last_message = None

	async def write_message(self, msg: bytes | Any, *, skip_unchanged = True, **kwargs):
		if not isinstance(msg, bytes):
			msg = json.dumps(msg).encode()
		if skip_unchanged:
			if msg == self.last_message:
				return
			self.last_message = msg
		with suppress(WebSocketClosedError):
			await super().write_message(msg, **kwargs)
			return True

	async def on_message(self, msg):
		await self.on_message_json(json.loads(msg))

	async def on_message_json(self, msg):
		raise NotImplemented

	async def open(self):
		self.update_task = asyncio.create_task(self._update())
		await self.on_open()

	async def on_open(self):
		pass

	def on_close(self):
		self.update_task.cancel()

	async def _update(self):
		try:
			await self.update()
		except Exception as e:
			log.exception(f'WebSocket {self.request.path} update task error: {e}')
		finally:
			self.close()

	async def update(self):
		pass



def systemd_socket(fd:int):
	sock = socket.fromfd(fd, socket.AF_INET6, socket.SOCK_STREAM)
	sock.setblocking(False)
	return sock
