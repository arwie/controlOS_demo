import asyncio
from random import uniform
from shared import app
from shared.app import codesys



async def blink(i, t):
	codesys.cmd.io[i] = True
	try:
		await app.sleep(t)
	finally:
		codesys.cmd.io[i] = False



@app.context
async def exec(inputs=True):
	async with app.AuxTaskGroup() as task_group:

		queue = asyncio.Queue[int]()

		@task_group
		async def splash():
			while True:
				x = await queue.get()

				async def shoot(i, d):
					while 1 < i < 16:
						i += d
						await blink(i, 0.075)

				async with app.AuxTaskGroup() as splash_task_group:
					splash_task_group(shoot(x, -1))
					splash_task_group(shoot(x, +1))
					await blink(x, 0.45)


		if inputs:

			@task_group
			async def trigger_inputs():
				last_io = [False] * 16
				while True:
					await app.sleep(0.01)
					for i in range(16):
						if codesys.fbk.io[i+1] and not last_io[i]:
							queue.put_nowait(i)
						last_io[i] = codesys.fbk.io[i+1]

		else:

			@task_group
			async def trigger_random():
				while True:
					await app.sleep(0.5)
					queue.put_nowait(int(uniform(4, 12)))


		yield
