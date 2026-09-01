# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

import sys
from importlib import import_module
from asyncio import Event
from shared.asyncio import asyncio_run
from shared import tornado
import web



import_module(sys.argv[-1])


async def main():

	server = web.server()
	server.add_socket(tornado.systemd_socket(3))

	await Event().wait()


asyncio_run(main())
