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
	from typing import TypeVar
	from collections.abc import Callable
	SimioTypes = TypeVar('SimioTypes', bool, int, float, str)

from typing import get_type_hints
from contextlib import AbstractContextManager
from . import app
from . import web



_simio:list[Input | Output] = []


class Input:
	direction = 'in'

	def __init__(self, io):
		_simio.append(self)
		self.name = f"{str(io.__module__).strip('_')}.{io.__name__}"
		self.io = io
		self.type = next(iter(get_type_hints(io).values()))
		self.override = None

	def _get(self):
		return self.type(self.io())

	def _override(self, override):
		try:
			self.override = None if override is None else self.type(override)
			return True
		except Exception:
			return False

	def __call__(self) -> SimioTypes:
		return self._get() if self.override is None else self.override


class Output(Input, AbstractContextManager):
	direction = 'out'

	def __init__(self, io):
		super().__init__(io)
		self.value = self.type()

	def _get(self):
		return self.value

	def _override(self, override):
		if super()._override(override):
			self._set(self.override if self.override is not None else self.value)

	def _set(self, value):
		self.io(value)

	def __call__(self, value=None):
		self.value = self.type() if value is None else self.type(value)
		if self.override is None:
			self._set(self.value)
		return self

	def __exit__(self, *exc):
		self()



def input(io:Callable[[], SimioTypes]):
	return Input(io)

def output(io:Callable[[SimioTypes], None]):
	return Output(io)



SimioWebSocketPlaceholder = web.placeholder('simio')

@app.context
async def exec():

	class SimioWebSocketHandler(web.WebSocketHandler):
		@classmethod
		def update(cls):
			return [{
				'id':		id,
				'ord':		simio.override,
				'val':		simio._get(),
			} for id,simio in enumerate(_simio)]

		def on_open(self):
			self.write_message(
				[{
					'id':		id,
					'dir':		simio.direction,
					'name':		simio.name,
					'type':		simio.type.__name__,
					'sim':		False,
				} for id,simio in enumerate(_simio)]
			)
			self.write_update()

		def on_message_json(self, msg):
			_simio[msg['id']]._override(msg['ord'])
			self.all.write_update()

	with SimioWebSocketPlaceholder.handle(SimioWebSocketHandler):
		async with app.target('simio'):
			async with app.task_group(SimioWebSocketHandler.all.update_loop()):
				yield
