# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

from __future__ import annotations
from typing import overload, Any
from collections.abc import Callable, Coroutine, AsyncGenerator
from contextlib import AbstractAsyncContextManager, asynccontextmanager
import asyncio
import inspect
from shared.condition import poll


from shared import log
from time import monotonic as clock



poll_period = 1 / 50


def sleep(delay:float = poll_period):
	return asyncio.sleep(delay)


@asynccontextmanager
async def _context(func):
	name = f"{str(func.__module__).strip('_')}.{func.__name__}"
	log.info(f'Context {name} starting')
	try:
		yield
	finally:
		log.info(f'Context {name} stopped')


@overload
def context[T, **P](func:Callable[P, AsyncGenerator[T, Any]]) -> Callable[P, AbstractAsyncContextManager[T]]: pass
@overload
def context[T, **P](func:Callable[P, Coroutine[Any, Any, T]]) -> Callable[P, Coroutine[Any, Any, T]]: pass

def context(func): #type:ignore
	if inspect.isasyncgenfunction(func):
		ctx = asynccontextmanager(func)
		async def wrapper_ctx(*args, **kwargs):
			async with _context(func):
				async with ctx(*args, **kwargs) as y:
					yield y
		return asynccontextmanager(wrapper_ctx)
	else:
		async def wrapper_func(*args, **kwargs):
			async with _context(func):
				return await func(*args, **kwargs)
		return wrapper_func



def context_select_loop(switch: Callable[[], Any], **kwargs) -> Callable[[Callable[..., AsyncGenerator]], Callable[[], Coroutine]]:
	"""
	Creates a state machine loop that monitors a switch function and manages async context lifecycles.

	The decorator operates in two modes based on whether the decorated function accepts parameters:

	**Parameterized mode** (function has parameters):
	Enters context with the current switch value and stays active until the value changes.
	The decorated function receives the switch value as a parameter.

	**Boolean mode** (function has no parameters):
	Waits for switch to become truthy, enters context, then waits for switch to become falsy.

	Args:
		switch: A callable that returns the current state value to monitor.
		**kwargs: Options passed to poll() (period, settle).

	Returns:
		A decorator that transforms an async generator into a coroutine loop.

	Examples:
		@context_select_loop(lambda: current_mode)
		async def handle_mode(mode):
			# Receives mode value, stays active until mode changes
			match mode:
				case "manual":
					async with manual_mode():
						yield
				case "auto":
					async with auto_mode():
						yield
				case _:
					yield

		@context_select_loop(is_active)
		async def active_handler():
			# Enters when is_active() is True, exits when False
			async with activate():
				yield
	"""

	def decorator(select_gen):
		select = asynccontextmanager(select_gen)

		if inspect.signature(select_gen).parameters:
			async def select_loop():
				while True:
					value = switch()
					async with select(value):
						await poll(lambda: switch() != value, **kwargs)
		else:
			async def select_loop():
				while True:
					await poll(switch, **kwargs)
					async with select():
						await poll(lambda: not switch(), **kwargs)

		return select_loop

	return decorator



class disableable:
	def __init__(self, func: Callable[..., Coroutine]):
		self._func = func
		self.lock = asyncio.Lock()
		self.disabled = 0

	@asynccontextmanager
	async def disable(self):
		async with self.lock:
			self.disabled += 1
		try:
			yield
		finally:
			self.disabled -= 1

	async def __call__(self, *args, **kwargs):
		async with self.lock:
			if not self.disabled:
				return await self._func(*args, **kwargs)
