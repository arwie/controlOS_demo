from ctypes import *  #type:ignore
class AppCfg(Structure):
	robot_vel: float
	robot_acc: float
	robot_jrk: float
	_fields_ = [
		('robot_vel', c_double),
		('robot_acc', c_double),
		('robot_jrk', c_double),
	]