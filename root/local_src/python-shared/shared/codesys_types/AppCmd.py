from ctypes import *  #type:ignore
from .CoCmd import CoCmd
class AppCmd(Structure):
	co: CoCmd
	axis_power: bool
	move_exec: bool
	move_distance: float
	move_velocity: float
	io: list[bool]
	_fields_ = [
		('co', CoCmd),
		('axis_power', c_bool),
		('move_exec', c_bool),
		('move_distance', c_double),
		('move_velocity', c_double),
		('io', c_bool * 129),
	]