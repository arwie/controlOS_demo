from pathlib import Path
from importlib import import_module
from shared import app
from shared.condition import Pulse, poll
from shared.asyncio import AuxTaskGroup
import buttons
from shared.iceoryx.pubsub import IoxSubscriber
from shared.topics.programs import programs_select_pubsub



programs = {
	file.stem: import_module(f'{__name__}.{file.stem}')
		for file in Path(__file__).parent.glob('*.py*') if not file.match('_*')
}


blink_pulse = Pulse(2)

async def run_program(prg:str):
	with buttons.led_running:
		while not buttons.start():
			await app.sleep()
			buttons.led_running(blink_pulse())
		buttons.led_running(True)
		try:
			await programs[prg].run()
		except Exception:
			app.log.exception(f'Failed to run program: {prg}')



@app.context
async def run():
	with IoxSubscriber(programs_select_pubsub) as program_subscriber:
		program = None

		while True:
			async with AuxTaskGroup() as task_group:
				await poll(lambda: not (buttons.stop() or buttons.start()))

				if program:
					task_group.create_task(run_program(program))

				if await poll(program_subscriber.has_samples, abort=buttons.stop):
					program = program_subscriber.receive_msgpack()
