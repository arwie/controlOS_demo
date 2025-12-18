from shared import app
from conv import conv

from . import robot_motion
from . import io_splash



@app.context
async def exec():
	async with (
		io_splash.exec(),
		robot_motion.exec(),
	):
		async with conv.power(), conv.move_velocity(100):
			yield
