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



def run(main:Callable[[], AbstractAsyncContextManager]):
	async def app_main():
		exit_event = asyncio.Event()

		for sig in (signal.SIGINT, signal.SIGTERM):
			asyncio.get_running_loop().add_signal_handler(sig, exit_event.set)

		async with (
			web.server(),
			simio.exec(),
		):
			async with main():
				await exit_event.wait()
				log.warning('Received INT/TERM signal -> app is going to exit...')

	asyncio.run(app_main())
	exit(0)
