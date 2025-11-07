# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

from __future__ import annotations
from typing import TYPE_CHECKING
if TYPE_CHECKING:
	from typing import Any
	from collections.abc import Callable

from abc import ABC, abstractmethod
from contextlib import AbstractContextManager
from time import monotonic
from asyncio import sleep



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
			await sleep(left)

	def __call__(self):
		return monotonic() < self.expire	#always return False if timeout==0


class Timeout(Timer):

	def __call__(self):
		return monotonic() >= self.expire	#always return True if timeout==0
