# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

import web
from shared.iceoryx.pubsub import IoxListeningSubscriber
from shared.topics._watch import watch_update_pubsub, watch_update_event


web.document.imports.append('diag/watch')
web.site.show(__name__, lambda: watch_update_pubsub.dynamic_config.number_of_publishers)



@web.handler
class update(web.WebSocketHandler):

	async def update(self):
		with IoxListeningSubscriber(watch_update_pubsub, watch_update_event) as subscriber:
			while True:
				await self.write_message(
					await subscriber.poll_receive_msgpack()
				)
