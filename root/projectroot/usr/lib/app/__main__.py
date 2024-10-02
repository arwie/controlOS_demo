from shared import app
from shared.app import codesys

import move_axis


@app.context
async def main():
	async with codesys.exec(4*2/1000):
		async with move_axis.exec():
			yield


app.run(main)
