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


import configparser, os, pathlib



class Conf(configparser.ConfigParser):
	
	def __init__(self, confFile, fromDict=None, section=None):
		super().__init__(strict=False)
		self.optionxform = str
		
		self.confFile = confFile
		
		if fromDict:
			if section:
				self.read_dict({section:fromDict})
			else:
				self.read_dict(fromDict)
		else:
			data = pathlib.Path(confFile).read_text(encoding='utf8')
			if not section:
				try:
					self.read_string(data)
				except configparser.MissingSectionHeaderError:
					section = os.path.splitext(os.path.basename(confFile))[0]
			if section:
				self.read_string("[{}]\n{}".format(section, data))
	
	
	def save(self, section=None):
		with open(self.confFile, 'w', encoding='utf8') as f:
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
