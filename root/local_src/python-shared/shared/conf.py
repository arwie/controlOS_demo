# Copyright (c) 2017 Artur Wiebe <artur@4wiebe.de>
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

from configparser import ConfigParser, MissingSectionHeaderError
from pathlib import Path
import os



class Conf(ConfigParser):
	
	def __init__(self, confFile=None, data=None, section=None):
		super().__init__(strict=False)
		
		self.confFile = confFile
		
		if isinstance(data, dict):
			self.read_dict({section:data} if section else data)
		else:
			if data is None:
				assert confFile
				data = Path(confFile).read_text()
			if not section:
				try:
					self.read_string(data)
				except MissingSectionHeaderError:
					assert confFile
					section = os.path.splitext(os.path.basename(confFile))[0]
			if section:
				self.read_string("[{}]\n{}".format(section, data))


	def update(self, data:dict[str, dict[str, Any]]):
		for section, options in data.items():
			if not self.has_section(section):
				self.add_section(section)
			for option, value in options.items():
				self[section][option] = str(value)

	
	def save(self, section=None):
		assert self.confFile
		with open(self.confFile, 'w') as f:
			if section:
				for k,v in self.items(section):
					f.write("{}={}\n".format(k,v))
			else:
				self.write(f)
	
	
	def dict(self, section=None):
		if section:
			return dict(self.items(section))
		else:
			return {s:dict(self.items(s)) for s in self.sections()}
