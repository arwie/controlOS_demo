from ctypes import *  #type:ignore
class CoFbk(Structure):
	data: int
	done: bool
	error: bool
	_fields_ = [
		('data', c_uint32),
		('done', c_bool),
		('error', c_bool),
	]