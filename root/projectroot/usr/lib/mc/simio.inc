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


function input($name, $type, $sim=false, $default=null) {
	$io = simio('in', $name, $type, $sim, $default);
	
	l('public function '.$io['name'].' as '.$type);
	ll('if not '.$io['ord'].' then');
	lll('call '.$io['get'].'('.$io['name'].')');
	ll('else');
	lll($io['name'].' = '.$io['app']);
	ll('end if');
	l('end function');
	l('public sub '.$io['get'].'(value_ as '.$type.')');
}


function output($name, $type, $sim=false, $default=null) {
	$io = simio('out', $name, $type, $sim, $default);
	
	l('public sub '.$io['name'].'(byval value_ as '.$type.')');
	ll('if not '.$io['ord'].' then');
	lll('call '.$io['set'].'(value_)');
	lll($io['app'].' = value_');
	lll($io['io'].'  = value_');
	ll('else');
	lll($io['app'].' = value_');
	ll('end if');
	l('end sub');
	l('public sub '.$io['set'].'(value_ as '.$type.')');
}


function simio($dir, $localName, $type, $sim, $default) {
	static $id = 0;
	
	$name = lib().'_'.$localName;
	$sim  = device_simulated(lib()) || (is_string($sim) ? device_simulated($sim) : $sim);
	
	$io = [
		'id'		=> $id++,
		'dir'		=> $dir,
		'name'		=> $name,
		'type'		=> $type,
		'sim'		=> $sim,
		'default'	=> $default,
		'ord'		=> "{$name}O",
		'app'		=> "{$name}A",
		'io'		=> "{$name}I",
		'get'		=> "{$name}G",
		'set'		=> "{$name}S",
	];

	lib('debug', 'call com_put'.ucfirst($type).'("'.$localName.'", '.($dir=='out'?$io['app']:$name).')');

	set('simio')[$name] = $io;
	return $io;
}
