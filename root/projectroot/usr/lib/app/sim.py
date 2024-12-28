from shared import app
from robot import robot
import buttons



web_placeholder = app.web.placeholder('sim')



async def _press_button_sim(button:app.simio.Input, duration=0.25):
	button.sim = True
	await app.sleep(duration)
	button.sim = False



@app.CommandRunner
async def cmd_handler(cmd, data):
	match cmd:
		case 1:
			await _press_button_sim(buttons.start)
		case 2:
			await _press_button_sim(buttons.stop)



class WebHandler(app.web.WebSocketHandler):
	@classmethod
	def update(cls):
		return {
			'cmd': 0,
			'robot': {
				'axes': robot.axes().astuple(),
				'pos':  robot.pos().asdict(),
			},
		}

	def on_message_json(self, msg):
		cmd_handler(msg['cmd'], msg)



@app.context
async def exec():
	async with web_placeholder.handle(WebHandler, update_period=1/30):
		async with app.task_group(cmd_handler.run):
			yield

