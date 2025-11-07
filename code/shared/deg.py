# Copyright (c) 2023 Artur Wiebe <artur@4wiebe.de>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
# associated documentation files (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


import math


DEG2RAD = math.pi / 180
RAD2DEG = 180 / math.pi


def sin(deg:float) -> float:
	return math.sin(deg * DEG2RAD)

def cos(deg:float) -> float:
	return math.cos(deg * DEG2RAD)


def asin(x:float) -> float:
	return RAD2DEG * math.asin(x)

def acos(x:float) -> float:
	return RAD2DEG * math.acos(x)


def atan2(y:float, x:float) -> float:
	return RAD2DEG * math.atan2(y, x)


def norm(deg:float) -> float:
	"""Normalize angle to [-180:180]"""
	deg %= 360
	if deg < -180:
		deg += 360
	elif deg > 180:
		deg -= 360
	return deg

def norm360(deg:float) -> float:
	"""Normalize angle to [0:360]"""
	deg %= 360
	if deg < 0:
		deg += 360
	return deg
