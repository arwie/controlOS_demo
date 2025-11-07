# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

import logging
import os
import sys
from pathlib import Path
from io import StringIO
from traceback import TracebackException
from systemd.journal import sendv
from typing import TYPE_CHECKING



from logging import DEBUG, INFO, WARNING, ERROR, CRITICAL

NOTICE = 25

if TYPE_CHECKING:
	def getLogger(name:str):
		return JournalLogger(name)
else:
	from logging import getLogger


term = 'TERM' in os.environ



class JournalLogger(logging.Logger):

	def _log(self, *args, exc_info=None, extra=None, stack_info=False, stacklevel=1, **kwargs):
		if kwargs:
			if extra is None:
				extra = {}
			extra['_journal_'] = kwargs
		super()._log(*args, exc_info=exc_info, extra=extra, stack_info=stack_info, stacklevel=stacklevel+1)

	def notice(self, msg, *args, **kwargs):
		if self.isEnabledFor(NOTICE):
			self._log(NOTICE, msg, args, **kwargs)

	if TYPE_CHECKING:
		def debug(self, msg, *args, **kwargs): pass
		def info(self, msg, *args, **kwargs): pass
		def warning(self, msg, *args, **kwargs): pass
		def error(self, msg, *args, **kwargs): pass
		def critical(self, msg, *args, **kwargs): pass
		def exception(self, msg, *args, exc_info=True, **kwargs): pass



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
			journal = [f'{k}={v}' for k,v in record.__dict__.get('_journal_', {}).items()]
			if record.exc_text:
				journal.append(f'EXCEPTION={record.exc_text}')
			if record.stack_info:
				journal.append(f'STACK={record.stack_info}')
			if record.taskName:
				journal.append(f'TASK={record.taskName}')
			sendv(
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
				*journal
			)
		except Exception:
			self.handleError(record)



logging.setLoggerClass(JournalLogger)

logging.root.addHandler(JournalHandler())
if term:
	logging.root.addHandler(logging.StreamHandler())

logging.captureWarnings(True)

logging.root.setLevel(logging.DEBUG)


sys.excepthook = lambda type, value, tb: logging.error(value, exc_info=(type, value, tb))
