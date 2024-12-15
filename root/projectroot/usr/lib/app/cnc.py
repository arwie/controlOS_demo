from itertools import count



class CNCProgram(list[str]):

	def __str__(self):
		return '\n'.join(f"N{num} {line}" for num,line in zip(count(), self))