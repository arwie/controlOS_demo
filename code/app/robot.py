from contextlib import asynccontextmanager
from shared.utils import instantiate
from pathlib import Path
from shared import app
from shared.app import codesys
from shared.condition import Timer, Timeout
from coordinates import Axes, Pos
from drives import robot_a, robot_b, robot_c
from cnc import CNCProgram
from conv import ConvItem



@instantiate
class robot:

	def __init__(self):
		codesys.cfg.robot_vel = 2000
		codesys.cfg.robot_acc = 20000
		codesys.cfg.robot_jrk = 400000

		self.override = 100


	@property
	def override(self) -> float:
		"""Velocity override in %"""
		return codesys.cmd.rbt_override * 100

	@override.setter
	def override(self, value:float):
		value /= 100
		codesys.cmd.rbt_override = max(0, min(value, 1))


	def axes(self):
		return Axes(*codesys.fbk.rbt_axes)
	
	def pos(self):
		return Pos(*codesys.fbk.rbt_pos)


	@asynccontextmanager
	async def power(self):
		codesys.cmd.rbt_power = codesys.cmd.rbt_reset = True
		try:
			if not await codesys.poll(lambda: codesys.fbk.rbt_powered, timeout=3):
				raise Exception('Failed to power on robot')
			codesys.cmd.rbt_reset = False
			app.log.info('Robot power enabled')
			yield
		finally:
			codesys.cmd.rbt_power = codesys.cmd.rbt_reset = False
			if not await codesys.poll(lambda: not codesys.fbk.rbt_powered, timeout=3):
				app.log.warning('Robot not disabled in time')
			await app.sleep(0.2) #Let the hardware settle befor next enable


	async def move_direct(self, axes:Axes, speed:float=100):
		app.log.info(f'Robot move direct to {axes}')
		codesys.cmd.rbt_move_coord[:] = axes.a, axes.b, axes.c
		codesys.cmd.rbt_move_fvel = speed / 100
		await self._move_exec(1)


	async def move_linear(self, pos:Pos, speed:float=100):
		app.log.info(f'Robot move linear to {pos}')
		codesys.cmd.rbt_move_coord[:] = pos.x, pos.y, pos.z
		codesys.cmd.rbt_move_fvel = speed / 100
		await self._move_exec(2)


	async def move_cnc(self, cnc:str|CNCProgram, speed:float=30):
		app.log.info(f'Robot execute CNC program', extra={'CNC':cnc})
		Path('/run/codesys/robot.cnc').write_text(str(cnc))
		codesys.cmd.rbt_move_fvel = speed / 100
		await self._move_exec(11)


	async def conv_pick(self, item:ConvItem):
		codesys.cmd.rbt_move_coord[:] = item.pos.x, item.pos.y, item.pos.z
		codesys.cmd.rbt_move_coord_conv = item.conv
		await self._move_exec(31)


	async def _move_exec(self, move:int):
		codesys.cmd.rbt_move = move
		try:
			if not await codesys.poll(lambda: codesys.fbk.rbt_move_done, abort=lambda: codesys.fbk.rbt_move_error):
				raise Exception('Failed to move robot')
		finally:
			codesys.cmd.rbt_move = 0
			await codesys.sync()


	@asynccontextmanager
	async def jog(self, power_time=15):
		watchdog = Timeout(0.3)

		@app.aux_task
		async def jog_task():
			while True:
				await app.poll(lambda: any(codesys.cmd.rbt_move_coord))
				async with self.power():
					codesys.cmd.rbt_move = 99
					try:
						power_timer = Timer(power_time)
						while power_timer and not (codesys.fbk.rbt_move_error or watchdog()):
							await app.sleep()
							if any(codesys.cmd.rbt_move_coord):
								power_timer.reset()
					finally:
						codesys.cmd.rbt_move = 0
						await codesys.sync()
				await app.poll(lambda: not any(codesys.cmd.rbt_move_coord))

		def jog_control(direction:Pos|None=None, speed:float=10):
			"""Calling jog_control without args resets the watchdog."""
			watchdog.reset()
			if direction is not None:
				codesys.cmd.rbt_move_coord[:] = direction.x, direction.y, direction.z
				codesys.cmd.rbt_move_fvel = speed / 100

		jog_control(Pos())
		async with jog_task():
			yield jog_control


	async def home(self):
		app.log.info(f'Robot homing started at {robot.axes()}')

		HOME_AXES = Axes(310-53.37, 310-55.37, 310-52.43) #manually calibrated

		async def setup_drives(torque, following_error):
			for drive in (robot_a, robot_b, robot_c):
				await drive.set_torque(torque)
				await drive.set_following_error(following_error)

		async def set_position(axes:Axes):
			codesys.cmd.rbt_move_coord[:] = axes.a, axes.b, axes.c
			await self._move_exec(-1)

		await setup_drives(20, 200)

		async with self.power():
			await app.sleep(1)
			await set_position(Axes(370, 370, 370))
			await self.move_direct(Axes(200, 200, 200), 5)
			await set_position(HOME_AXES)
			await self.move_direct(HOME_AXES, 30)
			await self.move_direct(Axes(300, 300, 300), 10)

		await setup_drives(100, 10)
		app.log.info(f'Robot homing finished at {robot.axes()}')



