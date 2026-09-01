from ctypes import *  #type:ignore
class CoCmd(Structure):
	func: int
	master: int
	slave: int
	index: int
	subIndex: int
	dataLength: int
	data: int
	_fields_ = [
		('func', c_int16),
		('master', c_uint8),
		('slave', c_uint16),
		('index', c_uint16),
		('subIndex', c_uint8),
		('dataLength', c_uint8),
		('data', c_uint32),
	]