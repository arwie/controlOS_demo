<?// Copyright (c) 2019 Artur Wiebe <artur@4wiebe.de>
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


function input($name, $type, $sim=false, $simio=null) {
	$io = _inout('in', $name, $type, $sim);
	
	l("public function {$io['name']} as $type");
		ll("if not {$io['ord']} then");
			lll($io['sim'] ? "{$io['name']} = {$io['io']}" : "io$name({$io['name']})");
		ll("else");
			lll("{$io['name']} = {$io['app']}");
		ll("end if");
	l("end function");
	l("public function {$io['gui']} as $type");
		ll($io['sim'] ? "{$io['gui']} = {$io['io']}" : "io$name({$io['gui']})");
		ll("if not {$io['ord']} then");
			lll("{$io['app']} = {$io['gui']}");
		ll("end if");
	l("end function");
	l("sub io$name(value_ as $type)");
	
	if ($io['sim'] && $simio)
		_simio("{$io['io']} = $simio");
}


function output($name, $type, $sim=false) {
	$io = _inout('out', $name, $type, $sim);
	
	l("public sub {$io['name']}(byval value_ as $type)");
		ll("{$io['app']} = value_");
		ll("if not {$io['ord']} then");
			if (!$io['sim']) ll("io$name(value_)"); ll("{$io['io']} = value_");
		ll("end if");
	l("end sub");
	l("public sub {$io['gui']}(byval value_ as $type)");
		if (!$io['sim']) ll("io$name(value_)"); ll("{$io['io']} = value_");
	l("end sub");
	l("sub io$name(value_ as $type)");
}


function simio() {
	if (device_simulated())
		_simio('libSimio()');
	l('sub libSimio');
}



function _inout($dir, $localName, $type, $sim) {
	static $id = 0;
	
	$name = lib().'_'.$localName;
	$sim  = device_simulated() || (is_string($sim) ? device_simulated($sim) : $sim);
	
	$io = [
		'id'		=> $id++,
		'dir'		=> $dir,
		'name'		=> $name,
		'type'		=> $type,
		'sim'		=> $sim,
		'ord'		=> "{$name}O",
		'app'		=> "{$name}A",
		'io'		=> "{$name}_",
		'gui'		=> "{$name}S",
	];
	
	common($io['ord']);
	common($io['app'], $type);
	common($io['io'],  $type);
	
	lib('debug', com_put($type, $localName, $dir=='out'?$io['app']:$name));

	set('simio')[$name] = $io;
	return $io;
}


function _simio($bit) {
	if (empty(lib('simio')))
		lib('end', function() {
			l('public sub '.lib().'_simio');
			call(lib('simio'));
			l('end sub');
		});
	lib('simio', $bit);
}
