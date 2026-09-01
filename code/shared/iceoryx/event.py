# SPDX-FileCopyrightText: 2026 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

from __future__ import annotations
from shared.asyncio import Trigger, asyncio_loop
from . import IoxService, IoxPort



class IoxEvent(IoxService):

	def __init__(self, name:str):
		super().__init__(name, lambda sb: sb.event())


class IoxNotifier(IoxPort[IoxEvent]):

	def __init__(self, service:IoxEvent):
		super().__init__(service, service.notifier_builder())


class IoxListener(IoxPort[IoxEvent], Trigger):

	def __init__(self, service:IoxEvent):
		IoxPort.__init__(self, service, service.listener_builder())
		Trigger.__init__(self)
		self._fd = self.file_descriptor.native_handle
		asyncio_loop.add_reader(self._fd, self._readable)

	def _readable(self):
		for event_id in self.try_wait_all():
			self.handle(event_id)

	def __exit__(self, et, exc, tb):
		asyncio_loop.remove_reader(self._fd)
		self.delete()

	def handle(self, event_id):
		self()
