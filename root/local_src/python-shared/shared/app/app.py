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
	from typing import overload, Any, TypeVar, ParamSpec
	from collections.abc import Callable, Coroutine, AsyncGenerator
	from contextlib import AbstractAsyncContextManager

import asyncio
import inspect
from functools import partial
from contextlib import AbstractContextManager, asynccontextmanager
from shared import system
from shared.util import singleinstance


from shared import log
from time import monotonic as clock



poll_period = 1 / 50


def sleep(delay:float = poll_period):
	return asyncio.sleep(delay)


async def poll(
	condition: Callable[[], Any],
	*,
	timeout: float | None = None,
	abort: Callable[[], Any] | None = None,
	period: float | int | Callable[[], Coroutine] = poll_period,
) -> bool:
	timeout_ = Timeout(timeout) if timeout else False
	if isinstance(period, (float, int)):
		period = partial(asyncio.sleep, period)
	while not condition():
		if timeout_ or (abort and abort()):
			return False
		await period()
	return True



class Timeout:
	def __init__(self, timeout:float):
		self._timeout = timeout
		self.reset()

	def reset(self):
		self._expire = clock() + self._timeout

	def __call__(self):
		return clock() > self._expire

	__bool__ = __call__


class Event(asyncio.Event):
	def __init__(self, set_=False):
		super().__init__()
		if set_:
			self.set()

	def trigger(self):
		if not self.is_set():
			self.set()
			self.clear()


def run_in_executor(func:Callable, *args):
	return asyncio.get_running_loop().run_in_executor(None, func, *args)



@asynccontextmanager
async def _context(func):
	name = f"{str(func.__module__).strip('_')}.{func.__name__}"
	log.info(f'Context {name} starting')
	try:
		yield
	finally:
		log.info(f'Context {name} stopped')


if TYPE_CHECKING:
	P, T = ParamSpec('P'), TypeVar('T')
	@overload
	def context(func:Callable[P, AsyncGenerator[T, Any]]) -> Callable[P, AbstractAsyncContextManager[T]]: pass
	@overload
	def context(func:Callable[P, Coroutine[Any, Any, T]]) -> Callable[P, Coroutine[Any, Any, T]]: pass

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



@asynccontextmanager
async def task_group(*coros:Coroutine[Any, Any, None]):
	async with asyncio.TaskGroup() as tg:
		for coro in coros:
			tg.create_task(coro)
		try:
			yield tg
		finally:
			tg._abort() #type:ignore


@asynccontextmanager
async def target(target:str):
	def systemctl(cmd):
		return run_in_executor(system.run, ['systemctl', '--no-block', cmd, f'app@{target}.target'])

	await systemctl('start')
	try:
		yield
	finally:
		await systemctl('stop')



@singleinstance
class raise_cancelling(AbstractContextManager):
	def __exit__(self, exc_type, exc_value, traceback):
		if exc_type and exc_type is not asyncio.CancelledError:
			if task := asyncio.current_task():
				if task.cancelling():
					log.error('error in cleanup logic of cancelling asyncio task', exc_info=(exc_type, exc_value, traceback))
					raise asyncio.CancelledError

	def __call__(self):
		if task := asyncio.current_task():
			if task.cancelling():
				raise asyncio.CancelledError
