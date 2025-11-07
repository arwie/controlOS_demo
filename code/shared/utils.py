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
	from collections.abc import Callable
	from typing import TypeVar
	T = TypeVar('T')

from pathlib import Path
from importlib import import_module
from time import monotonic



def import_all_in_package(init_file:str, init_module:str):
	"""
	Dynamically imports all python files from a package which names do not start with '_'.
	
	Call from __init__.py of the package:
	import_all_in_package(__file__, __name__)
	"""
	return set(
		import_module('.'.join((init_module, module_file.stem)))
			for module_file in Path(init_file).parent.glob('*.py*') if not module_file.match('_*')
	)


def instantiate(cls:type[T]) -> T:
	return cls()


class SignalDiff:
	def __init__(self, signal:Callable[[]]):
		self.signal = signal
		self.value = self.signal()
		self.time = monotonic()

	def __call__(self):
		self.past_value, self.past_time = self.value, self.time
		self.value = self.signal()
		self.time = monotonic()
		return self

	def diff(self):
		return self.value - self.past_value

	def rising_edge(self):
		return (self.value - self.past_value) > 0

	def falling_edge(self):
		return (self.value - self.past_value) < 0

	def velocity(self):
		return (self.value - self.past_value) / (self.time - self.past_time)
