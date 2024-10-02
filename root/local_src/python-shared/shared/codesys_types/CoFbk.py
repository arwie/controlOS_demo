from ctypes import *  #type:ignore
class CoFbk(Structure):
	done: bool
	error: bool
	_fields_ = [
		('done', c_bool),
		('error', c_bool),
	]