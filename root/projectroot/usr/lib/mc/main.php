<?// Copyright (c) 2016 Artur Wiebe <artur@4wiebe.de>
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


require 'shared.inc';


function &set($what, $set=true) { global $out;
	static $real, $fake;
	
	if ($out && $set) 
		return $fake;
	
	$real[$what] = $real[$what] ?: [];
	return $real[$what];
}
function get($what) {
	return set($what, false);
}


set('mc')['type'] = $argv[2];


function common($name, $type='long', $init=null) {
	if (strpos($name, '_')===false)
		$name = lib().'_'.$name;
	set('init')['begin'][] = "common shared $name as $type".($init ? " = $init" : '');
}


require 'lib.inc';
require 'com.inc';
require 'device.inc';
require 'axis.inc';
require 'robot.inc';
require 'simio.inc';
require 'async.inc';


function includeLib($file, $from=null, $type='app') {
	libBegin($file, $from, $type);
	l("'--------------------");
	l('');
	include $from ?: $file;
	l('');
	l("'--------------------");
	libEnd();
}


ob_start();

include 'config.inc';

includeLib('LOG.LIB',      null, 'system');
includeLib('STATE.LIB',    null, 'system');
includeLib('INIT.LIB',     null, 'system');
includeLib('ETC.LIB',      null, 'system');
includeLib('CAN.LIB',      null, 'system');
includeLib('DRIVELOG.LIB', null, 'system');
includeLib('SIMIO.LIB',    null, 'system');
includeLib('DEBUG.LIB',    null, 'system');
includeLib('SYSTEM.LIB',   null, 'system');

ob_end_clean();



$out = $argv[1].'/SSMC/';
if (!is_dir($out)) mkdir($out);

foreach (get('lib') as $lib) {
	ob_start();
	includeLib($lib['file'], $lib['from'], $lib['type']);
	file_put_contents($out.$lib['file'], ob_get_clean());
	
	if ($lib['prg']) {
		ob_start();
		libPrg($lib);
		file_put_contents($out.$lib['prg']['file'], ob_get_clean());
	}
}

foreach(glob('*.PRG') as $file) {
	ob_start();
	include $file;
	file_put_contents($out.$file, ob_get_clean());
}


ob_start();
	l('DIP=0xFF');
	l('INP=0x0');
file_put_contents($out.'IO.DAT', ob_get_clean());

ob_start();
	l('ipaddressmask '.gethostbyname('mc').':255.255.255.0');
	l('defaultgw '.gethostbyname('sys'));
file_put_contents($argv[1].'/FWCONFIG', ob_get_clean());


function linkStatic($dir) { global $out;
	foreach(array_filter(glob(getcwd()."/static/{$dir}/*"), 'is_file') as $file) {
		symlink($file, $out.basename($file));
	}
}
linkStatic('');
linkStatic(get('mc')['type']);
