from shared import app
from shared.app import codesys
from shared.app.gadget import UdpMaster


wlpot = UdpMaster('wlpot', 55211, 0.05)


@app.context
async def exec():
	async with wlpot.exec():

		async def meter():
			while True:
				await wlpot.sync()
				for i in range(16):
					codesys.cmd.io[i] = wlpot.fbk['pot']*16 > i

		async with app.task_group(meter()):
			yield