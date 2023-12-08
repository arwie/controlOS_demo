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
from ctypes import addressof, sizeof, memmove, c_char
import posix_ipc
from pathlib import Path
from functools import wraps
from shared.codesys import parse_struct, runstop_switch
from . import app


cfg = parse_struct('AppCfg')()
cmd = parse_struct('AppCmd')()
fbk = parse_struct('AppFbk')()


sync_event = app.Event()
sync = sync_event.wait


@wraps(app.poll)
async def poll(condition, **kwargs):
	await sync() #cmd -> codesys
	await sync() #codesys -> fbk
	return await app.poll(condition, period=sync, **kwargs)



runstop_switch(False)

@app.context
async def exec(period:float):
	cfg_path = Path('/run/codesys/cfg')
	cfg_path.write_bytes(bytes(cfg))
	runstop_switch(True)
	try:
		if not await app.poll(lambda: Path('/dev/shm/codesys').exists(), timeout=30):
			raise Exception('codesys application not started')
		sem = posix_ipc.Semaphore('/codesys')
		shm = posix_ipc.SharedMemory('/codesys')
		try:
			with mmap.mmap(shm.fd, shm.size) as mapfile:
				cmd_addr, cmd_size = addressof(cmd), sizeof(cmd)
				fbk_addr, fbk_size = addressof(fbk), sizeof(fbk)
				shm_cmd_addr = addressof((c_char*shm.size).from_buffer(mapfile))
				shm_fbk_addr = shm_cmd_addr + cmd_size

				async def link_loop():
					while True:
						with sem:
							memmove(shm_cmd_addr, cmd_addr, cmd_size)
							memmove(fbk_addr, shm_fbk_addr, fbk_size)
						sync_event.trigger()
						await asyncio.sleep(period)

				async with app.task_group(link_loop()):
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



async def co_sdo_write(device, index, sub_index, data_length, data):
	cmd.co.func = 1
	cmd.co.device = device
	cmd.co.index = index
	cmd.co.subIndex = sub_index
	cmd.co.dataLength = data_length
	cmd.co.data = data
	cmd.co.exec = True
	try:
		await poll(lambda: fbk.co.done)
	finally:
		cmd.co.exec = False
		await sync()
		cmd.co.func = 0