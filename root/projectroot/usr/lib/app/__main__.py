from shared import app
from shared.app import codesys

import wlpot


@app.context
async def main():
	async with codesys.exec(4*2/1000):
		async with wlpot.exec():
			yield


app.run(main)
