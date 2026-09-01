from shared import app
from robot import robot
from shared.coordinates import Axes
from cnc import CNCProgram
from shared.iceoryx.pubsub import IoxListeningSubscriber
from shared.topics.programs import cnc_paint_pubsub, cnc_paint_event



Z_PAINT    = -600
Z_TRAVERSE = -590
SMOOTHING = 3



async def draw(paths:list[list[dict]]):
	cnc = CNCProgram()
	cnc.append(f"G51 D{SMOOTHING}")

	for path in paths:

		cnc.append(f"G0 X{path[0]['x']} Y{path[0]['y']} Z{Z_TRAVERSE}")
		cnc.append(f"G0 Z{Z_PAINT}")

		for edge in path[1:]:
			cnc.append(f"G1 X{edge['x']} Y{edge['y']}")

		cnc.append(f"G0 Z{Z_TRAVERSE}")

	async with robot.power():
		await robot.move_cnc(cnc)
		await robot.move_direct(Axes(260, 260, 260), 60)



@app.context
async def run():
	with IoxListeningSubscriber(cnc_paint_pubsub, cnc_paint_event) as cmd_subscriber:
		while True:
			cmd_subscriber.drain()
			msg = await cmd_subscriber.poll_receive_msgpack()
			match msg['cmd']:
				case 1:
					await draw(msg['paths'])
