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


function scara($a1, $a2, $a3, $a4) {
	return [
		'axes'		=> [$a1, $a2, $a3, $a4],
		'model'		=> 4,
		'type'		=> 'xyzr',
	];
}


function robot($rbt) { global $lib;
	
	$rbt['name']			= lib();
	
	$lib['robot'] = true;
	set('robot')[$rbt['name']]	= $rbt;
	
	l('common shared '.lib().'_disabled as long = true');
	
	lib('debug', [
		'com_putBool("enable",	enable)',
	]);
	if ($rbt['model']) {
		lib('debug', [
			'com_putJoint'.$rbt['type'].'("positionFeedback", positionFeedback)',
		]);
	}
	foreach ($rbt['axes'] as $ax)
		lib('debugExt', $ax);
	
	lib('end', function() use ($rbt) {
		robot_enableFunctions($rbt['axes'], $rbt);
		_robotFunctions($rbt);
	});
}


function robot_setup() { global $lib;
	lib('robotSetup', 'robotSetup()');
	l('sub robotSetup');
}


function robot_setupSpeed($vel, $accTimeMs=500, $jerkTimeMs=250) {
?>
	velocitymaxtrans		= <?=$vel[0]?>'
	accelerationmaxtrans	= <?=1000/$accTimeMs?>  * velocitymaxtrans
	jerkmaxtrans			= <?=1000/$jerkTimeMs?> * accelerationmaxtrans
	velocitytrans			= velocitymaxtrans
	accelerationtrans		= accelerationmaxtrans
	decelerationtrans		= accelerationmaxtrans
	jerktrans				= jerkmaxtrans
	
	velocitymaxrot			= <?=$vel[1]?>'
	accelerationmaxrot		= <?=1000/$accTimeMs?>  * velocitymaxrot
	jerkmaxrot				= <?=1000/$jerkTimeMs?> * accelerationmaxrot
	velocityrot				= velocitymaxrot
	accelerationrot			= accelerationmaxrot
	decelerationrot			= accelerationmaxrot
	jerkrot					= jerkmaxrot
	
	velocitySyncTran		= velocitytrans
	accelerationSyncTran	= accelerationtrans
	jerkSyncTran			= jerktrans
	velocitySyncRot			= velocityrot
	accelerationSyncRot		= accelerationrot
	jerkSyncRot				= jerkrot
	
	velocityDeSyncTran		= velocitytrans
	accelerationDeSyncTran	= decelerationtrans
	jerkDeSyncTran			= jerktrans
	velocityDeSyncRot		= velocityrot
	accelerationDeSyncRot	= decelerationrot
	jerkDeSyncRot			= jerkrot
<?
}


function robot_enableFunctions($axes, $rbt=null) {
?>
public sub <?=lib()?>_enable
	<?foreach ($axes as $ax)
		call("dim {$ax}DriveFault_ as long = {$ax}.driveStatus band 0x8")?>
	<?foreach ($axes as $ax)
		call(["{$ax}_disabled = false", "{$ax}_driveError = false"])?>
	<?if ($rbt)
		call(lib()."_disabled = false")?>
	if not enable then
		try
			while not enable
				enable = true
				sleep 1
			end while
			sleep 20 'needed!
		catch else
			<?logError()?>
		finally
			<?foreach ($axes as $ax)
				call(["if {$ax}DriveFault_ then", "{$ax}_driveLogErrorHandled = false", "end if"])?>
			throw errorApplication
		end try
	end if
end sub
public sub <?=lib()?>_enableAttach
	<?=lib()?>_enable()
	attach
end sub

public sub <?=lib()?>_disable
	while isMoving > 0
		sleep 1
	end while
	enable = false
	<?if ($rbt)
		call(lib()."_disabled = true")?>
	<?foreach ($axes as $ax)
		call("{$ax}_disabled = true")?>
end sub
public sub <?=lib()?>_disableDetach
	detach
	<?=lib()?>_disable()
end sub
<?
}


function _robotFunctions($rbt) {
?>
public sub <?=lib()?>_robotSetup
	attach
	<?_defaultRobotSetup($rbt)?>
	detach
end sub
<?
}


function _defaultRobotSetup(&$rbt) {
	foreach ($rbt['axes'] as $ax) { $j += 1; $jnt = 'j'.$j;
		ll($jnt.'.positionmin			= '.$ax.'.positionmin');
		ll($jnt.'.positionmax			= '.$ax.'.positionmax');
	}
	call(libGet('robotSetup'));
}
