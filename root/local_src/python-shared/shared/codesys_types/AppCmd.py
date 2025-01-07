from ctypes import *  #type:ignore
from .CoCmd import CoCmd
class AppCmd(Structure):
	co: CoCmd
	rbt_power: bool
	rbt_reset: bool
	rbt_override: float
	rbt_move: int
	rbt_move_coord: list[float]
	rbt_move_coord_conv: float
	rbt_move_fvel: float
	conv_power: bool
	conv_reset: bool
	conv_move: int
	conv_move_vel: float
	io: list[bool]
	_fields_ = [
		('co', CoCmd),
		('rbt_power', c_bool),
		('rbt_reset', c_bool),
		('rbt_override', c_double),
		('rbt_move', c_int16),
		('rbt_move_coord', c_double * 3),
		('rbt_move_coord_conv', c_double),
		('rbt_move_fvel', c_double),
		('conv_power', c_bool),
		('conv_reset', c_bool),
		('conv_move', c_int16),
		('conv_move_vel', c_double),
		('io', c_bool * 129),
	]