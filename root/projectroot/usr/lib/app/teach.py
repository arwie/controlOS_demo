from asyncio import Event
from dataclasses import astuple
from shared import app
from robot import robot, Pos
from conv import conv



web_placeholder = app.web.placeholder('teach')


@app.context
async def exec():
	async with robot.jog() as robot_jog_control, conv.jog() as conv_jog_control:

		class WebHandler(app.web.WebSocketHandler):
			@classmethod
			def update(cls):
				return {
					'robot': {
						'pos': robot.pos().asdict(),
					},
					'conv': {
						'pos': conv.pos(),
					},
					'tool': 0,
					'gripped': False,
				}

			def on_message_json(self, msg):
				match msg.get('cmd'):
					case None: #watchdog
						robot_jog_control()
						conv_jog_control()

					case 0: #stop
						robot_jog_control(Pos())
						conv_jog_control(0)

					case 1: #robot jog
						direction = Pos(**msg['dir'])

						#compute travel distance if jogging towards snap
						distance = 500
						for s,d,p in zip(msg['snap'].values(), astuple(direction), astuple(robot.pos())):
							if len(s) and d:
								sp = float(s) - p
								if sp * d > 0.1:
									distance = abs(sp)

						robot_jog_control(direction * distance, msg['speed'])

					case 11: #conv jog
						conv_jog_control(msg['dir'], msg['speed'])


		async with web_placeholder.handle(WebHandler):
			yield

