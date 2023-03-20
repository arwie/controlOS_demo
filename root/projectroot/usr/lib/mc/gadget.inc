<?
$gadget=[];


$gadget_init = function($port, $ip='') use (&$gadget) {
	lib('begin', [
		"dim shared this_udpReceiver			as long",
		"dim shared this_udpSender				as long",
		"dim shared this_udpSenderAddress		as string = ".s('192.168.173.'.$ip),
	]);
	lib('init', function() use ($port) {
		com_openUdpReceiver('this_udpReceiver', $port);
	});
	lib('start', "com_reset(this_udpReceiver)");
	lib('start', function() use ($port) {
		com_openUdpSender('this_udpSender', 'this_udpSenderAddress', $port);
	});
	lib('stopTrigger', "com_sendSelf(this_udpReceiver)");
	lib('stop', "com_close(this_udpSender)");
};


$gadget_input = function($var, $receive, $reset) use (&$gadget) {
	$gadget['receive'][] = "$var = $receive";
	$gadget['reset'][]   = "$var = $reset";
	return $var;
};

$gadget_output = function($var, $send) use (&$gadget) {
	$gadget['send'][] = str_replace('#', $var, $send);
	return $var;
};


$gadget_initBattery = function() use ($gadget_input) {
	lib('begin', [
		"common shared ".$gadget_input(lib().'_batteryGood', 'com_getBool("/battery/good")', 0)." as long",
		"dim shared ".$gadget_input('this_batteryVoltage', 'com_getDouble("/battery/voltage")', 0)." as double",
	]);
	lib('debug', [
		'com_putBool("battery/good",		'.lib().'_batteryGood)',
		'com_putDouble("battery/voltage",	this_batteryVoltage)',
	]);
};



lib('begin', [
	"common shared ".lib()."_connected as long",
	"common shared ".$gadget_output(lib().'_enable', 'com_putBool("/enable", enable_)')." as long",
	"dim shared ".$gadget_input('this_signal', 'com_getDouble("/signal")', 0)." as double",
]);

lib('start',   lib().'_enable = false');
lib('prgStop', "gadgetSend(false)");


lib('end', function() use (&$gadget) {?>
public sub <?=lib()?>_startGadget(byval ip_ as long)
	this_udpSenderAddress = "192.168.173."+str$(ip_)
	<?=lib()?>_start()
end sub

<?lib_prgEvent(100/4)?>
	gadgetSend(<?=lib()?>_enable)
end sub

sub gadgetSend(byval enable_ as long)
	com_clear()
		<?call($gadget['send'])?>
	com_send(this_udpSender)
end sub

<?com_prgReceive('this_udpReceiver', 5000)?>
	select case receive_
	case com_receiveMessage
		<?=lib()?>_connected = true
		<?call($gadget['receive'])?>
	case com_receiveTimeout
		if <?=lib()?>_connected then
			<?logWarning("gadget disconnected")?>
		end if
		gadgetReset()
	end select
end sub

sub gadgetReset
	<?=lib()?>_connected = false
	<?call($gadget['reset'])?>
end sub
<?});


lib('init', "gadgetReset()");
lib('stop', "gadgetReset()");


lib('debug', [
	'com_putBool("connected",			'.lib().'_connected)',
	'com_putBool("enable",				'.lib().'_enable)',
	'com_putDouble("signal",			this_signal)',
]);
