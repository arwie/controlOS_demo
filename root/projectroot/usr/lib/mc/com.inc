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
	llll('call comPrgReceive(receive_)');
	lll('end if');
	ll('end while');
	l('end sub');
	l('sub comPrgReceive(byval receive_ as long)');
}



function com_websocket($port, $args=[], $name=false)
{
	if (!$name) {
		$name = 'this_websocket';
		l('dim shared '.$name.' as long');
	}
	
	lib('start', function() use ($port, $args, $name) {
		com_openWebsocket($name, $port, $args);
	});
	
	lib('stopTrigger', function() use ($name) {
		lll('call com_clear');
		lll('call com_sendSelf('.$name.')');
	});
	
	lib('stop', function() use ($name) {
		lll('call com_close('.$name.')');
	});
}



function com_send($name, $message) {
	call(['com_clear()', $message, "com_send({$name})"]);
}



function com_open($name, $type, $args=false) {
	lll('call com_clear');
	lll('call com_putString("/log/lib",  "'.lib().'")');
	lll('call com_putString("/log/name", "'.$name.'")');
	call($args);
	lll($name.' = com_open(com_channel'.ucfirst($type).')');
}

function com_openWebsocket($name, $port, $args=[]) {
	com_open($name, 'websocket', function() use ($port, $args) {
		lll('call com_putLong("/port", '.$port.')');
		foreach ($args as $arg=>$value) {
			switch ($arg) {
				case 'receive': lll('call com_putBool("/receive", '.$value.')'); break;
			}
		}
	});
}

function com_openFifo($name) {
	com_open($name, 'fifo');
}

function com_openNotify($name) {
	com_open($name, 'notify');
}

function com_openFile($name, $filename) {
	com_open($name, 'file', 'call com_putString("/file", '.s($filename).')');
}
