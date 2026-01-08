from shared import app, system
from shared.app import codesys
import drives
from robot import robot
import buttons
import sim
import teach


from programs import conv_pick_virt as program



@app.context
async def operation():
	await drives.initialize()
	await robot.home()

	while True:

		async with teach.exec():
			await app.poll(buttons.start)

		async with program.exec():
			await app.poll(buttons.stop)



@app.context
async def main():
	async with codesys.exec():

		# RT: tune SPI kernel threads on RPI
		for proc in ('spi0','irq/[0-9]*-spi0.0'):
			system.run(f'taskset -pc 2 $(pgrep -x {proc})', check=False)

		await app.poll(lambda: codesys.fbk.init_done)

		async with sim.exec():
			await operation()



app.run(main)
