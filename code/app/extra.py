from contextlib import asynccontextmanager
from shared.utils import instantiate
from shared import app
from shared.app import codesys
from shared.condition import Timer, Timeout



@instantiate
class extra:

	from drives import extra_drive as drive


	def __init__(self):
		codesys.cfg.extra_acc = 2000
		codesys.cfg.extra_jrk = 5000


	def pos(self):
		return codesys.fbk.extra_pos


	@asynccontextmanager
	async def power(self):
		codesys.cmd.extra_power = True
		try:
			if not await codesys.poll(lambda: codesys.fbk.extra_powered, timeout=3):
				raise Exception('Failed to power on extra axis')
			app.log.info('Extra axis power enabled')
			yield
		finally:
			codesys.cmd.extra_power = False
			if not await codesys.poll(lambda: not codesys.fbk.extra_powered, timeout=3):
				app.log.warning('Extra axis not disabled in time')
			await app.sleep(0.2) #Let the hardware settle befor next enable


	async def move_absolute(self, pos:float, vel:float, acc:float):
		codesys.cmd.extra_move_pos = pos
		codesys.cmd.extra_move_vel = vel
		codesys.cmd.extra_move_acc = acc
		await self._move_exec(1)


	async def _move_exec(self, move:int):
		codesys.cmd.extra_move = move
		try:
			if not await codesys.poll(lambda: codesys.fbk.extra_move_done, abort=lambda: codesys.fbk.extra_move_error):
				raise Exception('Failed to move extra axis')
		finally:
			codesys.cmd.extra_move = 0
			await codesys.sync()


	@asynccontextmanager
	async def jog(self, power_time=15):
		watchdog = Timeout(0.3)

		@app.aux_task
		async def jog_task():
			while True:
				await app.poll(lambda: codesys.cmd.extra_move_vel)
				async with self.power():
					codesys.cmd.extra_move = 99
					try:
						power_timer = Timer(power_time)
						while power_timer and not (codesys.fbk.extra_move_error or watchdog()):
							await app.sleep()
							if codesys.cmd.extra_move_vel:
								power_timer.reset()
					finally:
						codesys.cmd.extra_move = 0
						await codesys.sync()
				await app.poll(lambda: not codesys.cmd.extra_move_vel)

		def jog_control(direction:int|None=None, speed:float=10):
			"""Calling jog_control without args resets the watchdog."""
			watchdog.reset()
			if direction is not None:
				codesys.cmd.extra_move_vel = direction * 1500 * speed / 100

		jog_control(0)
		async with jog_task():
			yield jog_control
