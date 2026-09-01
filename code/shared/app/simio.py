# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

from __future__ import annotations
from typing import get_type_hints, overload, Any, Callable, Coroutine
from contextlib import AbstractContextManager, closing, suppress
from configparser import ConfigParser
from asyncio import sleep, iscoroutinefunction
from shared import system
from . import app
from .watch import Watch
from shared.asyncio import AuxTaskGroup, aux_task
from shared.iceoryx.pubsub import IoxPublisher, IoxNotifyingPublisher, IoxListeningSubscriber
from shared.topics._simio import simio_details_pubsub, simio_update_pubsub, simio_update_event, simio_cmd_pubsub, simio_cmd_event



_conf = ConfigParser()
_conf.read('/etc/app/simio.conf')
_virtual = system.virtual()



class _IOBase[T:(bool, int, float, str)]:
	cls: str
	value: T
	_io_sim: Callable

	def __init__(self, io:Callable, *, module=None, prefix=None, simulated=False):
		self.module = '.'.join(p.strip('_') for p in (module or io.__module__).split('.'))
		self.name   = '.'.join(p.strip('_') for p in (prefix, io.__name__) if p)
		self.type:type[T] = next(iter(get_type_hints(io).values()))
		self.override = None
		self.simulated = simulated or _conf.getboolean(
			self.module, self.name,
			fallback=_conf.getboolean(
				self.module, self.__class__.__name__,
				fallback=_conf.getboolean(
					'app', self.__class__.__name__,
					fallback=_virtual
				)
			)
		)

	def set_override(self, override):
		self.override = None if override is None else self.type(override)

	def open(self):
		add_simio(self)
		self._watch = Watch(lambda: { self.name: self.value }, module=self.module)
		return closing(self)

	def close(self):
		self._watch.close()
		remove_simio(self)

	async def sync(self):
		pass

	@aux_task
	async def sync_loop(self, period:float):
		while True:
			await self.sync()
			await sleep(period)



class Input[T:(bool, int, float, str)](_IOBase[T]):
	"""Readable IO point. Returns sim value when simulated, hardware value otherwise."""
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
	"""Input that reads hardware asynchronously via periodic sync."""
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
	"""Writable IO point. Resets to default on context manager exit."""
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
	"""Output that writes to hardware asynchronously via periodic sync."""
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
	"""Groups related I/O points under a common module and/or prefix."""

	def __init__(self, *, module: str | None = None, prefix: str | None = None):
		self.module = module
		self.prefix = prefix
		self._simio = list[_IOBase]()

	def __exit__(self, *exc):
		"""Reset all output members to their defaults."""
		for simio in self._simio:
			if isinstance(simio, AbstractContextManager):
				simio.__exit__(*exc)


	@property
	def simulated(self):
		"""True when all contained I/O points are simulated."""
		return all(simio.simulated for simio in self._simio)


	async def sync(self):
		"""Sync all async I/O points in the group."""
		for simio in self._simio:
			await simio.sync()

	@aux_task
	async def sync_loop(self, period:float):
		"""Run sync() in a periodic background loop."""
		while True:
			await self.sync()
			await sleep(period)


	def open(self):
		"""Register all I/O points for monitoring in the Studio UI."""
		for simio in self._simio:
			simio.open()
		return closing(self)

	def close(self):
		"""Unregister all I/O points from the Studio UI."""
		for simio in self._simio:
			simio.close()


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
		...
	@overload
	def input[T:(bool, int, float, str)](
		self,
		*,
		prefix: str | None = None,
		sim: T | Callable[[], T] | None = None,
		simulated = False,
	) -> Callable[[Callable[[], T | Coroutine[Any, Any, T]]], Input[T]]:
		...

	def input(self, io=None, **kwargs):
		"""Decorator that registers a function as an Input in this group."""
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
		...
	@overload
	def output[T:(bool, int, float, str)](
		self,
		*,
		prefix: str | None = None,
		simulated = False,
	) -> Callable[[Callable[[T], None | Coroutine[Any, Any, None]]], Output[T]]:
		...

	def output(self, io=None, **kwargs):
		"""Decorator that registers a function as an Output in this group."""
		if io is None: #decorator with kwargs
			return lambda io, /: self.output(io, **kwargs)
		self._decorator_kwargs_defaults(kwargs)
		simio = AsyncOutput(io, **kwargs) if iscoroutinefunction(io) else Output(io, **kwargs)
		self._simio.append(simio)
		return simio



default_io_group = IoGroup()
input  = default_io_group.input
output = default_io_group.output



_simio = dict[str, _IOBase]()
_simio_changed = False

def add_simio(simio:_IOBase):
	global _simio, _simio_changed
	_simio[str(id(simio))] = simio
	_simio_changed = True

def remove_simio(simio:_IOBase):
	global _simio, _simio_changed
	with suppress(Exception):
		del _simio[str(id(simio))]
		_simio_changed = True


@app.context
async def exec():
	with (
		default_io_group.open(),
		IoxPublisher(simio_details_pubsub) as details_publisher,
		IoxNotifyingPublisher(simio_update_pubsub, simio_update_event) as update_publisher,
	):

		def update():
			global _simio, _simio_changed
			if _simio_changed:
				_simio_changed = False
				details_publisher.send_msgpack([
					{
						'id':		id,
						'cls':		simio.cls,
						'module':	simio.module,
						'name':		simio.name,
						'type':		simio.type.__name__,
						'sim':		simio.simulated,
					} for id, simio in _simio.items()
				])
			update_publisher.send_msgpack({
				id: {
					'ord':		simio.override,
					'val':		simio.value,
				} for id, simio in _simio.items()
			})

		async with AuxTaskGroup() as task_group:

			@task_group
			async def update_task():
				while True:
					update()
					await sleep(0.2 if simio_update_pubsub.dynamic_config.number_of_subscribers else 1)

			@task_group
			async def cmd_task():
				global _simio, _simio_changed
				with IoxListeningSubscriber(simio_cmd_pubsub, simio_cmd_event) as cmd_subscriber:
					while True:
						msg = await cmd_subscriber.poll_receive_msgpack()
						_simio[msg['id']].set_override(msg['ord'])
						update()

			yield
