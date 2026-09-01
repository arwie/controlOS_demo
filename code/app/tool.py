from shared import app
from shared.app import codesys



@app.output
def magnet(value:bool):
	codesys.cmd.io[6] = value

@app.output
def vacuum(value:bool):
	codesys.cmd.io[7] = value

