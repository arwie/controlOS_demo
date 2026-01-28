from shared import app
from robot import robot
from coordinates import Axes, asdict
from cnc import CNCProgram



Z_PAINT    = -600
Z_TRAVERSE = -590
SMOOTHING = 3


web_placeholder = app.web.placeholder('cnc_paint')



@app.CommandExecutor
async def cmd_handler(cmd, data:dict):
	match cmd:
		case 1:
			cnc = CNCProgram()
			cnc.append(f"G51 D{SMOOTHING}")

			for path in data['paths']:

				cnc.append(f"G0 X{path[0]['x']} Y{path[0]['y']} Z{Z_TRAVERSE}")
				cnc.append(f"G0 Z{Z_PAINT}")

				for edge in path[1:]:
					cnc.append(f"G1 X{edge['x']} Y{edge['y']}")

				cnc.append(f"G0 Z{Z_TRAVERSE}")

			async with robot.power():
				await robot.move_cnc(cnc)
				await robot.move_direct(Axes(260, 260, 260), 60)



class WebHandler(app.web.WebSocketHandler):
	@classmethod
	def update(cls):
		return {
			'pos': asdict(robot.pos()),
			'busy': cmd_handler.busy(),
		}

	def on_message_json(self, msg):
		cmd_handler(msg['cmd'], msg)



@app.context
async def exec():
	robot.override = 25

	async with web_placeholder.handle(WebHandler, update_period=0.05):
		async with cmd_handler.exec():
			yield

