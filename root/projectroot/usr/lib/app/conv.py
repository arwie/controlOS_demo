from contextlib import asynccontextmanager
from dataclasses import dataclass
from shared.utils import instantiate
from shared import app
from shared.app import codesys
from shared.condition import Timer, Timeout
from coordinates import Pos
from drives import conv_drive



@dataclass
class ConvItem:
	pos: Pos
	conv: float



@instantiate
class conv:

	def __init__(self):
		codesys.cfg.conv_acc = 250
		codesys.cfg.conv_jrk = 500


	def pos(self):
		return codesys.fbk.conv_pos


	@asynccontextmanager
	async def power(self):
		codesys.cmd.conv_power = codesys.cmd.conv_reset = True
		try:
			if not await codesys.poll(lambda: codesys.fbk.conv_powered, timeout=3):
				raise Exception('Failed to power on conveyor')
			codesys.cmd.conv_reset = False
			app.log.info('Conveyor power enabled')
			yield
		finally:
			codesys.cmd.conv_power = codesys.cmd.conv_reset = False
			if not await codesys.poll(lambda: not codesys.fbk.conv_powered, timeout=3):
				app.log.warning('Conveyor not disabled in time')
			await app.sleep(0.2) #Let the hardware settle befor next enable


	@asynccontextmanager
	async def move_velocity(self, velocity:float):
		codesys.cmd.conv_move_vel = velocity
		codesys.cmd.conv_move = 1
		try:
			yield
		finally:
			codesys.cmd.conv_move = 0
			await codesys.sync()


	@asynccontextmanager
	async def jog(self, power_time=15):
		watchdog = Timeout(0.3)

		async def jog_task():
			while True:
				await app.poll(lambda: codesys.cmd.conv_move_vel)
				async with self.power():
					codesys.cmd.conv_move = 99
					try:
						power_timer = Timer(power_time)
						while power_timer and not (codesys.fbk.conv_move_error or watchdog()):
							await app.sleep()
							if codesys.cmd.conv_move_vel:
								power_timer.reset()
					finally:
						codesys.cmd.conv_move = 0
						await codesys.sync()
				await app.poll(lambda: not codesys.cmd.conv_move_vel)

		def jog_control(direction:int|None=None, speed:float=10):
			"""Calling jog_control without args resets the watchdog."""
			watchdog.reset()
			if direction is not None:
				codesys.cmd.conv_move_vel = direction * 500 * speed / 100

		jog_control(0)
		async with app.task_group(jog_task):
			yield jog_control
