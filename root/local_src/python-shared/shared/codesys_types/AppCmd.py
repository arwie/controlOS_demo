from ctypes import *  #type:ignore
from .CoCmd import CoCmd
class AppCmd(Structure):
	co: CoCmd
	rbt_power: bool
	rbt_reset: bool
	rbt_override: float
	rbt_move: int
	rbt_move_coord: list[float]
	rbt_move_fvel: float
	extra_power: bool
	extra_move_exec: bool
	extra_move_distance: float
	extra_move_velocity: float
	io: list[bool]
	_fields_ = [
		('co', CoCmd),
		('rbt_power', c_bool),
		('rbt_reset', c_bool),
		('rbt_override', c_double),
		('rbt_move', c_int16),
		('rbt_move_coord', c_double * 3),
		('rbt_move_fvel', c_double),
		('extra_power', c_bool),
		('extra_move_exec', c_bool),
		('extra_move_distance', c_double),
		('extra_move_velocity', c_double),
		('io', c_bool * 129),
	]