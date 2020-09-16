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


function async($prio='prgPriorityNormal')
{
	l('dim shared asyncBuffer   as long');
	l('dim shared asyncNotify   as long');
	l('dim shared asyncFunction as string = "{}"');
	
	lib('init', function(){
		com_openFifo('asyncBuffer');
		com_openNotify('asyncNotify');
	});
	
	lib('stopTrigger', [
		'com_store()',
		'com_send(asyncNotify)',
		'com_send(asyncBuffer)',
		'com_restore()',
	]);
	
	lib('stop', function(){
		ll('com_reset(asyncBuffer)');
		ll('asyncFunction = "{}"');
	});
	
	lib('debug', [
		'com_putJson("async/function", asyncFunction)',
		'com_putLong("async/buffer", round(com_count(asyncBuffer)/2.0))',
	]);
	
	lib('end', function() use ($prio) {
		com_prgReceive('asyncBuffer', 250, $prio);
			ll('select case receive_');
			ll('case com_receiveMessage');
				lll('asyncFunction = com_getJson("")');
				lll('select case com_getLong("/cmd")');
				lll('case -1');
					llll('com_send(asyncNotify)');
				foreach(lib('async')['functions'] as $f) {
					lll('case '.$f['cmd']);
					llll($f['nameSync'].$f['comGet']);
				}
				lll('end select');
				lll('asyncFunction = "{}"');
			ll('end select');
		l('end sub');
	
		l('public function '.lib().'_asyncBusy as long');
			ll(lib().'_asyncBusy = com_count(asyncBuffer)>0');
		l('end function');
	
		l('public sub '.lib().'_asyncWait');
			ll('if '.lib().'_asyncBusy then');
				lll('com_reset(asyncNotify)');			//race with stopTrigger!
				lll('if '.lib().'_active then');
					llll('com_store()');
					llll('asyncExec(-1)');
					call(['while not com_receive(asyncNotify, 100) and '.lib().'_active', 'end while']);
				lll('end if');
			ll('end if');
			call(['if not '.lib().'_active then', 'throw errorApplication', 'end if']);
		l('end sub');
	
		l('sub asyncExec(byval cmd_ as long)');
			ll('com_putLong("/cmd", cmd_)');
			ll('com_send(asyncBuffer)');
			ll('com_clear()');
			ll('com_send(asyncBuffer)');	//send notify after each function
			ll('com_restore()');
		l('end sub');
	});
}


function async_function($name, $args=[], $pre=false, $post=false)
{
	foreach ($args as $arg=>$type) {
		if ($type) {
			$params[] = $paramsPure[] = 'byval '.$arg.' as '.(is_string($type)?$type:$type[0]);
			$paramsCall[] = $arg;
			$comPut[] = (is_string($type)?'com_put'.$type:$type[1]).'("/args/'.$arg.'", '.$arg.')';
			$comGet[] = (is_string($type)?'com_get'.$type:$type[2]).'("/args/'.$arg.'")';
		} else {
			$paramsPure[] = $arg;
		}
	}
	
	$pp = function($tokens, $pp=true) { return $tokens ? '('.implode(', ', $tokens).')' : ($pp ? '()':''); };
	
	$f = [
		'name'			=> $name,
		'nameSync'		=> $name.'_',
		'cmd'			=> count(lib('async')['functions']?:[]),
		'comGet'		=> $pp($comGet),
	];
	lib('async')['functions'][] = $f;
	
	l('public sub '.lib().'_'.$f['name'].$pp($paramsPure, false));
	call($pre);
	ll('if '.lib().'_started then');
	lll('com_store()');
	lll('com_putString("/function", "'.$name.'")');
	foreach ($comPut?:[] as $p) lll($p);
	lll('asyncExec('.$f['cmd'].')');
	if ($post) lll(lib().'_asyncWait()');
	ll('else');
	lll($f['nameSync'].$pp($paramsCall));
	ll('end if');
	call($post);
	l('end sub');
	
	l('sub '.$f['nameSync'].$pp($params, false));
}


function async_call($name, $args='') {
	ll("{$name}_({$args})");
}
