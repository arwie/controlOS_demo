from shared.iceoryx.pubsub import IoxPublishSubscribe
from shared.iceoryx.event import IoxEvent
from ctypes import Structure, c_double


class RobotOverride(Structure):
	override: float
	_fields_ = [
		('override', c_double),
	]

robot_override_pubsub	= IoxPublishSubscribe('robot/override', RobotOverride, history=True)
robot_override_event  = IoxEvent('robot/override')
