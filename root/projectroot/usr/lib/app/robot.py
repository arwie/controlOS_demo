from contextlib import asynccontextmanager
from shared.utils import instantiate
from shared import app
from shared.app import codesys
from coordinates import Axes, Pos
from drives import robot_a, robot_b, robot_c



@instantiate
class robot:

	def __init__(self):
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


	async def move_linear(self, pos:Pos):
		app.log.info(f'Robot move linear to {pos}')
		codesys.cmd.rbt_move_coord[:] = pos.x, pos.y, pos.z
		await self._move_exec(2)


	async def _move_exec(self, move:int):
		codesys.cmd.rbt_move = move
		try:
			if not await codesys.poll(lambda: codesys.fbk.rbt_move_done, abort=lambda: codesys.fbk.rbt_move_error):
				raise Exception('Failed to move robot')
		finally:
			codesys.cmd.rbt_move = 0
			await codesys.sync()


	async def home(self):
		app.log.info(f'Robot homing started at {robot.axes()}')
	
		async def setup_drives(torque, following_error):
			for drive in (robot_a, robot_b, robot_c):
				await drive.set_torque(torque)
				await drive.set_following_error(following_error)

		async def set_position(a, b, c):
			codesys.cmd.rbt_move_coord[:] = a, b, c
			await self._move_exec(-1)

		await setup_drives(20, 200)

		async with self.power():
			await set_position(370, 370, 370)
			await self.move_direct(Axes(200, 200, 200), 5)
			await set_position(240, 240, 240)
			await self.move_direct(Axes(240, 240, 240), 20)
			await self.move_direct(Axes(300, 300, 300), 10)

		await setup_drives(100, 10)
		app.log.info(f'Robot homing finished at {robot.axes()}')



