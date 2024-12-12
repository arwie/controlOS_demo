from shared import app
from robot import robot
from coordinates import Axes, Pos



async def demo_move_direct(rounds):
	zero_axes = Axes(320, 320, 320)
	async with robot.power():
		for _ in range(rounds):
			await robot.move_direct(zero_axes + Axes(60,60,-40))
			await robot.move_direct(zero_axes + Axes(60,-40,60))
			await robot.move_direct(zero_axes + Axes(-40,60,60))
		await robot.move_direct(Axes(300, 300, 300), 60)



async def demo_move_linear(rounds):
	async with robot.power():
		for _ in range(rounds):
			await robot.move_linear(Pos(80,  170, -580))
			await robot.move_linear(Pos(80, -170, -580))
			await robot.move_linear(Pos(-110,  150, -600))
			await robot.move_linear(Pos(-110, -150, -600))
		await robot.move_direct(Axes(300, 300, 300), 60)



async def run_demo():
	robot.override = 70

	while True:
		try:
			await demo_move_direct(5)
			await demo_move_linear(5)
		except Exception as exc:
			app.log.exception(f'Motion error: {exc}')
			await app.sleep(1)

