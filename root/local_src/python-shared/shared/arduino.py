# Copyright (c) 2020 Artur Wiebe <artur@4wiebe.de>
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


import subprocess, pathlib, json, tempfile, logging


def insertSyswlanLogin(binary):
	login = {
		'bssid':	[int(h,16) for h in pathlib.Path('/sys/class/net/syswlan/address').read_text().strip().split(':')],
		'psk':		pathlib.Path('/etc/hostapd/hostapd.wpa_psk').read_text().strip().split()[1]
	}
	login = json.dumps(login, separators=(',',':')).encode() + b'\0'
	return binary.replace(b'W'*len(login), login, 1)


def update(binfile, syswlan=True):
	binary = pathlib.Path(binfile).read_bytes()
	if syswlan:
		binary = insertSyswlanLogin(binary)
	return binary


def upload(binary):
	with tempfile.NamedTemporaryFile() as binfile:
		binfile.write(binary)
		try:
			subprocess.run(['bossac', '-aewvRU', '--offset=0x2000', binfile.name], stderr=subprocess.PIPE, check=True, text=True)
		except subprocess.CalledProcessError as e:
			raise Exception(e.stderr) from e
