# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

from __future__ import annotations
from typing import TYPE_CHECKING
if TYPE_CHECKING:
	from typing import Callable
	from contextlib import AbstractAsyncContextManager

import asyncio
import signal

from .app import *
from . import web
from . import simio
from .simio import input, output, IoGroup



def run(app_main: Coroutine[Any, Any, None] | Callable[[], Coroutine[Any, Any, None]]):

	async def main():
		exit_event = asyncio.Event()

		for sig in (signal.SIGINT, signal.SIGTERM):
			asyncio.get_running_loop().add_signal_handler(sig, exit_event.set)

		async with app.AuxTaskGroup() as task_group:

			task_group(app_main)

			async with (
				web.server(),
				simio.exec(),
			):
				await exit_event.wait()
				log.warning('Received INT/TERM signal -> app is going to exit...')

	asyncio.run(main())
	exit(0)
