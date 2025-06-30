from asyncio import Event
from shared import app
from conv import conv

from . import robot_motion
from . import io_splash



async def run():
	async with app.task_group(
		robot_motion.run(),
		io_splash.run(False),
	):
		async with (conv.power(), conv.move_velocity(100)):
			await Event().wait()
