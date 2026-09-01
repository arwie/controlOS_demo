import web
from shared.asyncio import Trigger
from shared.iceoryx.pubsub import IoxNotifyingPublisher
from shared.topics.robot import RobotOverride, robot_override_pubsub, robot_override_event



@web.handler
class override(web.WebSocketHandler):

	publisher = IoxNotifyingPublisher(robot_override_pubsub, robot_override_event)
	data = RobotOverride()
	trigger = Trigger()

	@classmethod
	def set_override(cls, override:float):
		cls.data.override = override
		cls.publisher.send_copy(cls.data)
		cls.trigger()

	async def on_message_json(self, msg):
		self.set_override(msg)

	async def update(self):
		while True:
			await self.write_message(self.data.override)
			await self.trigger.wait()


override.set_override(60)