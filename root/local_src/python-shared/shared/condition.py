# Copyright (c) 2024 Artur Wiebe <artur@4wiebe.de>
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
	from typing import Any
	from collections.abc import Callable

from abc import ABC, abstractmethod
from contextlib import AbstractContextManager
from time import monotonic



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

	def __call__(self):
		return monotonic() < self.expire	#always return False if timeout==0


class Timeout(Timer):

	def __call__(self):
		return monotonic() >= self.expire	#always return True if timeout==0
