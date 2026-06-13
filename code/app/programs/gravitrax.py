"""
GraviTrax marble-run demo — keeping a ball track running with a delta robot.

The Igus delta robot carries a magnetic gripper. It continuously picks steel
balls from the catch points of a GraviTrax marble run and drops them back onto
the elevated track entries, so the run never empties out. A rotating stage
(the extra axis) presents two of the track entries to the robot in turn, while
several track loops on the floor are served directly. The result is six ball
circuits running at once on a single robot and a single turntable.

Why this is interesting for a PLC engineer
-------------------------------------------
In classic IEC 61131-3 this is a resource-arbitration problem: six independent
sequences all competing for one robot and one rotary axis. The usual solution
is a hand-written step sequencer (CASE state machine) per circuit, plus global
"robot busy" / "stage busy" interlock flags that every sequence must test and
set in the right order. Adding a seventh circuit means touching all the shared
interlock logic again, and a sequence that aborts mid-step has to remember to
release every flag it took.

Here the same machine is expressed with Python's asyncio, and the structure
maps directly onto PLC concepts:

* Each ball circuit is an `async def` task (see the `@task_group` functions in
  `exec`). It reads top to bottom like a single sequence — `move, grab, move,
  drop, wait` — instead of being chopped into numbered states. The scheduler
  interleaves the six tasks cooperatively at every `await`; there is no
  pre-emption and no race between them, exactly like the cyclic, single-threaded
  execution a PLC programmer expects.

* `robot_lock` and `extra_lock` are the interlocks, but declarative. `async with
  robot_lock` means "I need the robot now"; a task simply waits its turn and the
  lock is released automatically when the `with` block ends — including on abort
  or shutdown. No busy-flag to forget to clear.

* `play_ball` and `rotate_stage` are reusable sequence building blocks. A circuit
  is just a few lines that compose them. Adding a seventh circuit is one more
  `@task_group` function; the shared arbitration logic is never touched.

* `with magnet(True)` and `robot.power()` are cancel-safe resources: if the
  program stops while a ball is gripped, the magnet drops it and the drives
  power down cleanly as the context managers unwind — the framework guarantees
  the outputs reset (see app_io_abstraction.md), so there is no manual cleanup
  path to maintain.

Real-time motion still runs in CODESYS; this Python layer only orchestrates the
sequencing and talks to the drives over the shared-memory link every PLC cycle.
"""

from asyncio import Lock
from contextlib import asynccontextmanager
from dataclasses import replace

from shared import app
from robot import robot, Pos
from extra import extra
from tool import magnet


robot_lock = Lock()
extra_lock = Lock()


async def play_ball(pick:Pos, drop:Pos):
	async with robot_lock:
		await robot.move_linear(replace(pick, z=drop.z-10))
		with magnet(True):
			await robot.move_linear(pick)
			await robot.move_linear(replace(pick, z=drop.z))
			await robot.move_linear(drop, speed=40)
			await app.sleep(0.03)
		await app.sleep(0.02)


@asynccontextmanager
async def rotate_stage(pos:float):
	async with extra_lock:
		await extra.move_absolute(pos, vel=80, acc=60)
		yield


@app.context
async def exec():

	await extra.drive.tune(
		velocity_integral_gain = 0,
	)
	robot.override = 100

	async with (
		robot.power(),
		extra.power(),
		app.AuxTaskGroup() as task_group
	):

		@task_group
		async def stage_short():
			while True:
				async with rotate_stage(343):
					await play_ball(
						Pos(-151,   7, -591),
						Pos(-149, -98, -570),
					)
				await app.sleep(2)

		@task_group
		async def stage_long():
			while True:
				async with rotate_stage(133):
					await play_ball(
						Pos(-140, -38, -591),
						Pos(-141,  17, -550),
					)
				await app.sleep(3.5)

		@task_group
		async def floor_slow():
			while True:
				await play_ball(
					Pos(99,   55, -615),
					Pos(-3, -128, -570),
				)
				await app.sleep(5)

		@task_group
		async def floor_twister_short():
			while True:
				await play_ball(
					Pos(47,  -38, -615),
					Pos(150, -35, -570),
				)
				await app.sleep(3)

		@task_group
		async def floor_twister_long():
			while True:
				await play_ball(
					Pos(-4,   52, -615),
					Pos(-57, -98, -570),
				)
				await app.sleep(3)

		@task_group
		async def floor_jump():
			while True:
				await play_ball(
					Pos(-5, -67, -615),
					Pos(151, 22, -570),
				)
				await app.sleep(2.5)

		yield