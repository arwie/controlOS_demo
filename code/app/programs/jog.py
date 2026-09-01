from numbers import Number
from shared import app
from shared.coordinates import Pos, astuple
from shared.iceoryx.pubsub import IoxListeningSubscriber
from shared.topics.programs import jog_cmd_pubsub, jog_cmd_event
from robot import robot
from conv import conv
from extra import extra



@app.context
async def run():
	with IoxListeningSubscriber(jog_cmd_pubsub, jog_cmd_event) as cmd_subscriber:
		async with (
			robot.jog() as robot_jog_control,
			conv.jog()  as conv_jog_control,
			extra.jog() as extra_jog_control,
		):
			while True:
				msg = await cmd_subscriber.poll_receive_msgpack()
				match msg['cmd']:
					case -1: #watchdog
						robot_jog_control()
						conv_jog_control()
						extra_jog_control()

					case 0: #stop
						robot_jog_control(Pos())
						conv_jog_control(0)
						extra_jog_control(0)

					case 1: #robot jog
						direction = Pos(**msg['dir'])

						#compute travel distance if jogging towards snap
						distance = 500
						for s,d,p in zip(msg['snap'].values(), astuple(direction), astuple(robot.pos())):
							if isinstance(s, Number) and d:
								sp = s - p
								if sp * d > 0.1:
									distance = abs(sp)

						robot_jog_control(direction * distance, msg['speed'])

					case 11: #conv jog
						conv_jog_control(msg['dir'], msg['speed'])

					case 12: #extra jog
						extra_jog_control(msg['dir'], msg['speed'])
