from itertools import cycle
from shared import app
from shared.app import codesys



switches = 0
switches_per_second = 0


web_placeholder = app.web.placeholder('io_wave')

class WebHandler(app.web.WebSocketHandler):
	@classmethod
	def update(cls):
		return {
			'in':  [codesys.fbk.io[io+1] for io in range(16)],
			'out': [codesys.cmd.io[io+1] for io in range(16)],
			'switches_per_second': switches_per_second,
		}


@app.context
async def exec():
	async with (
		web_placeholder.handle(WebHandler, update_period=0.02),
		app.AuxTaskGroup() as task_group
	):

		@task_group
		async def io_wave():
			global switches
			for val in cycle((True, False)):
				for io in range(16):
					codesys.cmd.io[io+1] = val
					await codesys.poll(lambda: codesys.fbk.io[io+1] == val)
					switches += 1

		@task_group
		async def measure():
			global switches, switches_per_second
			while True:
				switches = 0
				await app.sleep(1)
				switches_per_second = switches

		yield
