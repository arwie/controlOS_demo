# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

import asyncio
from mmap import mmap
from ctypes import addressof, sizeof, memmove, c_byte, c_uint8, c_int8, c_uint16, c_int16, c_uint32, c_int32
from posix_ipc import SharedMemory, Semaphore
from pathlib import Path
from functools import partial
from contextlib import closing
from threading import Thread
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


async def shell_cmd(cmd:str):
	reader, writer = await asyncio.open_unix_connection('/var/run/codesysextension/plcshell.sock')
	with closing(writer):
		writer.write(f'{cmd}\n'.encode())
		await writer.drain()
		result = await reader.readline()
		writer.write(b'reflect\n')
		await writer.drain()
		result += await reader.readuntil(b'reflect')
		return '\n'.join(l.decode() for l in result.split(b'\r\n')[:-1] if l)



class closing_fd(closing):
	def __exit__(self, *exc_info):
		self.thing.close_fd() #type:ignore


@app.context
async def exec():
	Path('/run/codesys/cfg').write_bytes(bytes(cfg))

	await shell_cmd('resetprgcold application')
	runstop_switch(True)
	await shell_cmd('startprg application')

	if not await app.poll(Path('/dev/shm/codesys').exists, timeout=30):
		raise Exception('codesys application not started')

	with (
		closing_fd(SharedMemory('/codesys')) as shm,
		closing(Semaphore('/codesys')) as sem,
		mmap(shm.fd, shm.size) as mapfile
	):
		cmd_addr, cmd_size = addressof(cmd), sizeof(cmd)
		fbk_addr, fbk_size = addressof(fbk), sizeof(fbk)
		assert shm.size >= 1 + cmd_size + fbk_size

		shm_addr = addressof(c_byte.from_buffer(mapfile))
		shm_sync_flag = c_byte.from_address(shm_addr)
		shm_cmd_addr = shm_addr + sizeof(shm_sync_flag)
		shm_fbk_addr = shm_cmd_addr + cmd_size

		def shm_sync():
			memmove(shm_cmd_addr, cmd_addr, cmd_size)
			memmove(fbk_addr, shm_fbk_addr, fbk_size)
			shm_sync_flag.value = 1
			_sync_trigger()

		def shm_sync_loop(event_loop=asyncio.get_running_loop()):
			while mapfile is not None:
				sem.acquire()
				event_loop.call_soon_threadsafe(shm_sync)

		shm_sync_thread = Thread(target=shm_sync_loop)
		shm_sync_thread.start()
		try:
			await sync()
			yield
		finally:
			mapfile = None
			sem.release() #release shm_sync_thread in case codesys application is not running
			shm_sync_thread.join()
			await asyncio.sleep(0) #allow scheduled shm_sync to run before closing mmap




SDO_TYPES = c_uint8 | c_int8 | c_uint16 | c_int16 | c_uint32 | c_int32


class EthercatDevice:

	_co_lock = asyncio.Lock()


	def __init__(self, slave:int, master:int=1):
		self.slave  = slave
		self.master = master


	async def sdo_read(self, addr: tuple[int, int], data_type: type[SDO_TYPES] = c_uint32):
		async with self._co_lock:
			return data_type(await self._sdo_exec(1, addr)).value


	async def sdo_write(self, addr: tuple[int, int], data: SDO_TYPES):
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
			return fbk.co.data
		finally:
			cmd.co.func = 0
			await sync()



class CanopenDevice(EthercatDevice):
	async def _sdo_exec(self, func, addr):
		return await super()._sdo_exec(-func, addr)
