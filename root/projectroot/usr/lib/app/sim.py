from dataclasses import asdict, astuple
from shared import app
from robot import robot
from conv import conv, ConvItem
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
				'axes': astuple(robot.axes()),
				'pos': asdict(robot.pos()),
			},
			'conv': {
				'pos': conv.pos(),
			},
		}

	def on_message_json(self, msg):
		cmd_handler(msg['cmd'], msg)



@app.context
async def exec():
	async with web_placeholder.handle(WebHandler, update_period=1/30):
		async with app.task_group(cmd_handler.run):
			yield



def conv_place_item(item:ConvItem):
	WebHandler.all.write_message({
		'cmd': 11,
		'id': str(id(item)),
		'item': asdict(item),
	})

def conv_remove_item(item:ConvItem):
	WebHandler.all.write_message({
		'cmd': 12,
		'id': str(id(item)),
	})