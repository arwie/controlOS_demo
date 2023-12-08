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


import ctypes
import re
from pathlib import Path
from configparser import ConfigParser
from functools import cache


PLC_LOGIC_PATH = '/opt/codesys/PlcLogic'


@cache
def application():
	cmp_app = ConfigParser()
	cmp_app.read(Path(PLC_LOGIC_PATH, 'CmpApp.cfg'))
	return cmp_app['CmpApp']['Application.1']


types = {
	'BOOL':		ctypes.c_bool,
	'SINT':		ctypes.c_int8,
	'INT':		ctypes.c_int16,
	'DINT':		ctypes.c_int32,
	'LINT':		ctypes.c_int64,
	'USINT':	ctypes.c_uint8,
	'BYTE':		ctypes.c_uint8,
	'UINT':		ctypes.c_uint16,
	'WORD':		ctypes.c_uint16,
	'UDINT':	ctypes.c_uint32,
	'DWORD':	ctypes.c_uint32,
	'ULINT':	ctypes.c_uint64,
	'LWORD':	ctypes.c_uint64,
	'REAL':		ctypes.c_float,
	'LREAL':	ctypes.c_double,
}


def parse_struct(name:str) -> type[ctypes.Structure]:
	struct = Path(PLC_LOGIC_PATH, application(), f'{name}.struct').read_text()
	
	def ctype(codesys_type):
		array_length = None
		if array := re.search(r'ARRAY \[(\d+)\.\.(\d+)\] OF (\w+)', codesys_type):
			codesys_type = array.group(3)
			array_length = int(array.group(2)) - int(array.group(1)) + 1
		if codesys_type not in types:
			types[codesys_type] = parse_struct(codesys_type)
		return types[codesys_type] * array_length if array_length else types[codesys_type]
	
	return type(
		name,
		(ctypes.Structure, ),
		{'_fields_': [(f[0], ctype(f[1])) for f in re.findall(r'^\s*(\w+)\s*:\s*(.+)\s*;', struct, re.MULTILINE)]},
	)


def runstop_switch(run:bool):
	Path('/var/opt/codesysextension/runstop.switch').write_bytes(b'RUN' if run else b'STOP')