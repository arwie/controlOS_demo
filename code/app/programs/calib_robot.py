from shared import app
from shared.iceoryx.pubsub import IoxPublisher
from shared.topics.programs import calib_robot_pubsub
from drives import robot_a, robot_b, robot_c



@app.context
async def run():
	with IoxPublisher(calib_robot_pubsub) as publischer:
		while True:
			publischer.send_msgpack({
				drive.name: await drive.get_internal_pos()
					for drive in (robot_a, robot_b, robot_c)
			})
			await app.sleep(0.1)
