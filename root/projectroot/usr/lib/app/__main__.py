from shared import app
from shared.app import codesys
import drives
from robot import robot
import teach

import demo_robot_motion
import demo_cnc_paint



@app.context
async def operation():
	await drives.initialize()
	await robot.home()

	await teach.run()

	#await demo_robot_motion.run()
	#await demo_cnc_paint.run()



@app.context
async def main():
	async with codesys.exec(4*2/1000):
		await app.poll(lambda: codesys.fbk.init_done)

		await operation()



app.run(main)
