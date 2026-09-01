# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

from __future__ import annotations
from typing import Any, Callable, Coroutine
from contextlib import AbstractContextManager, asynccontextmanager, suppress
import asyncio
import signal
from shared.utils import instantiate
from shared import log



asyncio_loop = asyncio.new_event_loop()


def asyncio_run(main:Coroutine):
	"""Run `main` on the prebuilt `asyncio_loop` until it completes.

	Like `asyncio.run`, but reuses the module-level event loop, so objects bound
	to it can be created before the program starts.

	SIGINT and SIGTERM cancel the main task instead of raising, giving context
	managers a chance to unwind; the resulting CancelledError is suppressed and
	`None` is returned.

	Args:
		main: The coroutine to run as the main task.

	Returns:
		The result of `main`, or `None` if it was cancelled by a signal.
	"""

	with asyncio.Runner(loop_factory=lambda: asyncio_loop):
		task = asyncio_loop.create_task(main, name=main.__qualname__)

		def shutdown():
			log.info('Received INT/TERM signal -> stopping...')
			task.cancel()

		for sig in (signal.SIGINT, signal.SIGTERM):
			asyncio_loop.add_signal_handler(sig, shutdown)

		with suppress(asyncio.CancelledError):
			return asyncio_loop.run_until_complete(task)



class Trigger:
	"""Stateless notification: `wait()` blocks until the next call.

	Equivalent to an `asyncio.Event` that is immediately cleared again after
	being set, but without the flag and its bookkeeping: waiters are futures
	that are simply resolved and dropped.
	"""

	def __init__(self):
		self._waiters = list[asyncio.Future[None]]()

	def __call__(self):
		"""Wake all tasks currently waiting."""
		for fut in self._waiters:
			if not fut.done():	# cancelled meanwhile
				fut.set_result(None)
		self._waiters.clear()

	def wait(self) -> asyncio.Future[None]:
		"""Await the returned future to block until the next call."""
		fut = asyncio_loop.create_future()
		self._waiters.append(fut)
		return fut



class AuxTaskGroup(asyncio.TaskGroup):
	"""TaskGroup that cancels all tasks on exit.

	Unlike asyncio.TaskGroup which waits for tasks to complete on normal exit,
	AuxTaskGroup always cancels all tasks when exiting the context, regardless
	of whether an exception occurred.

	Intended for background/supervisory tasks that should only run while the main
	work is active (e.g., monitoring, heartbeats, logging).

	Tasks are started either with `create_task`, which names the task after the
	coroutine, or by calling the group with a coroutine function, which makes it
	usable as a decorator on the task's `async def`.

	Example:
		async with AuxTaskGroup() as task_group:

			@task_group
			async def monitor_health():
				while True:
					...

			task_group.create_task(log_metrics(interval=1))

			await main_work()
		# monitor_health and log_metrics are cancelled here
	"""

	def create_task(self, coro:Coroutine, **kwargs):
		kwargs.setdefault('name', coro.__qualname__)
		return super().create_task(coro, **kwargs)

	def __call__(self, coro_function:Callable[[], Coroutine]):
		return self.create_task(coro_function())

	async def __aexit__(self, et, exc, tb):
		if not self._aborting:	#type:ignore
			self._abort()		#type:ignore
		try:
			return await super().__aexit__(et, exc, tb)
		except BaseExceptionGroup as eg:
			if eg.exceptions[0] is not exc or len(eg.exceptions) > 1:
				raise


def aux_task(coro_function:Callable[..., Coroutine]):
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
			yield task_group.create_task(coro_function(*args, **kwargs))

	return aux_task_asynccontextmanager



def task_cancelling():
	task = asyncio.current_task()
	return task and task.cancelling()


@instantiate
class raise_cancelling(AbstractContextManager):
	"""Guard against a cancellation being swallowed by cleanup code.

	asyncio cancellation is edge-triggered: `cancel()` throws one CancelledError
	into the task and is then done. If that exception is replaced - cleanup logic
	raising an error of its own while unwinding - or caught by a broad
	`except Exception`, the cancellation is silently lost and the task keeps
	running. This restores it, based on the still-pending `task.cancelling()`.

	Used as a context manager, an exception leaving the block while the task is
	cancelling is logged and replaced by a fresh CancelledError (the original is
	kept as its `__context__`). Called as a function, it re-raises CancelledError
	if one is pending, acting as a cancellation checkpoint in code that has
	already absorbed the original.

	Example:
		while True:
			cmd = await next_command()
			try:
				with raise_cancelling:
					await handler(cmd)	# its cleanup may raise
			except Exception as e:
				log.exception(e)	# no longer swallows the cancellation
	"""

	def __exit__(self, exc_type, exc_value, traceback):
		if exc_type and exc_type is not asyncio.CancelledError:
			if task_cancelling():
				log.error('error in cleanup logic of cancelling asyncio task', exc_info=(exc_type, exc_value, traceback))
				raise asyncio.CancelledError

	def __call__(self):
		if task_cancelling():
			raise asyncio.CancelledError
