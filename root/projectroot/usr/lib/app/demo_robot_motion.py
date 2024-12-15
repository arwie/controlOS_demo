from shared import app
from robot import robot
from coordinates import Axes, Pos



ZERO_AXES = Axes(320, 320, 320)



async def demo_move_direct(rounds):
	async with robot.power():
		for _ in range(rounds):
			await robot.move_direct(ZERO_AXES + Axes(60,60,-40))
			await robot.move_direct(ZERO_AXES + Axes(60,-40,60))
			await robot.move_direct(ZERO_AXES + Axes(-40,60,60))
		await robot.move_direct(ZERO_AXES, 60)



async def demo_move_linear(rounds):
	async with robot.power():
		for _ in range(rounds):
			await robot.move_linear(Pos(80,  170, -580))
			await robot.move_linear(Pos(80, -170, -580))
			await robot.move_linear(Pos(-110,  150, -600))
			await robot.move_linear(Pos(-110, -150, -600))
		await robot.move_direct(ZERO_AXES, 60)



async def demo_move_cnc(rounds):
	async with robot.power():
		for _ in range(rounds):
			await robot.move_cnc("""
				N10 G51  D250
				N21 G01  X80    Y170   Z-580
				N22 G01  X80    Y-170  Z-580
				N23 G01  X-110  Y150   Z-600
				N24 G01  X-110  Y-150  Z-600
			""")
		await robot.move_direct(ZERO_AXES, 60)



async def run():
	robot.override = 50

	while True:
		await app.sleep(1)
		try:
			await demo_move_direct(3)
			await demo_move_linear(3)
			await demo_move_cnc(3)
		except Exception as exc:
			app.log.exception(f'Motion error: {exc}')

