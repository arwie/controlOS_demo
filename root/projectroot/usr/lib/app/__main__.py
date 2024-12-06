from shared import app
from shared.app import codesys
import drives
from robot import robot

import robot_demo



@app.context
async def operation():
	await app.poll(lambda: codesys.fbk.init_done)
	await drives.initialize()
	await robot.home()

	await robot_demo.run_demo()



@app.context
async def main():
	async with codesys.exec(4*2/1000):
		async with app.task_group(operation):
			yield


app.run(main)
