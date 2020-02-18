<?// Copyright (c) 2020 Artur Wiebe <artur@4wiebe.de>
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


function libBegin($file, $from, $type) { global $lib;
	$lib = [
		'file'	=> basename($file),
		'name'	=> strtolower(basename($file, '.LIB')),
		'from'	=> $from,
		'type'	=> $type,
	];

	l('common shared '.$lib['name'].'_active  as long');
	l('dim shared lib_activeNotify as long');
}

function &lib($what='name', $add=false) { global $lib;
	if ($add) $lib[$what][] = $add; else return $lib[$what];
}
function libGet($what) {
	return get('lib')[lib()][$what];
}


function engage($libs) {
	$libs = array_filter($libs, function($lib) { return $lib && array_key_exists($lib, get('lib')); });
	lib('start', function() use ($libs) {
		foreach ($libs as $l) lll('call '.$l.'_start');
	});
	$libs = array_reverse($libs);
	lib('stop', function() use ($libs) {
		foreach ($libs as $l) lll('call '.$l.'_stopTrigger');
		foreach ($libs as $l) lll('call '.$l.'_stop');
	});
}

function waitActive($lib, $while='true', $interval=100) {
	lll('while '.lib().'_active and not '.$lib.'_wait('.$interval.') and ('.$while.')');
	lll('end while');
	if ($lib != lib())
		lib('stopTrigger', $lib.'_stopTrigger()');
}
function engageActive($lib, $while='true', $interval=100) {
	lll($lib.'_start()');
	waitActive($lib, $while, $interval);
	lll($lib.'_stop()');
}

function logMessage($prio, $message=null, $report=null, $log=[]) {
	if (is_array($message)) {
		$log = $message;
	} else {
		if (is_array($report)) {
			$log = $report;
		} else {
			if (is_string($report))
				$log['report'] = strpos($report,'"')===false ? s($report) : $report;
		}
		if (is_string($message))
			$log['message'] = strpos($message,'"')===false ? s($message) : $message;
	}
	if (!$log['message']) {
		$log['message'] = 'taskerror(programname)';
		$extra[] = 'com_putLong("/error", taskerrornumber(programname))';
	}
	ll("log_message($prio, {$log['message']})");
	if ($log['report']) {
		$extra[] = "log_putReport({$log['report']})";
	}
	unset($log['message'], $log['report']);
	if ($log) {
		$extra[] = ['try', $log, 'catch else', 'end try'];
	}
	call($extra);
	ll(lib().'_putDebug(true)');
	ll('log_putCodeFunc(scope)');
	ll('com_putString("/lib", '.s(lib()).')');
	ll('log_send()');
}
function logCritical($message=null, $report=null, $log=[]) { logMessage(2, $message, $report, $log); }
function logError   ($message=null, $report=null, $log=[]) { logMessage(3, $message, $report, $log); }
function logWarning ($message=null, $report=null, $log=[]) { logMessage(4, $message, $report, $log); }
function logNotice  ($message=null, $report=null, $log=[]) { logMessage(5, $message, $report, $log); }
function logInfo    ($message=null, $report=null, $log=[]) { logMessage(6, $message, $report, $log); }
function logDebug   ($message=null, $report=null, $log=[]) { logMessage(7, $message, $report, $log); }

function throwLog($message=null, $report=null, $log=[]) {
	logError($message, $report, $log);
	ll('throw errorApplication');
}

function catchLog($log=[], $finally=false) {
	ll('catch errorApplication.num');
	ll('catch else');
	logError(false, null, $log);
	if ($finally) {
		ll('finally');
		call($finally);
	}
	ll('end try');
}
function catchThrowLog($log=[], $finally=false) {
	catchLog($log, [$finally, 'throw errorApplication']);
}
function catchThrowAlwaysLog($always, $log=[]) {
	catchThrowLog($log, $always);
	call($always);
}


function lib_init() {
	lib('init', 'call libInit');
	l('sub libInit');
}


function lib_start() {
	lib('start', 'call libStart');
	l('sub libStart');
}


function lib_stopTrigger() {
	lib('stopTrigger', 'call libStopTrigger');
	l('sub libStopTrigger');
}


function lib_stop() {
	lib('stop', 'call libStop');
	l('sub libStop');
}


function lib_prg($prio='prgPriorityNormal') {
	lib('prg')['name'] = lib();
	lib('prg')['file'] = strtoupper(lib().'.PRG');
	lib('prg')['prio'] = $prio;
	l('public sub '.lib().'_prg');
}
function lib_prgPoll($interval, $prio='prgPriorityNormal') {
	lib_prg($prio);
	ll('do');
	lll('call prgLoop');
	if ($interval)
		ll('loop until com_receive(lib_activeNotify, '.$interval.')');
	else
		ll('loop while '.lib().'_active');
	l('end sub');
	l('sub prgLoop');
}
function lib_prgLoop($prio='prgPriorityNormal') {
	lib_prgPoll(false, $prio);
}

function lib_prgStart() {
	lib('prgStart', 'call libPrgStart');
	l('sub libPrgStart');
}

function lib_prgStop() {
	lib('prgStop', 'call libPrgStop');
	l('sub libPrgStop');
}

function lib_prgEvent($scantime=5) { global $lib;
	$lib['prg']['event'] = $scantime;
	l('public sub '.$lib['name'].'_prgEvent');
}

function lib_prgError($log=false) {
	lib('prgError')['log'] = $log;
	lib('prgError', 'call lib_prgError');
	l('sub lib_prgError');
}


function lib_debug($ext=[]) {
	lib('debug', 'libPutDebug()');
	foreach ($ext as $l)
		if (array_key_exists($l, get('lib')))
			lib('debugExt', $l);
	l('sub libPutDebug');
}


function lib_systemError($errors, $log=false) {
	foreach ($errors as $e) lib('systemError', $e);
	l('public sub '.lib().'_systemError');
	logError(['message'=>'system.error', 'com_putLong("/error", system.errornumber)', $log]);
	ll('call lib_systemError');
	l('end sub');
	l('sub lib_systemError');
}



function libEnd() { global $lib;
	call(lib('end'));
	
	l('public sub '.$lib['name'].'_init');
	com_openNotify('lib_activeNotify');
	if ($lib['prg'] && $lib['prg']['prio']) {
		ll('load '.$lib['prg']['file'].' priority = '.$lib['prg']['prio']);
		foreach ($lib['prg']['threads']?:[] as $thread)
			ll('load '.$thread['file'].' priority = '.$thread['prio']);
	}
	call(lib('init'));
	l('end sub');
	
	l('public sub '.$lib['name'].'_start');
	ll('if not '.$lib['name'].'_started then');
	call(lib('start'));
	lll($lib['name'].'_started = true');
	lll('call com_sendSelf(state_websocket)');
	lll($lib['name'].'_active = true');
	lll('call com_reset(lib_activeNotify)');
	if ($lib['prg']) {
		lll('starttask '.$lib['prg']['file']);
	}
	logInfo(lib().' started');
	ll('end if');
	l('end sub');

	l('public sub '.lib().'_stopTrigger');
	ll('if '.lib().'_active then');
	lll(lib().'_active = false');
	lll('call com_send(lib_activeNotify)');
	call(lib('stopTrigger'), true);
	ll('end if');
	l('end sub');

	l('public function '.$lib['name'].'_wait(byval timeout_ as long) as long');
	ll($lib['name'].'_wait = com_receive(lib_activeNotify, timeout_)');
	l('end function');

	l('public sub '.$lib['name'].'_stop');
	ll('if '.$lib['name'].'_started then');
	lll('call '.$lib['name'].'_stopTrigger');
	if (lib('prg')) {
		lll('while ('.lib('prg')['file'].'.state band 0x0F)=TASK_RUNNING or ('.lib('prg')['file'].'.state band 0x100)');
		llll('sleep 1');
		lll('end while');
		lll('while '.lib('prg')['file'].'.state<>TASK_KILLED');
		llll('try');
		lllll('killtask '.lib('prg')['file']);
		llll('catch else');
		llll('end try');
		llll('sleep 1');
		lll('end while');
	}
	lll($lib['name'].'_started = false');
	lll('call com_sendSelf(state_websocket)');
	call(lib('stop'), true);
	logInfo(lib().' stopped');
	ll('end if');
	l('end sub');
	
	l('public sub '.lib().'_putDebug(byval ext_ as long)');
	ll('try');
	lll('com_with("/debug/'.lib().'/")');
	lll('com_putBool("started", '.lib().'_started)');
	lll('com_putBool("active", '.lib().'_active)');
	call(lib('debug'));
	ll('catch else');
	lll('com_putString("-", error)');
	ll('end try');
	if (lib('debugExt')) {
		ll('if ext_ then');
			foreach (lib('debugExt') as $l)
				lll("{$l}_putDebug(true)");
		ll('end if');
	}
	l('end sub');

	l('sub sleepActive(byval milliseconds_ as long)');
	ll('dim dummy_ as long = com_receive(lib_activeNotify, milliseconds_)');
	l('end sub');

	if (lib('prg'))
	{
		l('public sub '.lib().'_prgStart');
			call(lib('prgStart'));
		l('end sub');
		
		l('public sub '.lib().'_prgError');
			logError([
				'call com_putLong("/state", '.lib('prg')['file'].'.state)',
				//'call com_putString("/trace", backtrace$(programname))',
				lib('prgError')['log'],
			]);
			call(lib('prgError'));
			if (!lib('prgError') && !debug()) ll('call init_stopTrigger');
		l('end sub');
		
		l('public sub '.lib().'_prgStop');
			call(lib('prgStop'), true);
		l('end sub');
		
		l('function prgRunning as long');
		ll('prgRunning = (('.lib('prg')['file'].'.state band 0xF) = TASK_RUNNING)');
		l('end function');
		l('sub prgExit');
		ll('idletask '.$lib['prg']['file']);
		l('end sub');
	}

	if ($lib['device'])
		deviceLibEnd($lib['device']);
	
	set('lib')[lib()]					= $lib;
	set('libs')[$lib['type']][lib()]	= $lib;
}



function libPrg($lib) { $name=$lib['name']; $prg=$lib['prg']; ?>
program
	onError
		catch else
			call <?=$name?>_prgError
	end onError

	<?if ($prg['event']) {?>
		onevent <?=$name?>_prgEvent scantime=<?=$prg['event']?> priority=<?=$prg['prio']?>-1
			call <?=$name?>_prgEvent
		end onevent
	<?}?>

	call <?=$name?>_prgStart
	if <?=$name?>_active then
		<?if ($prg['event']) l("eventon {$name}_prgEvent")?>
		call <?=$name?>_prg
		<?if ($prg['event']) l("eventoff {$name}_prgEvent")?>
		call <?=$name?>_stopTrigger
	end if
	call <?=$name?>_prgStop
end program
<?}
