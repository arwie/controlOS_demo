# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

from __future__ import annotations
from typing import overload, Any
from collections.abc import Callable, Coroutine

from typing import get_type_hints
from contextlib import AbstractContextManager, closing, suppress
from configparser import ConfigParser
from asyncio import iscoroutinefunction
from shared import system
from . import app
from . import web



_conf = ConfigParser()
_conf.read('/etc/app/simio.conf')
_virtual = system.virtual()



class _IOBase[T:(bool, int, float, str)]:
	cls: str
	value: T
	_io_sim: Callable

	def __init__(self, io:Callable, *, module=None, prefix=None, simulated=False):
		io_module = '.'.join(p.strip('_') for p in (module or io.__module__).split('.'))
		io_name   = '.'.join(p.strip('_') for p in (prefix, io.__name__) if p)
		self.name = f'{io_module}: {io_name}'
		self.type:type[T] = next(iter(get_type_hints(io).values()))
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

	def set_override(self, override):
		self.override = None if override is None else self.type(override)

	def open(self):
		_WebHandler.add_simio(self)
		return closing(self)

	def close(self):
		_WebHandler.remove_simio(self)

	async def sync(self):
		pass

	@app.aux_task
	async def sync_loop(self, period:float):
		while True:
			await self.sync()
			await app.sleep(period)



class Input[T:(bool, int, float, str)](_IOBase[T]):
	cls = 'Input'
	_get: Callable[[], T]

	def __init__(self, io, *, sim: T | Callable[[], T] | None = None, **kwargs):
		super().__init__(io, **kwargs)
		self.sim = self.type() if sim is None else sim
		if not hasattr(self, '_get'):
			self._get = io

	@property
	def value(self) -> T:
		return (self.sim() if callable(self.sim) else self.sim) if self.simulated else self._get()

	def __call__(self) -> T:
		return self.value if self.override is None else self.override


class AsyncInput[T:(bool, int, float, str)](Input[T]):
	_sync: Callable[[], Coroutine[Any, Any, T]]

	def __init__(self, io, **kwargs):
		super().__init__(io, **kwargs)
		self._sync_value = self.type()
		self._sync = io

	def _get(self):
		return self._sync_value

	async def sync(self):
		if not self.simulated:
			self._sync_value = await self._sync()



class Output[T:(bool, int, float, str)](_IOBase[T], AbstractContextManager):
	cls = 'Output'
	_set: Callable[[T], None]

	def __init__(self, io, **kwargs):
		super().__init__(io, **kwargs)
		self.value = self.type()
		if not hasattr(self, '_set'):
			self._set = io

	def set_override(self, override):
		super().set_override(override)
		if not self.simulated:
			self._set(self.override if self.override is not None else self.value)

	def __call__(self, value: T | None = None):
		self.value = self.type() if value is None else self.type(value)
		if not self.simulated and self.override is None:
			self._set(self.value)
		return self

	def __exit__(self, *exc):
		self()


class AsyncOutput[T:(bool, int, float, str)](Output[T]):
	_sync: Callable[[T], Coroutine[Any, Any, None]]

	def __init__(self, io, **kwargs):
		super().__init__(io, **kwargs)
		self._sync_value = self.type()
		self._sync = io

	def _set(self, value):
		self._sync_value = value

	async def sync(self):
		if not self.simulated:
			await self._sync(self._sync_value)



class IoGroup(AbstractContextManager):

	def __init__(self, *, module: str | None = None, prefix: str | None = None):
		self.module = module
		self.prefix = prefix
		self._simio = list[_IOBase]()

	def __exit__(self, *exc):
		for simio in self._simio:
			if isinstance(simio, AbstractContextManager):
				simio.__exit__(*exc)


	@property
	def simulated(self):
		return all(simio.simulated for simio in self._simio)


	async def sync(self):
		for simio in self._simio:
			await simio.sync()

	@app.aux_task
	async def sync_loop(self, period:float):
		while True:
			await self.sync()
			await app.sleep(period)


	def open(self):
		for simio in self._simio:
			simio.open()
		_WebHandler.all.write_update()
		return closing(self)

	def close(self):
		for simio in self._simio:
			simio.close()
		_WebHandler.all.write_update()


	def _decorator_kwargs_defaults(self, kwargs:dict):
		kwargs.setdefault('module', self.module)
		kwargs.setdefault('prefix', self.prefix)


	@overload
	def input[T:(bool, int, float, str)](
		self,
		io: Callable[[], T | Coroutine[Any, Any, T]],
		*,
		prefix: str | None = None,
		sim: T | Callable[[], T] | None = None,
		simulated = False,
	) -> Input[T]:
		pass
	@overload
	def input[T:(bool, int, float, str)](
		self,
		*,
		prefix: str | None = None,
		sim: T | Callable[[], T] | None = None,
		simulated = False,
	) -> Callable[[Callable[[], T | Coroutine[Any, Any, T]]], Input[T]]:
		pass

	def input(self, io=None, **kwargs):
		if io is None: #decorator with kwargs
			return lambda io, /: self.input(io, **kwargs)
		self._decorator_kwargs_defaults(kwargs)
		simio = AsyncInput(io, **kwargs) if iscoroutinefunction(io) else Input(io, **kwargs)
		self._simio.append(simio)
		return simio


	@overload
	def output[T:(bool, int, float, str)](
		self,
		io: Callable[[T], None | Coroutine[Any, Any, None]],
		*,
		prefix: str | None = None,
		simulated = False,
	) -> Output[T]:
		pass
	@overload
	def output[T:(bool, int, float, str)](
		self,
		*,
		prefix: str | None = None,
		simulated = False,
	) -> Callable[[Callable[[T], None | Coroutine[Any, Any, None]]], Output[T]]:
		pass

	def output(self, io=None, **kwargs):
		if io is None: #decorator with kwargs
			return lambda io, /: self.output(io, **kwargs)
		self._decorator_kwargs_defaults(kwargs)
		simio = AsyncOutput(io, **kwargs) if iscoroutinefunction(io) else Output(io, **kwargs)
		self._simio.append(simio)
		return simio



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
		return {
			'data': {
				id: {
					'ord':		simio.override,
					'val':		simio.value,
				} for id, simio in cls._simio.items()
			},
			'list': [
				{
					'id':		id,
					'cls':		simio.cls,
					'name':		simio.name,
					'type':		simio.type.__name__,
					'sim':		simio.simulated,
				} for id, simio in cls._simio.items()
			] if full else None,
		}

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
