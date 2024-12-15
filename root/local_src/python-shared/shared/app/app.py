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
from typing import overload, Any
from collections.abc import Callable, Coroutine, AsyncGenerator
from contextlib import AbstractAsyncContextManager
import asyncio
import inspect
from functools import partial
from contextlib import AbstractContextManager, asynccontextmanager
from shared import system
from shared.utils import instantiate
from shared.condition import Timeout, Condition


from shared import log
from time import monotonic as clock



poll_period = 1 / 50


def sleep(delay:float = poll_period):
	return asyncio.sleep(delay)



class Trigger:
	def __init__(self):
		self._event = asyncio.Event()

	def __call__(self):
		self._event.set()
		self._event.clear()

	def wait(self):
		return self._event.wait()



async def poll(
	condition: Callable[[], Any],
	*,
	timeout: float | Timeout | None = None,
	abort: Callable[[], Any] | None = None,
	period: float | Trigger | Callable[[], Coroutine] = poll_period,
	settle: float | Timeout = 0
):

	if callable(abort):
		abort = Condition(abort)

	if isinstance(timeout, (float, int)):
		timeout = Timeout(timeout)

	if isinstance(period, (float, int)):
		period = partial(asyncio.sleep, period)
	elif isinstance(period, Trigger):
		period = period.wait

	if isinstance(settle, (float, int)):
		settle = Timeout(settle)

	while True:
		if abort: #check abort before condition
			return False

		if result := condition():
			if settle:
				return result
		else:
			settle.reset()

		if timeout:
			return False
		await period()



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


@overload
#def context[T, **P](func:Callable[P, AsyncGenerator[T, Any]]) -> Callable[P, AbstractAsyncContextManager[T]]: pass
def context(func:Callable[..., AsyncGenerator]) -> Callable[..., AbstractAsyncContextManager]: pass

@overload
#def context[T, **P](func:Callable[P, Coroutine[Any, Any, T]]) -> Callable[P, Coroutine[Any, Any, T]]: pass
def context(func:Callable[..., Coroutine]) -> Callable[..., Coroutine]: pass

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



class task_group(asyncio.TaskGroup):

	def __init__(self, *coros: Coroutine[Any, Any, None] | Callable[[], Coroutine[Any, Any, None]]):
		super().__init__()
		self._coros = coros

	async def __aenter__(self):
		await super().__aenter__()
		for coro in self._coros:
			self(coro)
		del self._coros
		return self

	def __call__(self, coro: Coroutine[Any, Any, None] | Callable[[], Coroutine[Any, Any, None]], **kwargs):
		return self.create_task(coro() if callable(coro) else coro, **kwargs)

	async def __aexit__(self, et, exc, tb):
		if not self._aborting:	#type:ignore
			self._abort()		#type:ignore
		try:
			return await super().__aexit__(et, exc, tb)
		except BaseExceptionGroup as eg:
			if eg.exceptions[0] is not exc or len(eg.exceptions) > 1:
				raise



@asynccontextmanager
async def target(target:str):
	def systemctl(cmd):
		return run_in_executor(system.run, ['systemctl', cmd, f'app@{target}.target'])

	await systemctl('start')
	try:
		yield
	finally:
		await systemctl('stop')




def task_cancelling():
	return (task := asyncio.current_task()) and task.cancelling()


@instantiate
class raise_cancelling(AbstractContextManager):
	def __exit__(self, exc_type, exc_value, traceback):
		if exc_type and exc_type is not asyncio.CancelledError:
			if task_cancelling():
				log.error('error in cleanup logic of cancelling asyncio task', exc_info=(exc_type, exc_value, traceback))
				raise asyncio.CancelledError

	def __call__(self):
		if task_cancelling():
			raise asyncio.CancelledError



def context_select_loop(switch: Callable[[], Any], **kwargs) -> Callable[[Callable[[Any], AsyncGenerator]], Callable[[], Coroutine]]:
	def decorator(select_gen):
		select = asynccontextmanager(select_gen)
		async def select_loop():
			while True:
				value = switch()
				async with select(value):
					await poll(lambda: switch() != value, **kwargs)
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



class CommandRunner:

	def __init__(self, handler: Callable[[int, Any], Coroutine]):
		self.handler = handler

	async def run(self):
		while True:
			self.cancelled = False
			self.future = asyncio.Future[tuple[int, Any]]()
			cmd, data = await self.future
			try:
				with raise_cancelling:
					await self.handler(cmd, data)
			except Exception as e:
				log.exception(e)

	def busy(self):
		return self.future.result()[0] if self.future.done() else 0

	def __call__(self, cmd:int, data:Any=None):
		if not self.future.done():
			self.future.set_result((cmd, data))
		else:
			self.cancelled = True
