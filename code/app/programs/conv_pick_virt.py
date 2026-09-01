from collections import deque
from random import uniform
from shared import app
from shared.asyncio import AuxTaskGroup, Trigger
from shared.condition import poll
from robot import robot, Pos
from conv import conv, ConvItem
import sim



@app.context
async def run():

	queue = deque[ConvItem]()
	queue_trigger = Trigger()

	async with (
		conv.power(),
		conv.move_velocity(100),
		robot.power(),
		AuxTaskGroup() as task_group
	):

		@task_group
		async def place_items():
			while True:
				await app.sleep(1.1)
				item = ConvItem(Pos(-300 - uniform(0, 50), uniform(10, 90)), conv.pos())
				queue.append(item)
				queue_trigger()
				sim.conv_place_item(item)

		while True:
			await poll(lambda: queue, queue_trigger)
			item = queue.popleft()
			await robot.conv_pick(item)
			sim.conv_remove_item(item)
