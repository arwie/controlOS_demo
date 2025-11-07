# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

from asyncio import to_thread
import web
from shared import network
from shared.utils import import_all_in_package



web.document.imports.append('system/network')


@web.handler
class status(web.RequestHandler):
	async def get(self):
		network_status = await to_thread(network.status)
		self.write(network_status.encode())



from . import syswlan
from . import lan
from . import wlan
from . import smtp

import_all_in_package(__file__, __name__)
