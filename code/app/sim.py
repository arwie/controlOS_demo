from dataclasses import asdict, astuple
from shared import app
from shared.condition import poll
from shared.asyncio import AuxTaskGroup
from shared.iceoryx.pubsub import IoxPublisher, IoxListeningSubscriber
from shared.topics.sim import sim_update_pubsub, sim_cmd_pubsub, sim_cmd_event
from robot import robot
from conv import conv, ConvItem
import buttons



update_publisher = IoxPublisher(sim_update_pubsub)


def conv_place_item(item:ConvItem):
	update_publisher.send_msgpack({
		'cmd': 11,
		'id': str(id(item)),
		'item': asdict(item),
	})

def conv_remove_item(item:ConvItem):
	update_publisher.send_msgpack({
		'cmd': 12,
		'id': str(id(item)),
	})



async def _press_button_sim(button:app.simio.Input, duration=0.25):
	button.sim = True
	await app.sleep(duration)
	button.sim = False


@app.context
async def exec():
	async with AuxTaskGroup() as task_group:

		@task_group
		async def cmd_task():
			with IoxListeningSubscriber(sim_cmd_pubsub, sim_cmd_event) as cmd_subscriber:
				while True:
					msg = await cmd_subscriber.poll_receive_msgpack()
					match msg['cmd']:
						case 1:
							await _press_button_sim(buttons.start)
						case 2:
							await _press_button_sim(buttons.stop)

		yield
