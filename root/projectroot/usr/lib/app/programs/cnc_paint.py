from shared import app
from robot import robot, Axes
from cnc import CNCProgram



Z_PAINT    = -600
Z_TRAVERSE = -590
SMOOTHING  = 15


web_placeholder = app.web.placeholder('paint')



@app.CommandRunner
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
				await robot.move_direct(Axes(300, 300, 300), 60)



class WebHandler(app.web.WebSocketHandler):
	@classmethod
	def update(cls):
		return {
			'pos': robot.pos().asdict(),
			'busy': cmd_handler.busy(),
		}

	def on_message_json(self, msg):
		cmd_handler(msg['cmd'], msg)



async def run():
	robot.override = 30

	async with web_placeholder.handle(WebHandler, update_period=0.05):
		await cmd_handler.run()

