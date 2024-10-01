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


import logging
import os
import sys
import re
from pathlib import Path
from io import StringIO
from traceback import TracebackException
from systemd import journal

from logging import DEBUG, INFO, WARNING, ERROR, CRITICAL
from logging import debug, info, warning, error, critical, exception

NOTICE = 25
def notice(msg, *args, **kwargs):
	logging.log(NOTICE, msg, *args, stacklevel=2, **kwargs)


sys.excepthook = lambda type, value, tb: error(value, exc_info=(type, value, tb))
logging.captureWarnings(True)

logging.root.setLevel(DEBUG)

term = 'TERM' in os.environ
if term:
	logging.root.addHandler(logging.StreamHandler())


#use custom formatter to increase max_group_depth
class JournalFormatter(logging.Formatter):
	def formatException(self, ei):
		assert ei[0] and ei[1]
		te = TracebackException(ei[0], ei[1], ei[2], compact=True, max_group_depth=100)
		sio = StringIO()
		te.print(file=sio, chain=True)
		s = sio.getvalue()
		sio.close()
		if s[-1:] == "\n":
			s = s[:-1]
		return s


class JournalHandler(logging.Handler):
	ident_pattern = re.compile(r'[A-Z_0-9]*')
	syslog_identifier = Path(sys.argv[0]).stem

	def __init__(self):
		super().__init__()
		self.setFormatter(JournalFormatter())

	@staticmethod
	def map_priority(levelno):
		if levelno <= DEBUG:
			return 7
		elif levelno <= INFO:
			return 6
		elif levelno <= NOTICE:
			return 5
		elif levelno <= WARNING:
			return 4
		elif levelno <= ERROR:
			return 3
		elif levelno <= CRITICAL:
			return 2
		else:
			return 1

	def emit(self, record):
		try:
			self.format(record)
			sendv = [f'{k}={v}' for k,v in record.__dict__.items() if re.fullmatch(self.ident_pattern, k)]
			if record.exc_text:
				sendv.append(f'EXCEPTION={record.exc_text}')
			if record.stack_info:
				sendv.append(f'STACK={record.stack_info}')
#			added in Python 3.12
#			if record.taskName:
#				sendv.append(f'TASK={record.taskName}')
			journal.sendv(
				f'MESSAGE={record.message}',
				f'SYSLOG_IDENTIFIER={self.syslog_identifier}',
				f'PRIORITY={self.map_priority(record.levelno)}',
				f'THREAD={record.threadName}',
				f'PROCESS={record.processName}',
				f'MODULE={record.module}',
				f'LOGGER={record.name}',
				f'CODE_FILE={record.pathname}',
				f'CODE_LINE={record.lineno}',
				f'CODE_FUNC={record.funcName}',
				*sendv
			)
		except Exception:
			self.handleError(record)


logging.root.addHandler(JournalHandler())
