from shared import app



@app.input
def start() -> bool:
	return False

@app.input
def stop() -> bool:
	return False
