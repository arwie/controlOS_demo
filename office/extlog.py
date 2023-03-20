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


import server, tempfile
from shared import system
from pathlib import Path


extlogDir = tempfile.TemporaryDirectory(prefix='office.', suffix='.extlog', dir='/var/tmp')

import log
log.cmd = ['journalctl', '--file={}/*'.format(extlogDir.name)]



class Handler(server.RequestHandler):
	
	def clearJournal(self):
		for f in Path(extlogDir.name).glob('*'):
			f.unlink()
	
	def importJournal(self):
		self.clearJournal()
		system.run(
			'set -o pipefail; xzcat | /lib/systemd/systemd-journal-remote --output={}/extlog.journal -'.format(extlogDir.name),
			input=self.request.files['extlog'][0]['body']
		)
	
	async def put(self):
		await server.run_in_executor(self.importJournal)
	
	def post(self):
		self.clearJournal()



server.addAjax(__name__, Handler)
