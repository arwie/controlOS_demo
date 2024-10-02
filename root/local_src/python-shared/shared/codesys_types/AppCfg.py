from ctypes import *  #type:ignore
class AppCfg(Structure):
	foo: float
	bar: int
	zoo: bool
	_fields_ = [
		('foo', c_double),
		('bar', c_int16),
		('zoo', c_bool),
	]