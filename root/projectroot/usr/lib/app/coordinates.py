from __future__ import annotations
from typing import TYPE_CHECKING
if TYPE_CHECKING:
	from collections.abc import Mapping

from math import sqrt
from dataclasses import dataclass, asdict
from shared import deg



@dataclass
class Axes:
	a: float = 0
	b: float = 0
	c: float = 0

	def asdict(self):
		return asdict(self)

	def __add__(self, other:Axes):
		return Axes(
			a = self.a + other.a,
			b = self.b + other.b,
			c = self.c + other.c,
		)

	def __sub__(self, other:Axes):
		return Axes(
			a = self.a - other.a,
			b = self.b - other.b,
			c = self.c - other.c,
		)

	def __mul__(self, factor:float):
		return Axes(
			a = self.a * factor,
			b = self.b * factor,
			c = self.c * factor,
		)

	def __truediv__(self, divisor:float):
		return Axes(
			a = self.a / divisor,
			b = self.b / divisor,
			c = self.c / divisor,
		)



@dataclass
class Pos:
	x: float = 0
	y: float = 0
	z: float = 0
	r: float = 0

	@classmethod
	def from_dict(cls, data:Mapping[str, float]):
		return Pos(
			x = float(data['x']),
			y = float(data['y']),
			z = float(data['z']),
			r = float(data['r']),
		)

	def asdict(self):
		return asdict(self)

	def __add__(self, other:Pos):
		return Pos(
			x = self.x + other.x,
			y = self.y + other.y,
			z = self.z + other.z,
			r = self.r + other.r,
		)

	def __sub__(self, other:Pos):
		return Pos(
			x = self.x - other.x,
			y = self.y - other.y,
			z = self.z - other.z,
			r = self.r - other.r,
		)

	def __mul__(self, factor:float):
		return Pos(
			x = self.x * factor,
			y = self.y * factor,
			z = self.z * factor,
			r = self.r * factor,
		)

	def __invert__(self):
		"""Return inverted Pos instance"""
		sr, cr = deg.sin(-self.r), deg.cos(-self.r)
		return Pos(
			x = -cr*self.x + sr*self.y,
			y = -sr*self.x - cr*self.y,
			z = -self.z,
			r = -self.r,
		)

	def __matmul__(self, other:Pos):
		"""Transform other Pos p"""
		sr, cr = deg.sin(self.r), deg.cos(self.r)
		return Pos(
			x = self.x + cr*other.x - sr*other.y,
			y = self.y + sr*other.x + cr*other.y,
			z = self.z + other.z,
			r = deg.norm(self.r + other.r),
		)

	def __or__(self, other:Pos) -> float:
		"""Cartesian distance"""
		return sqrt((self.x-other.x)**2 + (self.y-other.y)**2 + (self.z-other.z)**2)
