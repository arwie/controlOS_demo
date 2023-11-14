// Copyright (c) 2023 Artur Wiebe <artur@4wiebe.de>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
// associated documentation files (the "Software"), to deal in the Software without restriction,
// including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


{attribute 'global_init_slot' := '100'}
PROGRAM app

VAR_OUTPUT
	setup: Setup;
	cmd: Cmd;
END_VAR
VAR_INPUT
	fbk: Fbk;
END_VAR

VAR
	shm: RTS_IEC_HANDLE;
	sem: RTS_IEC_HANDLE;
	iec_result: RTS_IEC_RESULT;
	conflicts: UDINT := 0;
END_VAR

VAR //must be the last variable
	_init: BOOL := init();
END_VAR


IF SysSemProcessEnter(sem, 0) = 0 THEN
	SysSharedMemoryRead (shm,           0, ADR(cmd), SIZEOF(Cmd), ADR(iec_result));
	SysSharedMemoryWrite(shm, SIZEOF(Cmd), ADR(fbk), SIZEOF(Fbk), ADR(iec_result));
	SysSemProcessLeave(sem);
ELSE
	conflicts := conflicts + 1;
END_IF



METHOD init: BOOL
VAR
	shm_size: __UXINT := SIZEOF(Fbk) + SIZEOF(Cmd);
	setup_fh: RTS_IEC_HANDLE;
END_VAR

init := TRUE;

shm := SysSharedMemoryCreate('codesys', 0, ADR(shm_size), ADR(iec_result));	
sem := SysSemProcessCreate('codesys', ADR(iec_result));

setup_fh := SysFileOpen('/run/codesys/setup', SysFile.ACCESS_MODE.AM_READ, ADR(iec_result));
SysFileRead(setup_fh, ADR(setup), SIZEOF(setup), ADR(iec_result));
SysFileClose(setup_fh);
