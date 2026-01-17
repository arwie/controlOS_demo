from shared import app, system
from shared.app import codesys
import sim
import drives
from robot import robot
import programs



@app.context
async def operation():
	await drives.initialize()
	await robot.home()

	await programs.run()



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
