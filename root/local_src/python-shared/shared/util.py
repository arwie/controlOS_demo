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
	from typing import TypeVar
	T = TypeVar('T')

from pathlib import Path
import time
from dataclasses import dataclass



def all_in_package(__file__):
	return [m.stem for m in Path(__file__).parent.glob('*.py') if not m.match('__*__.py')]


def singleinstance(cls:type[T]) -> T:
	return cls()


class CycleDiff:

	@dataclass
	class Diff:
		value: float
		time: float

		def velocity(self):
			return self.value / self.time

		def rising_edge(self):
			return self.value > 0


	def __init__(self, value_update) -> None:
		self.value_update = value_update
		self.last_value = self.value_update()
		self.last_time = time.monotonic()

	def __call__(self):
		value = self.value_update()
		time_ = time.monotonic()
		diff = self.Diff(value - self.last_value, time_ - self.last_time)
		self.last_value = value
		self.last_time = time_
		return diff