# SPDX-FileCopyrightText: 2026 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

from __future__ import annotations
from typing import Any
from collections.abc import Callable
from collections import defaultdict
from contextlib import AbstractContextManager
from asyncio import sleep
from shared.asyncio import AuxTaskGroup
from shared.iceoryx.pubsub import IoxNotifyingPublisher
from shared.topics._watch import watch_update_pubsub, watch_update_event
from . import app



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



@app.context
async def exec():
	async with AuxTaskGroup() as task_group:

		@task_group
		async def update():
			with IoxNotifyingPublisher(watch_update_pubsub, watch_update_event) as publischer:
				while True:
					publischer.send_msgpack({
						module: {
							f'{w.prefix}.{key}' if w.prefix else key: value
							for w in ws
							for key, value in w.collector().items()
						} for module, ws in _watched.items()
					})
					await sleep(0.2 if watch_update_pubsub.dynamic_config.number_of_subscribers else 1)

		yield
