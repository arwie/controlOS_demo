# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

from __future__ import annotations
from collections.abc import Coroutine
from shared.asyncio import asyncio_run

from .app import *
from .watch import Watch
from .simio import input, output, IoGroup


def run(app_main: Coroutine):

	async def _main():
		async with (
			watch.exec(),
			simio.exec(),
		):
			await app_main

	asyncio_run(_main())
