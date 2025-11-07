#!/usr/bin/python -Bu

# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

import os
import re
from systemd import daemon, journal
from shared import log


master, slave = os.openpty()
os.symlink(os.ttyname(slave), '/run/codesys-log/tty')
daemon.notify('READY=1')


def send(priority:int, message:str, *args):
	journal.sendv(
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
			log.exception('Failed to log codesys stdout line', LINE=line)
