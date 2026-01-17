from shared import app
from shared.app import codesys



@app.input(sim=True)
def start() -> bool:
	return codesys.fbk.io[1]

@app.input
def stop() -> bool:
	return codesys.fbk.io[2]

@app.output
def led_running(value:bool):
	codesys.cmd.io[1] = value


@app.input
def left() -> bool:
	return codesys.fbk.io[3]

@app.input
def right() -> bool:
	return codesys.fbk.io[4]

@app.output
def led_arrows(value:bool):
	codesys.cmd.io[2] = value
