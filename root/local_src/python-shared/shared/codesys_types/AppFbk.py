from ctypes import *  #type:ignore
from .CoFbk import CoFbk
class AppFbk(Structure):
	co: CoFbk
	init_done: bool
	rbt_axes: list[float]
	rbt_pos: list[float]
	rbt_powered: bool
	rbt_move_done: bool
	rbt_move_error: bool
	conv_pos: float
	conv_powered: bool
	conv_move_done: bool
	conv_move_error: bool
	io: list[bool]
	_fields_ = [
		('co', CoFbk),
		('init_done', c_bool),
		('rbt_axes', c_double * 3),
		('rbt_pos', c_double * 3),
		('rbt_powered', c_bool),
		('rbt_move_done', c_bool),
		('rbt_move_error', c_bool),
		('conv_pos', c_double),
		('conv_powered', c_bool),
		('conv_move_done', c_bool),
		('conv_move_error', c_bool),
		('io', c_bool * 129),
	]