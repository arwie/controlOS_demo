from typing import Literal
from shared import app
from shared.app.codesys import CanopenDevice
from ctypes import c_uint8, c_uint16, c_uint32
from shared import system


POSITION_FACTOR_ROBOT = 4096 / 70

virtual = system.virtual()



class StepIM(CanopenDevice):

	def __init__(self, slave:int, name:str, rev_units:float=360):
		super().__init__(slave)
		self.name = name
		self.pos_factor = 4096 / rev_units


	async def initialize(self):
		if not virtual:
			self.max_current = await self.sdo_read((0x6075, 0))


	async def set_torque(self, torque:float=100):
		if not virtual:
			current = int(self.max_current * torque / 100)
			await robot_a.sdo_write((0x6073, 0), c_uint16(current))


	async def set_following_error(self, error:float):
		if not virtual:
			error_drive = int(error * self.pos_factor)
			await robot_a.sdo_write((0x6065, 0), c_uint32(error_drive))


	async def set_baud_rate(self, baud_rate:Literal[1000,500,250]):
		"""
		Set the baud rate of the drive in the CANopen network.
		
		:param baud_rate: CAN Baud rate in Kbit/s
		"""
		values = {
			1000:	0,
			500:	2,
			250:	3,
		}
		await self.sdo_write((0x2F1F,0), c_uint16(values[baud_rate]))
		await self._save()


	async def _save(self):
		await self.sdo_write((0x1010,1), c_uint32(0x65766173))
		await app.sleep(3)



class RobotDrive(StepIM):
	pass


robot_a = RobotDrive(1, 'Robot_A', 70)
robot_b = RobotDrive(2, 'Robot_B', 70)
robot_c = RobotDrive(3, 'Robot_C', 70)

conv_drive  = StepIM(4, 'Conv', 20)
extra_drive = StepIM(5, 'Extra')



async def initialize():
	for drive in (robot_a, robot_b, robot_c):
		await drive.initialize()

	await app.sleep(1) # drives jump if enabled too soon (Servotronix bug)
