import asyncio
from shared import app
from shared.app import codesys


async def blink(i, t):
	codesys.cmd.io[i] = True
	try:
		await app.sleep(t)
	finally:
		codesys.cmd.io[i] = False


@app.context
async def exec():
	queue = asyncio.Queue()

	async def trigger():
		last_io = [False] * 16
		while True:
			await app.sleep(0.01)
			for i in range(0, 16):
				if codesys.fbk.io[i] and not last_io[i]:
					queue.put_nowait(i)
				last_io[i] = codesys.fbk.io[i]

	async def splash():
		while True:
			x = await queue.get()

			async def shoot(i, d):
				while 0 <= i <= 15:
					await blink(i, 0.075)
					i += d

			async with app.task_group(shoot(x, -1), shoot(x, +1)):
				for _ in range(0, 3):
					await app.sleep(0.15)
					await blink(x, 0.15)

	async with app.task_group(trigger(), splash()):
		yield
