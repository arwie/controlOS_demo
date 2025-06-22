# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

from __future__ import annotations
from typing import Any

from contextlib import suppress
import json
import socket
import logging

import tornado.web
import tornado.websocket

from tornado.web import Application, RedirectHandler, StaticFileHandler, HTTPError
from tornado.httpserver import HTTPServer
from tornado.websocket import WebSocketClosedError


logging.getLogger('tornado.access').setLevel(logging.WARNING)



class RequestHandler(tornado.web.RequestHandler):

	def initialize(self):
		self.set_header('Cache-Control', 'no-store, must-revalidate')

	def read_json(self):
		return json.loads(self.request.body.decode())

	def write(self, msg: bytes | Any):
		if not isinstance(msg, bytes):
			msg = json.dumps(msg).encode()
		super().write(msg)



class WebSocketHandler(tornado.websocket.WebSocketHandler):

	last_message = None

	def write_message(self, msg: bytes | Any, *, send_unchanged:bool = False, **kwargs):
		if not isinstance(msg, bytes):
			msg = json.dumps(msg).encode()
		if send_unchanged or msg != self.last_message:
			self.last_message = msg
			with suppress(WebSocketClosedError):
				super().write_message(msg, **kwargs).cancel()

	def on_message(self, msg):
		self.on_message_json(json.loads(msg))

	def on_message_json(self, msg:dict):
		raise NotImplemented



class WebSocketConnections(set[WebSocketHandler]):

	def write_message(self, msg: bytes | Any, **kwargs):
		if not isinstance(msg, bytes):
			msg = json.dumps(msg).encode()
		for conn in self:
			conn.write_message(msg, **kwargs)



def systemd_socket(fd:int):
	systemd_socket = socket.fromfd(fd, socket.AF_INET6, socket.SOCK_STREAM)
	systemd_socket.setblocking(False)
	return systemd_socket
