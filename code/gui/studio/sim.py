from asyncio import sleep
import web
from shared.iceoryx.pubsub import IoxNotifyingPublisher, IoxSubscriber, poll
from shared.topics.sim import sim_cmd_pubsub, sim_cmd_event, sim_update_pubsub
from shared.topics.codesys import codesys_fbk_pubsub
from shared.coordinates import Pos, Axes, asdict, astuple


web.document.imports.append('studio/sim')

web.files.glob('sim/**/*.stl')



@web.handler
class update(web.WebSocketHandler):

	cmd_publisher = IoxNotifyingPublisher(sim_cmd_pubsub, sim_cmd_event)

	async def on_message_json(self, msg):
		self.cmd_publisher.send_msgpack(msg)

	async def update(self):
		update_period=1/30
		with (
			IoxSubscriber(codesys_fbk_pubsub) as fbk_subscriber,
		):
			while True:
				with await poll(fbk_subscriber.receive) as sample:
					fbk = sample.payload().contents
					msg = {
						'cmd': 0,
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
					}
				await self.write_message(msg)
				await sleep(update_period)
