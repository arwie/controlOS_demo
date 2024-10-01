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
	from typing import overload, TypeVar, Any
	from collections.abc import Callable
	SimioTypes = TypeVar('SimioTypes', bool, int, float, str)

from typing import get_type_hints
from contextlib import AbstractContextManager
from configparser import ConfigParser
from . import app
from . import web



_conf = ConfigParser()
_conf.read('/etc/app/simio.conf')


_simio:list[_IOBase] = []


class _IOBase:
	value: Any
	_io_sim: Callable

	def __init__(self, io:Callable, *, prefix=None):
		_simio.append(self)
		io_module = '.'.join(p.strip('_') for p in io.__module__.split('.'))
		io_name   = '.'.join(p.strip('_') for p in (prefix, io.__name__) if p)
		self.name = f'{io_module}: {io_name}'
		self.type:type = next(iter(get_type_hints(io).values()))
		self.override = None
		self.simulated = _conf.getboolean(
			io_module, io_name,
			fallback=_conf.getboolean(
				io_module, self.__class__.__name__,
				fallback=_conf.getboolean(
					'app', self.__class__.__name__,
					fallback=False
				)
			)
		)
		self._io = self._io_sim if self.simulated else io

	def set_override(self, override):
		try:
			self.override = None if override is None else self.type(override)
			return True
		except Exception:
			return False


class Input(_IOBase):
	def __init__(self, io, *, sim=None, **kwargs):
		super().__init__(io, **kwargs)
		self.sim = self.type() if sim is None else sim

	def _io_sim(self):
		return self.sim() if callable(self.sim) else self.sim

	@property
	def value(self):
		return self._io()

	def __call__(self) -> SimioTypes:
		return self.value if self.override is None else self.override


class Output(_IOBase, AbstractContextManager):
	def __init__(self, io, **kwargs):
		super().__init__(io, **kwargs)
		self.value = self.type()

	@staticmethod
	def _io_sim(value):
		pass

	def set_override(self, override):
		if super().set_override(override):
			self._io(self.override if self.override is not None else self.value)

	def __call__(self, value=None):
		self.value = self.type() if value is None else self.type(value)
		if self.override is None:
			self._io(self.value)
		return self

	def __exit__(self, *exc):
		self()



if TYPE_CHECKING:
	@overload
	def input(
		io: Callable[[], SimioTypes],
		*,
		prefix: str | None = None,
		sim: SimioTypes | Callable[[], SimioTypes] | None = None
	) -> Input:
		pass
	@overload
	def input(
		*,
		prefix: str | None = None,
		sim: SimioTypes | Callable[[], SimioTypes] | None = None
	) -> Callable[[Callable[[], SimioTypes]], Input]:
		pass

def input(io=None, **kwargs):
	def decorator(io, /):
		return Input(io, **kwargs)
	return decorator if io is None else decorator(io)


if TYPE_CHECKING:
	@overload
	def output(
		io: Callable[[SimioTypes], None],
		*,
		prefix: str | None = None,
	) -> Output:
		pass
	@overload
	def output(
		*,
		prefix: str | None = None,
	) -> Callable[[Callable[[SimioTypes], None]], Output]:
		pass

def output(io=None, **kwargs):
	def decorator(io, /):
		return Output(io, **kwargs)
	return decorator if io is None else decorator(io)



SimioWebSocketPlaceholder = web.placeholder('simio')

@app.context
async def exec():

	class SimioWebSocketHandler(web.WebSocketHandler):
		@classmethod
		def update(cls):
			return [{
				'id':		id,
				'ord':		simio.override,
				'val':		simio.value,
			} for id,simio in enumerate(_simio)]

		def on_open(self):
			self.write_message(
				[{
					'id':		id,
					'cls':		simio.__class__.__name__,
					'name':		simio.name,
					'type':		simio.type.__name__,
					'sim':		simio.simulated,
				} for id,simio in enumerate(_simio)]
			)
			self.write_update()

		def on_message_json(self, msg):
			_simio[int(msg['id'])].set_override(msg['ord'])
			self.all.write_update()

	async with SimioWebSocketPlaceholder.handle(SimioWebSocketHandler):
		async with app.task_group(SimioWebSocketHandler.all.update_loop()):
			yield
