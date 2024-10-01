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


import asyncio
import mmap
from ctypes import addressof, sizeof, memmove, c_byte, c_uint8, c_uint16, c_uint32
import posix_ipc
from pathlib import Path
from functools import partial
from shared.codesys_types import AppCfg, AppCmd, AppFbk
from . import app


cfg = AppCfg()
cmd = AppCmd()
fbk = AppFbk()


_sync_trigger = app.Trigger()


poll = partial(app.poll, period=_sync_trigger)

async def sync():
	await _sync_trigger.wait() #cmd -> codesys
	await _sync_trigger.wait() #codesys -> fbk



def runstop_switch(run:bool):
	Path('/var/opt/codesysextension/runstop.switch').write_bytes(b'RUN' if run else b'STOP')



@app.context
async def exec(period:float):
	cfg_path = Path('/run/codesys/cfg')
	cfg_path.write_bytes(bytes(cfg))
	runstop_switch(True)
	try:
		if not await app.poll(lambda: Path('/dev/shm/codesys').exists(), timeout=90):
			raise Exception('codesys application not started')
		sem = posix_ipc.Semaphore('/codesys')
		shm = posix_ipc.SharedMemory('/codesys')
		try:
			with mmap.mmap(shm.fd, shm.size) as mapfile:
				cmd_addr, cmd_size = addressof(cmd), sizeof(cmd)
				fbk_addr, fbk_size = addressof(fbk), sizeof(fbk)
				assert shm.size >= cmd_size + fbk_size
				shm_cmd_addr = addressof(c_byte.from_buffer(mapfile))
				shm_fbk_addr = addressof(c_byte.from_buffer(mapfile, cmd_size))

				async def sync_loop():
					while True:
						with sem:
							memmove(shm_cmd_addr, cmd_addr, cmd_size)
							memmove(fbk_addr, shm_fbk_addr, fbk_size)
						_sync_trigger()
						await asyncio.sleep(period)

				async with app.task_group(sync_loop):
					try:
						yield
					finally:
						await sync()
		finally:
			shm.close_fd()
			sem.close()
	finally:
		runstop_switch(False)
		await app.poll(lambda: not cfg_path.exists(), timeout=10)




class EthercatDevice:

	_co_lock = asyncio.Lock()


	def __init__(self, slave:int, master:int=1):
		self.slave  = slave
		self.master = master


	async def sdo_write(self, addr:tuple[int, int], data: c_uint8 | c_uint16 | c_uint32):
		async with self._co_lock:
			cmd.co.dataLength = sizeof(data)
			cmd.co.data = data.value
			await self._sdo_exec(2, addr)


	async def _sdo_exec(self, func:int, addr:tuple[int, int]):
		cmd.co.func = func
		cmd.co.master = self.master
		cmd.co.slave = self.slave
		cmd.co.index, cmd.co.subIndex = addr
		try:
			if not await poll(lambda: fbk.co.done, abort=lambda: fbk.co.error):
				raise Exception(f'SDO access error: {self.slave} > {hex(addr[0])}:{addr[1]}')
		finally:
			cmd.co.func = 0
			await sync()



class CanopenDevice(EthercatDevice):
	async def _sdo_exec(self, func, addr):
		return await super()._sdo_exec(-func, addr)
