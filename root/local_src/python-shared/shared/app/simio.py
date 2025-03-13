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
from contextlib import AbstractContextManager, closing, suppress
from configparser import ConfigParser
from shared import system
from . import app
from . import web



_conf = ConfigParser()
_conf.read('/etc/app/simio.conf')
_virtual = system.virtual()


class _IOBase:
	value: Any
	_io_sim: Callable

	def __init__(self, io:Callable, *, module=None, prefix=None, simulated=False):
		io_module = '.'.join(p.strip('_') for p in (module or io.__module__).split('.'))
		io_name   = '.'.join(p.strip('_') for p in (prefix, io.__name__) if p)
		self.name = f'{io_module}: {io_name}'
		self.type:type = next(iter(get_type_hints(io).values()))
		self.override = None
		self.simulated = simulated or _conf.getboolean(
			io_module, io_name,
			fallback=_conf.getboolean(
				io_module, self.__class__.__name__,
				fallback=_conf.getboolean(
					'app', self.__class__.__name__,
					fallback=_virtual
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

	def open(self):
		_WebHandler.add_simio(self)
		return closing(self)

	def close(self):
		_WebHandler.remove_simio(self)


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



class IoGroup(AbstractContextManager):

	def __init__(self, *, module: str | None = None, prefix: str | None = None):
		self.module = module
		self.prefix = prefix
		self._simio = list[_IOBase]()

	def __exit__(self, *exc):
		for simio in self._simio:
			if isinstance(simio, AbstractContextManager):
				simio.__exit__(*exc)


	def open(self):
		for simio in self._simio:
			simio.open()
		_WebHandler.all.write_update()
		return closing(self)

	def close(self):
		for simio in self._simio:
			simio.close()
		_WebHandler.all.write_update()


	if TYPE_CHECKING:
		@overload
		def input(
			self,
			io: Callable[[], SimioTypes]
		) -> Input:
			pass
		@overload
		def input(
			self,
			*,
			prefix: str | None = None,
			sim: SimioTypes | Callable[[], SimioTypes] | None = None,
			simulated = False,
		) -> Callable[[Callable[[], SimioTypes]], Input]:
			pass

	def input(self, io=None, **kwargs):
		def decorator(io, /):
			kwargs.setdefault('module', self.module)
			kwargs.setdefault('prefix', self.prefix)
			simio = Input(io, **kwargs)
			self._simio.append(simio)
			return simio
		return decorator if io is None else decorator(io)


	if TYPE_CHECKING:
		@overload
		def output(
			self,
			io: Callable[[SimioTypes], None]
		) -> Output:
			pass
		@overload
		def output(
			self,
			*,
			prefix: str | None = None,
			simulated = False,
		) -> Callable[[Callable[[SimioTypes], None]], Output]:
			pass

	def output(self, io=None, **kwargs):
		def decorator(io, /):
			kwargs.setdefault('module', self.module)
			kwargs.setdefault('prefix', self.prefix)
			simio = Output(io, **kwargs)
			self._simio.append(simio)
			return simio
		return decorator if io is None else decorator(io)



default_io_group = IoGroup()
input  = default_io_group.input
output = default_io_group.output



_web_placeholder = web.placeholder('simio')

class _WebHandler(web.WebSocketHandler):

	_simio = dict[int, _IOBase]()
	_simio_changed = False

	@classmethod
	def add_simio(cls, simio:_IOBase):
		cls._simio[id(simio)] = simio
		cls._simio_changed = True

	@classmethod
	def remove_simio(cls, simio:_IOBase):
		with suppress(Exception):
			del cls._simio[id(simio)]
			cls._simio_changed = True

	@classmethod
	def update(cls, full=False):
		full = full or cls._simio_changed
		cls._simio_changed = False
		return [{
			'id':		id,
			'ord':		simio.override,
			'val':		simio.value,
			**({
				'cls':		simio.__class__.__name__,
				'name':		simio.name,
				'type':		simio.type.__name__,
				'sim':		simio.simulated,
			} if full else {})
		} for id,simio in cls._simio.items()]

	def on_open(self):
		self.write_update(True)

	def on_message_json(self, msg):
		self._simio[int(msg['id'])].set_override(msg['ord'])
		self.all.write_update()


@app.context
async def exec():
	with default_io_group.open():
		async with _web_placeholder.handle(_WebHandler):
			yield
