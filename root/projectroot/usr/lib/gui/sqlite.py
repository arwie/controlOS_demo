# Copyright (c) 2018 Artur Wiebe <artur@4wiebe.de>
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


import server



class TableHandler(server.RequestHandler):
	def initialize(self, sqlite, tableName, doGet={}, doPost={}):
		self.table = sqlite.table(tableName)
		self.db    = sqlite.db
		self.doGet = {**{
			'list':		self.doList,
			'load':		self.doLoad,
		}, **doGet}
		self.doPost = {**{
			'create':	self.doCreate,
			'remove':	self.doRemove,
			'save':		self.doSave,
		}, **doPost}
	
	def get(self):
		result = self.doGet[self.get_query_argument('do', 'list')]()
		if result is not None:
			self.writeJson(result)
	
	def post(self):
		with self.table.db:
			self.doPost[self.get_query_argument('do')]()
	
	
	def doList(self):
		return self.table.list()
	
	def doLoad(self):
		return self.table.load(self.get_query_argument('id'))
	
	
	def doCreate(self):
		self.table.create()
	
	def doRemove(self):
		self.table.remove(self.get_query_argument('id'))
	
	def doSave(self):
		return self.table.save(self.get_query_argument('id'), self.readJson())
