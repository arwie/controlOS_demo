from asyncio import sleep
import logging
from contextlib import asynccontextmanager
from shared import app
from shared.app import codesys


@app.input
def sto() -> bool:
	return codesys.fbk.axis_sto

@app.output
def led_left(value:bool):
	codesys.cmd.io[1] = value

@app.output
def led_right(value:bool):
	codesys.cmd.io[2] = value


@asynccontextmanager
async def power():
	codesys.cmd.axis_power = True
	try:
		if not await codesys.poll(lambda: codesys.fbk.axis_powered, timeout=1):
			raise Exception('Failed to power on axis')
		yield
	finally:
		codesys.cmd.axis_power = False


async def move(distance:float, velocity:float):
	codesys.cmd.move_distance = distance
	codesys.cmd.move_velocity = velocity
	codesys.cmd.move_exec = True
	try:
		if not await codesys.poll(lambda: codesys.fbk.move_done, abort=lambda: codesys.fbk.move_error):
			raise Exception('Failed to move axis')
	finally:
		codesys.cmd.move_exec = False
		await codesys.sync()


@asynccontextmanager
async def blink(led:app.simio.Output, frequency:float):
	sleep_duration = 0.5 / frequency

	async def blink_loop():
		while True:
			with led(True):
				await sleep(sleep_duration)
			await sleep(sleep_duration)

	async with app.task_group(blink_loop):
		yield


async def move_blinking(distance:float, velocity:float):
	async with blink(led_right if distance > 0 else led_left, velocity / 100):
		await move(distance, velocity)


async def run_demo():
	while True:
		await sleep(3)
		await app.poll(lambda: not sto())
		try:
			async with power():
				await move_blinking(+400,  300)
				await move_blinking(-700,  400)
				await move_blinking(+900,  500)
				await move_blinking(-800,  400)
				await move_blinking(+1200, 700)
				await move_blinking(-1100, 500)
				await move_blinking(+500,  300)
		except Exception as exc:
			logging.exception(f'Motion error: {exc}')


@app.context
async def exec():
	async with app.task_group(run_demo):
		yield