# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

from __future__ import annotations
from typing import Any, overload, Callable, Awaitable, Literal
from abc import ABC, abstractmethod
from contextlib import AbstractContextManager, suppress
from functools import partial
from time import monotonic
import asyncio
from shared.asyncio import Trigger



class AbstractCondition(ABC):

	@abstractmethod
	def __call__(self) -> bool:
		return False
	
	def __bool__(self) -> bool:
		return self()



class Condition(AbstractCondition):

	def __init__(self, condition: Callable[[], Any]):
		self.condition = condition

	def __call__(self):
		return bool(self.condition())



@overload
async def poll[T](
	condition: Callable[[], T | None],
	period: float | Trigger | Callable[[], Awaitable] = 0.02,
	*,
	timeout: None = None,
	abort: None = None,
	settle: float = 0
) -> T: ...

@overload
async def poll[T](
	condition: Callable[[], T | None],
	period: float | Trigger | Callable[[], Awaitable] = 0.02,
	*,
	timeout: float,
	abort: None = None,
	settle: float = 0
) -> T | None: ...

@overload
async def poll[T](
	condition: Callable[[], T | None],
	period: float | Trigger | Callable[[], Awaitable] = 0.02,
	*,
	timeout: None = None,
	abort: Callable[[], Any],
	settle: float = 0
) -> T | Literal[False]: ...

@overload
async def poll[T](
	condition: Callable[[], T | None],
	period: float | Trigger | Callable[[], Awaitable] = 0.02,
	*,
	timeout: float,
	abort: Callable[[], Any],
	settle: float = 0
) -> T | Literal[False] | None: ...

async def poll[T](
	condition: Callable[[], T | None],
	period: float | Trigger | Callable[[], Awaitable] = 0.02,
	*,
	timeout: float | None = None,
	abort: Callable[[], Any] | None = None,
	settle: float = 0
):
	"""
	Periodically polls a condition until it becomes true, times out, or is aborted.

	Args:
		condition: Callable evaluated each iteration. Polling continues until it returns a truthy value.
		period: Time to wait between condition checks. Can be:
			- float/int: Sleep interval in seconds
			- Trigger: Event-driven trigger to wait for
			- Callable[[], Coroutine]: Custom async wait function
		timeout: Maximum time in seconds to poll. None means no timeout (poll indefinitely).
		abort: Optional callable that when returns truthy, aborts the polling.
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



class Timer(AbstractCondition, AbstractContextManager):

	def __init__(self, timeout:float, reset=True):
		self.timeout = timeout
		if reset:
			self.reset()
		else:
			self.clear()

	def reset(self):
		self.expire = monotonic() + self.timeout

	def clear(self):
		self.expire = 0

	def __enter__(self):
		self.reset()

	def __exit__(self, *exc):
		self.clear()

	def left(self):
		return max(0, self.expire - monotonic())

	async def wait(self):
		while left := self.left():
			await asyncio.sleep(left)

	def __call__(self):
		return monotonic() < self.expire	#always return False if timeout==0


class Timeout(Timer):

	def __call__(self):
		return monotonic() >= self.expire	#always return True if timeout==0



class Pulse(AbstractCondition):

	def __init__(self, hertz:float = 1):
		self.period = 1 / hertz
		self.switch = self.period / 2

	def __call__(self):
		return (monotonic() % self.period) < self.switch
