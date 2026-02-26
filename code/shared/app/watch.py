# SPDX-FileCopyrightText: 2026 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

from __future__ import annotations
from typing import Any
from collections.abc import Callable
from collections import defaultdict
from itertools import chain
from contextlib import AbstractContextManager
from . import app
from . import web



class Watch(AbstractContextManager):

	def __init__(self, collector:Callable[[], dict[str, Any]], *, module=None, prefix=None):
		self.collector = collector
		self.module = module or '.'.join(p.strip('_') for p in collector.__module__.split('.'))
		self.prefix = prefix
		_watched[self.module].add(self)

	def close(self):
		_watched[self.module].discard(self)
		if not _watched[self.module]:
			del _watched[self.module]

	def __exit__(self, *exc):
		self.close()



_watched = defaultdict[str, set[Watch]](set)


_web_placeholder = web.placeholder('watch')

class _WebHandler(web.WebSocketHandler):

	@classmethod
	def update(cls):
		return {
			module: {
				f'{w.prefix}.{key}' if w.prefix else key: value
				for w in ws
				for key, value in w.collector().items()
			} for module, ws in _watched.items()
		}


@app.context
async def exec():
	async with _web_placeholder.handle(_WebHandler):
		yield
