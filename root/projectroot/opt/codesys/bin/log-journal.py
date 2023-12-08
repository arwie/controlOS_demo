#!/usr/bin/python -Bu

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

import os
import re
from systemd import daemon
from shared import log


master, slave = os.openpty()
os.symlink(os.ttyname(slave), '/run/codesys-log/tty')
daemon.notify('READY=1')


def send(priority:int, message:str, *args):
	log.journal.sendv(
		'SYSLOG_IDENTIFIER=codesys',
		f'PRIORITY={priority}',
		f'MESSAGE={message}',
		*args
	)

def prio(prio_class):
	match prio_class:
		case '1': return 6 #Info
		case '2': return 4 #Warning
		case '4': return 3 #Error
		case '8': return 2 #Critical
		case _:   return 7 #Debug


pattern = re.compile(r'Cmp=(.*), Class=(.*), Error=(.*), Info=(.*), pszInfo=(.*)')

with os.fdopen(master, 'rb') as input:
	for line in input:
		try:
			line = line.decode().strip()
			if match := pattern.search(line):
				send(
					prio(match.group(2)),
					match.group(5).strip(),
					f'CMP={match.group(1)}',
					f'ERROR={match.group(3)}',
					f'INFO={match.group(4)}',
				)
			else:
				if line and not line.startswith('_/'):
					send(6, line)
		except Exception:
			log.exception(line)