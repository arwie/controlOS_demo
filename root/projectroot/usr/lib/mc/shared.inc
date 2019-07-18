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



function conf($file=null, $section=null, $key=null, $default=null) {
	static $conf = null;
	
	if (is_null($conf)) {
		$conf = [];
		foreach (glob('/etc/app/*.conf') as $path) {
			$conf[basename($path, '.conf')] = parse_ini_file($path, true);
		}
	}
	
	if (is_null($file))
		return $conf;
	
	if (is_null($section))
		return array_key_exists($file, $conf);
	
	if (is_null($key))
		return array_key_exists($file, $conf) && array_key_exists($section, $conf[$file]); 
	
	return (array_key_exists($file, $conf) && array_key_exists($section, $conf[$file]) && array_key_exists($key, $conf[$file][$section])) ? $conf[$file][$section][$key] : $default;
}


function setup($section=null, $key=null) {
	static $setup;
	if (!isset($setup)) {
		$setup = json_decode(exec('python -c "from shared.setup import setup; import sys,json; json.dump(setup,sys.stdout)"'), true) ?: [];
	}
	return is_null($section) ? $setup : (is_null($key) ? $setup[$section] : $setup[$section][$key]);
}


function awaitCondition($result, $condition, $timeout, $ifnot=false) {
	ll($result.' = system.clock + '.$timeout);
	ll('while not ('.$condition.') and system.clock < '.$result);
	lll('sleep '.min(100, $timeout));
	ll('end while');
	ll($result.' = '.$condition);
	if ($ifnot) {
		ll('if not '.$result.' then');
			call($ifnot);
		ll('end if');
	}
}


function debug() {
	return file_exists('/etc/app/debug');
}


function l($basic='')	{ echo $basic."\n"; }
function ll($basic)		{ echo "\t".$basic."\n"; }
function lll($basic)	{ echo "\t\t".$basic."\n"; }
function llll($basic)	{ echo "\t\t\t".$basic."\n"; }
function lllll($basic)	{ echo "\t\t\t\t".$basic."\n"; }

function s($str) {
	if (!is_string($str))
		$str = json_encode($str);
	return '"'.wordwrap(strtr($str, '`"', "'`"), 80, '"+"', true).'"';
}
function ifs($if, $then, $else='') { return $if ? $then : $else; }

function call($parts, $reverse=false) {
	if (is_array($parts)) {
		foreach ($reverse?array_reverse($parts):$parts as $k=>$v)
			if (is_int($k))
				call($v);
	} elseif (is_callable($parts)) {
		$parts();
	} elseif (is_string($parts)) {
		lll($parts);
	}
}

function hashsum($whatever) {
	if (is_callable($whatever)) {
		ob_start();
		$whatever();
		return hashsum(ob_get_clean());
	}
	return md5(serialize($whatever));
}


function dump($var, $caption='dump') {
	file_put_contents('php://stderr', $caption.":\n".print_r($var, true)."\n\n");
}
