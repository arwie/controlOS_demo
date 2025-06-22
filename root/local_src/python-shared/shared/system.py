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


import subprocess
from pathlib import Path



def run(cmd, capture=False, **kwargs):
	kwargs.setdefault('check', True)
	kwargs.setdefault('stderr', subprocess.PIPE)
	if capture:
		kwargs['stdout'] = subprocess.PIPE
	try:
		proc = subprocess.run(cmd, shell=isinstance(cmd, str), **kwargs)
		return proc.stdout if capture else proc
	except subprocess.CalledProcessError as e:
		errorText = e.stderr if (e.stderr or capture or not e.stdout) else e.stdout
		if isinstance(errorText, bytes):
			errorText = errorText.decode()
		raise Exception(errorText) from e


def status_text(unit:str) -> str:
	return run(['systemctl', '--no-pager', '--full', 'status', unit], True, text=True, check=False)

def restart(unit):
	run(['systemctl', '--no-block', 'restart', unit])

def stop(unit):
	run(['systemctl', '--no-block', 'stop', unit])


def reboot(kexec=True):
	run(['reboot-kexec' if kexec else 'reboot'])

def poweroff():
	run(['poweroff'])


def virtual():
	"""
	Returns True if the system is running inside a virtual environment
	"""
	return 'hypervisor' in Path('/proc/cpuinfo').read_text()
