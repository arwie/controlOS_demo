# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

import web
from shared.iceoryx.pubsub import IoxNotifyingPublisher, IoxSubscriber, IoxListeningSubscriber, poll
from shared.topics._simio import simio_details_pubsub, simio_update_pubsub, simio_update_event, simio_cmd_pubsub, simio_cmd_event


web.document.imports.append('studio/simio')
web.site.show(__name__, lambda: simio_update_pubsub.dynamic_config.number_of_publishers)


@web.handler
class update(web.WebSocketHandler):

	cmd_publisher = IoxNotifyingPublisher(simio_cmd_pubsub, simio_cmd_event)

	async def on_message_json(self, msg):
		self.cmd_publisher.send_msgpack(msg)

	async def update(self):
		with (
			IoxListeningSubscriber(simio_update_pubsub, simio_update_event) as update_subscriber,
			IoxSubscriber(simio_details_pubsub) as details_subscriber,
		):
			await poll(details_subscriber.has_samples, update_subscriber.listener)
			while True:
				await self.write_message({
					'data': await update_subscriber.poll_receive_msgpack(),
					'list': details_subscriber.receive_msgpack(),
				})
