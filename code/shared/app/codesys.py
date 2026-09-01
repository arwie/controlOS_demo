# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

import asyncio
from ctypes import sizeof, byref, memmove, c_uint8, c_int8, c_uint16, c_int16, c_uint32, c_int32
from pathlib import Path
from contextlib import closing
from shared.condition import poll
from shared.asyncio import Trigger, asyncio_loop
from shared.iceoryx.pubsub import IoxPublisher, IoxSubscriber
from shared.iceoryx.event import IoxListener
from shared.topics.codesys import AppCfg, AppCmd, AppFbk, codesys_cmd_pubsub, codesys_fbk_pubsub, codesys_fbk_event
from . import app


cfg = AppCfg()
cmd = AppCmd()
fbk = AppFbk()

fbk_trigger: Trigger


def runstop_switch(run:bool):
	Path('/var/opt/codesyscontrolapi/runstop.switch').write_bytes(b'RUN' if run else b'STOP')


async def shell_cmd(cmd:str):
	reader, writer = await asyncio.open_unix_connection('/var/opt/codesyscontrolapi/plcshell.sock')
	with closing(writer):
		writer.write(f'{cmd}\n'.encode())
		await writer.drain()
		result = await reader.readline()
		writer.write(b'reflect\n')
		await writer.drain()
		result += await reader.readuntil(b'reflect')
		return '\n'.join(l.decode() for l in result.split(b'\r\n')[:-1] if l)



@app.context
async def exec():
	Path('/run/codesys/cfg').write_bytes(bytes(cfg))

	await shell_cmd('resetprgcold application')
	runstop_switch(True)
	await shell_cmd('startprg application')

	class FbkListener(IoxListener):
		def handle(self, event_id):
			if fbk_sample := fbk_subscriber.receive():
				memmove(byref(fbk), fbk_sample.payload(), sizeof(fbk))
				self()
				asyncio_loop.call_soon(cmd_publischer.send_copy, cmd)

	global fbk_trigger
	with (
		IoxSubscriber(codesys_fbk_pubsub) as fbk_subscriber,
		IoxPublisher(codesys_cmd_pubsub) as cmd_publischer,
		FbkListener(codesys_fbk_event) as fbk_trigger
	):
		yield




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
			await poll(lambda: not (fbk.co.done or fbk.co.error), fbk_trigger, timeout=1)



class CanopenDevice(EthercatDevice):
	async def _sdo_exec(self, func, addr):
		return await super()._sdo_exec(-func, addr)
