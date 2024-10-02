from ctypes import *  #type:ignore
from .CoFbk import CoFbk
class AppFbk(Structure):
	co: CoFbk
	axis_sto: bool
	axis_powered: bool
	move_done: bool
	move_error: bool
	io: list[bool]
	_fields_ = [
		('co', CoFbk),
		('axis_sto', c_bool),
		('axis_powered', c_bool),
		('move_done', c_bool),
		('move_error', c_bool),
		('io', c_bool * 129),
	]