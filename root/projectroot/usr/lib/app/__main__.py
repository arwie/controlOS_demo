from shared import app
from shared.app import codesys
import drives
from robot import robot
import buttons
import sim
import teach


from programs import hardware_test as program



@app.context
async def operation():
	await drives.initialize()
	await robot.home()

	while True:

		async with teach.exec():
			await app.poll(buttons.start)

		async with app.task_group(program.run):
			await app.poll(buttons.stop)



@app.context
async def main():
	async with codesys.exec(4*2/1000):
		await app.poll(lambda: codesys.fbk.init_done)

		async with sim.exec():
			await operation()



app.run(main)
