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
from shared import system


def prg(t, d):
	return 'program\n{} "{}"\nend program\n'.format(t, d.strip()).encode()


class Handler(server.RequestHandler):
	
	def post(self):
		license = self.readJson()
		system.run(['ssh', 'mc', 'cat > /FFS0/SN'],  input=prg('sn',  license['sn']))
		system.run(['ssh', 'mc', 'cat > /FFS0/UAC'], input=prg('uac', license['uac']))
		system.run(['ssh', 'mc', 'sudo reboot'])


server.addAjax(__name__, Handler)
