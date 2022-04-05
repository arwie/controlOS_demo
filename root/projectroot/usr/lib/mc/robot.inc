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


function robot_configGroup() {
	lib('robotConfigGroup', ['robotConfigGroup()','configGroup']);
	l('sub robotConfigGroup');
}

function robot_setup() {
	lib('robotSetup', 'robotSetup()');
	l('sub robotSetup');
}


function robot_setupSpeed($vel, $accTimeMs=500, $jerkTimeMs=250) {
?>
	velocitycruise			= velocitymax
	acceleration			= accelerationmax
	deceleration			= decelerationmax
	decelerationstop		= decelerationmax
	jerk					= jerkmax
	
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
			do
				enable = true
				sleep 1
			loop until enable
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
	if enable then
		while isMoving > 0
			sleep 1
		end while
		sleep 20
	end if
	do
		enable = false
		sleep 1
	loop while enable <?if ($rbt) foreach ($axes as $ax) echo " or {$ax}.enable"?>'
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
	<?call(libGet('robotConfigGroup'))?>
	<?_defaultRobotSetup($rbt)?>
	<?call(libGet('robotSetup'))?>
	detach
end sub
<?
}


function _defaultRobotSetup(&$rbt) {
	if ($rbt['model']) {?>
		absolute					= true
		
		rmin						= 0
		rmax						= MAXDOUBLE
		xmin						= -rmax
		xmax						= rmax
		ymin						= -rmax
		ymax						= rmax
		zmin						= -rmax
		zmax						= rmax
		base.xmin					= xmin
		base.xmax					= xmax
		base.ymin					= ymin
		base.ymax					= ymax
		base.zmin					= zmin
		base.zmax					= zmax
		machinetable.xmin			= xmin
		machinetable.xmax			= xmax
		machinetable.ymin			= ymin
		machinetable.ymax			= ymax
		machinetable.zmin			= zmin
		machinetable.zmax			= zmax
		workpiece.xmin				= xmin
		workpiece.xmax				= xmax
		workpiece.ymin				= ymin
		workpiece.ymax				= ymax
		workpiece.zmin				= zmin
		workpiece.zmax				= zmax
		tool.xmin					= xmin
		tool.xmax					= xmax
		tool.ymin					= ymin
		tool.ymax					= ymax
		tool.zmin					= zmin
		tool.zmax					= zmax
	<?}
	foreach ($rbt['axes'] as $ax) { $j += 1; $jnt = 'j'.$j;
		ll($jnt.'.positionmin			= '.$ax.'.positionmin');
		ll($jnt.'.positionmax			= '.$ax.'.positionmax');
	}
}
