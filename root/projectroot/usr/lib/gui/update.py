# Copyright (c) 2021 Artur Wiebe <artur@4wiebe.de>
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
from pathlib import Path
from shared import system


class Handler(server.RequestHandler):
	def get(self):
		try:
			self.write(Path('/version').read_text())
		except: pass
	
	async def put(self):
		await server.run_in_executor(lambda:system.run(['update'], input=self.request.files['update'][0]['body']))


class RevertHandler(server.RequestHandler):
	def get(self):
		try:
			self.write(str(Path('/var/revert').stat().st_mtime))
		except: pass
	
	async def post(self):
		await server.run_in_executor(lambda:system.run(['update','--revert']))



server.addAjax(__name__,				Handler)
server.addAjax(__name__+'/revert',		RevertHandler)
