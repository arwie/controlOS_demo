# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

from __future__ import annotations
from typing import overload, Any
from collections.abc import Callable, Coroutine, AsyncGenerator
from contextlib import AbstractAsyncContextManager, suppress
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
	timeout: float | None = None,
	abort: Callable[[], Any] | None = None,
	period: float | Trigger | Callable[[], Coroutine] = poll_period,
	settle: float = 0
):
	"""
	Periodically polls a condition until it becomes true, times out, or is aborted.

	Args:
		condition: Callable evaluated each iteration. Polling continues until it returns a truthy value.
		timeout: Maximum time in seconds to poll. None means no timeout (poll indefinitely).
		abort: Optional callable that when returns truthy, aborts the polling.
		period: Time to wait between condition checks. Can be:
			- float/int: Sleep interval in seconds
			- Trigger: Event-driven trigger to wait for
			- Callable[[], Coroutine]: Custom async wait function
		settle: Duration in seconds the condition must remain continuously True before returning.
			If condition becomes False during this period, the settle timer resets.

	Returns:
		- The truthy result from condition() when it has been True for the settle duration
		- False when the abort condition becomes True
		- None when the timeout expires
	"""

	if callable(abort):
		abort = Condition(abort)

	if isinstance(period, (float, int)):
		period = partial(asyncio.sleep, period)
	elif isinstance(period, Trigger):
		period = period.wait

	settle_timeout = Timeout(settle)

	with suppress(TimeoutError):
		async with asyncio.timeout(timeout):
			while not abort:
				if result := condition():
					if settle_timeout:
						return result
				else:
					settle_timeout.reset()
				await period()
			return False


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



class AuxTaskGroup(asyncio.TaskGroup):
	"""TaskGroup that cancels all tasks on exit.

	Unlike asyncio.TaskGroup which waits for tasks to complete on normal exit,
	AuxTaskGroup always cancels all tasks when exiting the context, regardless
	of whether an exception occurred.

	Intended for background/supervisory tasks that should only run while the main
	work is active (e.g., monitoring, heartbeats, logging).

	Example:
		async with AuxTaskGroup() as tg:
			tg(monitor_health)
			tg(log_metrics)
			await main_work()
		# monitor_health and log_metrics are cancelled here
	"""

	def __call__(self, coro: Coroutine[Any, Any, None] | Callable[[], Coroutine[Any, Any, None]], **kwargs):
		if callable(coro):
			coro = coro()
		return self.create_task(coro, name=coro.__qualname__, **kwargs)

	async def __aexit__(self, et, exc, tb):
		if not self._aborting:	#type:ignore
			self._abort()		#type:ignore
		try:
			return await super().__aexit__(et, exc, tb)
		except BaseExceptionGroup as eg:
			if eg.exceptions[0] is not exc or len(eg.exceptions) > 1:
				raise


def aux_task(coro_function:Callable[..., Coroutine[Any, Any, None]]):
	"""
	Decorator that transforms a coroutine function into an async context manager
	that runs the coroutine as a managed background task within an AuxTaskGroup.

	Args:
		coro_function: A coroutine function to run as a background task.
			Can accept any arguments which are passed when entering the context.

	Returns:
		An async context manager that starts the task on entry and ensures proper
		cleanup on exit via AuxTaskGroup lifecycle management.

	Example:
		@aux_task
		async def background_worker(name: str, interval: float = 1.0):
			while True:
				await asyncio.sleep(interval)
				print(f"{name}: tick")

		async with background_worker("worker-1", interval=0.5) as task:
			# background_worker is now running with the provided arguments
			await do_other_work()
			# task is cleaned up on exit
	"""

	@asynccontextmanager
	async def aux_task_asynccontextmanager(*args, **kwargs):
		async with AuxTaskGroup() as task_group:
			yield task_group(coro_function(*args, **kwargs))

	return aux_task_asynccontextmanager



@asynccontextmanager
async def target(target:str):
	def systemctl(cmd):
		return asyncio.to_thread(system.run, ['systemctl', cmd, f'app@{target}.target'])

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



class CommandExecutor:

	def __init__(self, handler: Callable[[int, dict], Coroutine]):
		self.handler = handler
		self.cancelled = True
		self.future = None


	@aux_task
	async def exec(self):
		try:
			while True:
				self.cancelled = False
				self.future = asyncio.Future[tuple[int, dict]]()
				cmd, data = await self.future
				try:
					with raise_cancelling:
						await self.handler(cmd, data)
				except Exception as e:
					log.exception(e)
		finally:
			self.future = None


	def busy(self):
		"""Returns the command number that is currently being executed"""
		return self.future.result()[0] if self.future and self.future.done() else 0


	def __call__(self, cmd:int, data:dict={}):
		"""Schedules a command to be executed"""
		if self.future and not self.future.done():
			self.future.set_result((cmd, data))
		else:
			self.cancelled = True
