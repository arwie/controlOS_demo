<?// Copyright (c) 2018 Artur Wiebe <artur@4wiebe.de>
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


function com_prgReceive($name, $timeout=250, $prio='prgPriorityNormal') {
	lib_prg($prio);
	ll('dim receive_ as long');
	ll('while '.lib().'_active');
	lll('receive_ = com_receive('.$name.', '.$timeout.')');
	lll('if '.lib().'_active then');
	llll('comPrgReceive(receive_)');
	lll('end if');
	ll('end while');
	l('end sub');
	l('sub comPrgReceive(byval receive_ as long)');
}



function com_websocket($port, $args=[], $name=false)
{
	if (!$name) {
		$name = 'this_websocket';
		l("dim shared {$name} as long");
	}
	lib('start', function() use ($port, $args, $name) {
		com_openWebsocket($name, $port, $args);
	});
	lib('stopTrigger', ['com_store()', "com_sendSelf({$name})", 'com_restore()']);
	lib('stop','com_close('.$name.')');
}

function com_udpReceiver($port, $name=false)
{
	if (!$name) {
		$name = 'this_udpReceiver';
		l("dim shared {$name} as long");
	}
	lib('start', function() use ($port, $name) {
		com_openUdpReceiver($name, $port);
	});
	lib('stopTrigger', ['com_store()', "com_sendSelf({$name})", 'com_restore()']);
	lib('stop','com_close('.$name.')');
}

function com_fifo($name=false)
{
	if (!$name) {
		$name = 'this_fifo';
		l("dim shared {$name} as long");
	}
	lib('start', function() use ($name) {
		com_openFifo($name);
	});
	lib('stopTrigger', ['com_store()', "com_send({$name})", 'com_restore()']);
	lib('stop', 'com_close('.$name.')');
}



function com_open($name, $type, $args=false) {
	lll('com_clear()');
	lll('com_putString("/log/lib",  "'.lib().'")');
	lll('com_putString("/log/name", "'.$name.'")');
	call($args);
	lll($name.' = com_open(com_channel'.ucfirst($type).')');
}

function com_openWebsocket($name, $port, $args=[]) {
	com_open($name, 'websocket', function() use ($port, $args) {
		lll('com_putLong("/port", '.$port.')');
		foreach ($args as $arg=>$value) {
			switch ($arg) {
				case 'receive': lll('com_putBool("/receive", '.$value.')'); break;
			}
		}
	});
}

function com_openUdpSender($name, $address, $port) {
	com_open($name, 'udpSender', ['com_putString("/address",'.s($address).')', 'com_putLong("/port",'.$port.')']);
}
function com_openUdpReceiver($name, $port) {
	com_open($name, 'udpReceiver', ['com_putLong("/port",'.$port.')']);
}

function com_openFifo($name) {
	com_open($name, 'fifo');
}

function com_openNotify($name) {
	com_open($name, 'notify');
}

function com_openFile($name, $filename) {
	com_open($name, 'file', 'com_putString("/file", '.s($filename).')');
}



function com_with($with) {
	return 'com_with('.s($with).')';
}

function com_put($type, $path, $value) {
	return 'com_put'.ucfirst($type).'('.s($path).','.$value.')';
}
function com_putLong($path, $value)		{ return com_put('long', $path, $value); }
function com_putBool($path, $value)		{ return com_put('bool', $path, $value); }
function com_putDouble($path, $value)	{ return com_put('double', $path, $value); }
function com_putString($path, $value, $literal=true)	{ return com_put('string', $path, $literal?s($value):$value); }

function com_get($type, $path) {
	return 'com_get'.ucfirst($type).'('.s($path).')';
}
