from asyncio import sleep
import web
from shared.iceoryx.pubsub import IoxNotifyingPublisher, IoxSubscriber, poll
from shared.topics.programs import jog_cmd_pubsub, jog_cmd_event
from shared.topics.codesys import codesys_fbk_pubsub
from shared.coordinates import Pos, Axes, asdict, astuple


web.document.imports.append('hmi/programs/jog')
web.site.show(__name__, lambda: jog_cmd_pubsub.dynamic_config.number_of_subscribers)



@web.handler
class main(web.WebSocketHandler):

	cmd_publisher = IoxNotifyingPublisher(jog_cmd_pubsub, jog_cmd_event)

	async def on_message_json(self, msg):
		self.cmd_publisher.send_msgpack(msg)

	async def update(self):
		update_period=1/5
		with IoxSubscriber(codesys_fbk_pubsub) as fbk_subscriber:
			while True:
				with await poll(fbk_subscriber.receive) as sample:
					fbk = sample.payload().contents
					msg = {
						'robot': {
							'axes': astuple(Axes(*fbk.rbt_axes)),
							'pos': asdict(Pos(*fbk.rbt_pos)),
						},
						'conv': {
							'pos': fbk.conv_pos,
						},
						'extra': {
							'pos': fbk.extra_pos,
						},
						'tool': 0,
						'gripped': False,
					}
				await self.write_message(msg)
				await sleep(update_period)
