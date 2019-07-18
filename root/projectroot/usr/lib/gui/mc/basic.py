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
import subprocess, shlex



class Handler(server.RequestHandler):
	
	async def get(self):
		
		def listFiles():
			lists = subprocess.run(['ssh', 'mc', 'cd /FFS0/SSMC && ls -1 *.LIB && echo "###" && ls -1 *.PRG && echo "###" && ls -1 *.DAT'], stdout=subprocess.PIPE).stdout.decode().split('###')
			return [l.split() for l in lists]
		
		def loadFile(filename):
			return subprocess.run(['ssh', 'mc', 'cd /FFS0/SSMC && cat {}'.format(shlex.quote(filename))], stdout=subprocess.PIPE, stderr=subprocess.STDOUT).stdout
		
		filename = self.get_query_argument('file', False)
		if filename:
			code = await server.run_in_executor(loadFile, filename)
			self.write(code)
		else:
			files = await server.run_in_executor(listFiles)
			self.writeJson(files)


server.addAjax(__name__, Handler)
