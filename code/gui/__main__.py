# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

import sys
from importlib import import_module
import asyncio
import web
from shared import tornado


import_module(sys.argv[-1])


async def main():
	asyncio.get_running_loop().set_task_factory(asyncio.eager_task_factory)

	server = web.server()
	server.add_socket(tornado.systemd_socket(3))

	await asyncio.Event().wait()


asyncio.run(main())
