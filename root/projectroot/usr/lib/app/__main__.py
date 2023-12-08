from shared import app
from shared.app import codesys

import splash


@app.context
async def main():
	async with codesys.exec(4*2/1000):
		async with splash.exec():
			yield


app.run(main)
