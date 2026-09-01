from pathlib import Path
import web
from shared.asyncio import Trigger
from shared.iceoryx.pubsub import IoxPublisher
from shared.topics.programs import programs_select_pubsub


@web.handler
class programs(web.ModuleHandler):
	async def export_default(self):
		return sorted(f.stem for f in Path('/usr/lib/app/programs').glob('*.py') if not f.match('_*'))


web.files.glob('hmi/programs/*.jpg')
web.document.imports.append('hmi/programs')


@web.handler
class select(web.WebSocketHandler):

	select_publisher = IoxPublisher(programs_select_pubsub)
	program: str|None = None
	program_trigger = Trigger()

	@classmethod
	def select_program(cls, program):
		cls.program = program
		cls.select_publisher.send_msgpack(cls.program)
		cls.program_trigger()

	async def on_message_json(self, msg):
		self.select_program(msg)

	async def update(self):
		while True:
			await self.write_message(self.program)
			await self.program_trigger.wait()


from . import calib_robot
from . import jog
from . import cnc_paint
