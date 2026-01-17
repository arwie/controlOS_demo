from pathlib import Path
from importlib import import_module
from shared import app
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

			async with teach.exec():
				await app.poll(lambda: program and buttons.start())
				assert program in programs

			try:
				with buttons.led_running(True):
					async with programs[program].exec():
						await app.poll(lambda: buttons.stop() or not program)

			except Exception:
				app.log.exception(f'Failed to run program: {program}')
				program = None
