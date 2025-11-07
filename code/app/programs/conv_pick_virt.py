from collections import deque
from random import uniform
from shared import app
from robot import robot, Pos
from conv import conv, ConvItem
import sim



async def run():
	robot.override = 100

	queue = deque[ConvItem]()
	queue_trigger = app.Trigger()

	async def place_items():
		while True:
			await app.sleep(1.1)
			item = ConvItem(Pos(-300 - uniform(0, 50), uniform(10, 90)), conv.pos())
			queue.append(item)
			queue_trigger()
			sim.conv_place_item(item)

	async with (
		conv.power(),
		conv.move_velocity(100),
		robot.power(),
		app.task_group(place_items)
	):
		while True:
			await app.poll(lambda: queue, period=queue_trigger)
			item = queue.popleft()
			await robot.conv_pick(item)
			sim.conv_remove_item(item)
