from typing import Literal
from shared import app
from shared.app.codesys import CanopenDevice
from ctypes import c_uint8, c_uint16, c_uint32, c_int32
from shared import system
from shared.conf import Conf


POSITION_FACTOR_ROBOT = 4096 / 70

conf = Conf('/etc/app/drives.conf')
virtual = system.virtual()



class StepIM(CanopenDevice):

	def __init__(self, slave:int, name:str, rev_units:float=360):
		super().__init__(slave)
		self.name = name
		self.rev_units = rev_units
		self.pos_factor = 4096 / rev_units
		self.pos_offset = conf.getfloat(name, 'offset', fallback=0.0)


	async def initialize(self):
		if not virtual:
			self.max_current = await self.sdo_read((0x6075, 0), c_uint32)


	async def get_internal_pos(self):
		"""6064h: Position Actual Internal Value"""
		if virtual:
			return 0.0
		return await self.sdo_read((0x6064,0), c_int32) / self.pos_factor

	async def set_torque(self, torque:float=100):
		if not virtual:
			current = int(self.max_current * torque / 100)
			await robot_a.sdo_write((0x6073, 0), c_uint16(current))


	async def set_following_error(self, error:float|None=None):
		if error is None:
			error = 0.1 * self.rev_units
		if not virtual:
			error_drive = int(error * self.pos_factor)
			await robot_a.sdo_write((0x6065, 0), c_uint32(error_drive))


	async def tune(self,
		position_proportional_gain:int=10000,
		position_integral_input_saturation:int=100000,
		position_integral_gain:int=0,
		position_derivative_gain:int=0,
		position_velocity_feedforward_gain:int=256,
		velocity_loop_input_filter:int=100,
		velocity_proportional_gain:int=5000,
		velocity_integral_gain:int=5,
	):
		"""
		Tune the position and velocity control loops.
		Parameter names and default values follow the ISM CANopen object dictionary.
		"""
		await self.sdo_write((0x2022, 0), c_int32(position_proportional_gain))
		await self.sdo_write((0x2077, 0), c_int32(position_integral_input_saturation))
		await self.sdo_write((0x2020, 0), c_int32(position_integral_gain))
		await self.sdo_write((0x201E, 0), c_int32(position_derivative_gain))
		await self.sdo_write((0x2023, 0), c_int32(position_velocity_feedforward_gain))
		await self.sdo_write((0x20D9, 0), c_uint16(velocity_loop_input_filter))
		await self.sdo_write((0x2027, 0), c_int32(velocity_proportional_gain))
		await self.sdo_write((0x2026, 0), c_int32(velocity_integral_gain))


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



drive_by_name = {
	drive.name: drive for drive in (robot_a, robot_b, robot_c, conv_drive, extra_drive)
}