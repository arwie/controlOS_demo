"""
I/O wave — measuring the round-trip latency of the digital I/O link.

A wave runs across the digital outputs 9..16: each output is switched, and the
program waits until the corresponding input reports the new state back before
it moves on to the next one. On this rig the outputs are wired back to the
inputs, so every switch is a full round trip Python → CODESYS → I/O → CODESYS →
Python. A second task counts the completed round trips and logs them once per
second.

Why this is interesting for a PLC engineer
-------------------------------------------
The obvious question about running application logic in Python is "how much
does it cost me?". This program answers it in one number: switches per second
is the rate at which an ordinary Python coroutine can command an output and
react to the resulting input.
"""

from itertools import cycle
from shared import app
from shared.app import codesys
from shared.asyncio import AuxTaskGroup
from shared.condition import poll
from shared import log



@app.context
async def run():

	switches = 0

	async with AuxTaskGroup() as task_group:

		@task_group
		async def measure_task():
			nonlocal switches
			while True:
				await app.sleep(1)
				log.notice(f'Switches per second: {switches}')
				switches = 0

		for val in cycle((True, False)):
			for i in range(9, 17):
				codesys.cmd.io[i] = val
				await poll(lambda: codesys.fbk.io[i] == val, codesys.fbk_trigger)
				switches += 1
