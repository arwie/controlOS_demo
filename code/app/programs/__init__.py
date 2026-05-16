from pathlib import Path
from importlib import import_module
from shared import app
from shared.condition import Pulse
import buttons
import teach



programs = {
	file.stem: import_module(f'{__name__}.{file.stem}')
		for file in Path(__file__).parent.glob('*.py*') if not file.match('_*')
}
program = None


web_placeholder = app.web.placeholder('programs')


class WebHandler(app.web.RequestHandler):

	async def get(self):
		self.write(program)

	async def post(self):
		global program
		program = self.read_json()



@app.context
async def run():
	global program

	async with web_placeholder.handle(WebHandler):
		while True:

			async with (
				teach.exec(),
			):
				with buttons.led_running:
					blink_pulse = Pulse(2)
					while not (program and buttons.start()):
						buttons.led_running(bool(program and blink_pulse()))
						await app.sleep()

			try:
				with buttons.led_running(True):
					async with programs[program].exec():
						await app.poll(lambda: buttons.stop() or not program)

			except Exception:
				app.log.exception(f'Failed to run program: {program}')
				program = None
