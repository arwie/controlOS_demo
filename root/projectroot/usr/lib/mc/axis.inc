<?# Copyright (c) 2019 Artur Wiebe <artur@4wiebe.de>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
# associated documentation files (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


function axis($ax) { global $lib;
	static $elementid = 1;

	$ax['elementid']	= $elementid++;
	$ax['name']			= lib();
	
	$ax['setup']		= $ax['setup']		?: strtoupper($ax['name']).'.DAT';
	$ax['firmware']		= $ax['firmware']	?: strtoupper($ax['device']).'.O';

	switch ($ax['device']) {
		case 'cdhd':
			//$ax['writeBit'] = [['index'=>0x60FE, 'subindex'=>1, 'size'=>6,  'offset'=>16]];
			break;
	}

	$lib['axis'] = true;
	device($ax);
	
	l('common shared '.lib().'_disabled as long = true');
	l('common shared '.lib().'_driveLogErrorHandled as long');
	
	lib('debug', [
		'com_putBool("enable",				enable)',
		'com_putDouble("positionFeedback",	positionFeedback)',
		'com_putDouble("torqueFeedback",	torqueFeedback)',
	]);
	lib('end', function() use ($ax) {
		robot_enableFunctions([lib()]);
		_axisFunctions($ax);
	});
	
	if ($ax['bus']) {
		lib('end', function() use ($ax) { _driveFunctions($ax); });
	}
	if (!$ax['simulated']) {
		lib('end', function() use ($ax) { _driveLogFunctions($ax); });
	}
}


function drive_update($hash) {
	lib('driveUpdate')['hash'][] = $hash;
	lib('driveUpdate', 'driveUpdate()');
	l('sub driveUpdate');
}

function driveCache($expr, $type='double') {
	$hash = hashsum([$expr, $type]);
	lib('driveCache', 'com_put'.$type.'("/'.$hash.'", '.$expr.')');
	return 'com_get'.$type.'("/'.$hash.'")';
}

function drive_setup() {
	lib('driveSetup', 'driveSetup()');
	l('sub driveSetup');
}

function axis_setup() {
	lib('axisSetup', 'axisSetup()');
	l('sub axisSetup');
}


function axis_setupSpeed($vel, $accTimeMs=500, $jerkTimeMs=250) {
?>
	velocitymax			= <?=$vel?>'
	accelerationmax		= <?=1000/$accTimeMs?>  * velocitymax
	decelerationmax		= accelerationmax
	jerkmax				= <?=1000/$jerkTimeMs?> * accelerationmax
	velocitycruise		= velocitymax
	acceleration		= accelerationmax
	deceleration		= decelerationmax
	jerk				= jerkmax
	decelerationstop	= decelerationmax
	velocityoverspeed	= 10 * velocitymax
<?
}



function _axisFunctions($ax) {
?>
public sub <?=lib()?>_axisSetup
	dim driveUpdate_ as long = true
	dim driveCache_ as long
	dim driveHash_ as string
	attach
<?
	if (!$ax['simulated'])
	{
		com_openFile('driveCache_', '/home/mc/'.lib().'.drivecache');
		ll('driveHash_ = '.s(hashsum([libGet('driveUpdate'), libGet('driveCache')])).'+str$('.lib().'_deviceRead(0x1018, 4))');
		ll('try');
		lll('if com_receive(driveCache_, 0) then');
			llll('driveUpdate_ = driveHash_ <> com_getString("/#")');
		lll('end if');
		catchLog();
		ll('if driveUpdate_ then');
			logInfo(lib().' drive parameters update');
			
			lll('com_clear()');
			_defaultDriveUpdate($ax);
			lll(lib().'_driveSave()');
			call(libGet('driveCache'));
			lll('com_putString("/#", driveHash_)');
			lll('com_send(driveCache_)');
			
		ll('end if');
		ll('com_close(driveCache_)');
		
		_defaultDriveSetup($ax);
	}
	
	_defaultAxisSetup($ax);
?>
	detach
end sub
<?
}


function _defaultDriveUpdate($ax) { lib('driveUpdate')['hash'][] = 4;
	switch ($ax['device']) {
		case 'cdhd':
		break;case 'stepim':
	}
	call(libGet('driveUpdate'));
}


function _defaultDriveSetup($ax) {
	ll('driveLogResetFault(false)');
	ll('driveLogResetFault(true)');
	ll(lib().'_deviceWrite(0x6060, 0, 8, 8)');		#Modes of Operation: 8 = cyclic synchronous position mode

	ll('motionbusvelocityscale		= 0');
	ll('motionbusvelocitybase		= 1000');
	
	switch ($ax['device']) {
		case 'cdhd':
			ll(lib().'_deviceWrite(0x60C0, 0, 16, 2)');			#Interpolation: 2 = Cubic interpolation with position only – strict
			ll('positionfactor				= '.driveCache(lib().'_deviceRead(0x6092, 1)/'.lib().'_deviceRead(0x6092, 2)', 'double'));
			ll('positionerrordelay			= 4.11');
		break;case 'stepim':
			ll(lib().'_deviceWrite(0x1003, 0, 8, 0)');			#Clear Error History
			ll('positionfactor				= 4096');
			ll('positionerrordelay			= '.($ax['bus']=='etc' ? 5 : 2));
	}
	call(libGet('driveSetup'));
}


function _defaultAxisSetup($ax) {
	if ($ax['simulated']) {
		ll('positionerrordelay		= 4');
		ll('positionerrormax		= MAXDOUBLE');
	}
	
	ll('velocityfactor				= positionfactor / 1000');
	ll('accelerationfactor			= positionfactor / 1000000');
	ll('jerkfactor					= positionfactor / 1000000000');
	ll('velocityexternalfactor		= positionexternalfactor / 1000');
	
	ll('smoothFactor				= -1');
	
	call(libGet('axisSetup'));
}



function _driveFunctions($ax) {
?>
public sub <?=lib()?>_driveSave
	<?=lib()?>_deviceWrite(0x<?=($ax['device']=='stepim' && $ax['bus']=='etc')?'2E04':'1010'?>, 1, 32, 0x65766173)
	sleep <?=($ax['device']=='stepim' && $ax['bus']=='can')?'3500':'500'?>'
end sub

<?if ($ax['device']=='stepim') {?>

<?if (!$ax['simulated'] && $ax['bus']=='can') {?>
public sub <?=lib()?>_driveSetupAddress(byval currentAddress_ as long)
	can_write(currentAddress_, 0x2F1B, 0, 16, <?=get('device')[lib()]['address']?>)
	can_write(currentAddress_, 0x1010, 1, 32, 0x65766173)
end sub
<?}?>

public sub <?=lib()?>_driveTune(byval posProportional_ as long, byval posIntegral_ as long, byval posDerivative_ as long, byval posVelFeedForward_ as long, byval velProportional_ as long, byval velIntegral_ as long)
	<?=lib()?>_deviceWrite(0x201E, 0, 32, posDerivative_)
	<?=lib()?>_deviceWrite(0x2020, 0, 32, posIntegral_)
	<?=lib()?>_deviceWrite(0x2022, 0, 32, posProportional_)
	<?=lib()?>_deviceWrite(0x2023, 0, 32, posVelFeedForward_)
	<?=lib()?>_deviceWrite(0x2026, 0, 32, velIntegral_)
	<?=lib()?>_deviceWrite(0x2027, 0, 32, velProportional_)
end sub
<?}?>

<?
}



function _driveLogFunctions($ax) {
?>
public function <?=lib()?>_driveLogError as long
	dim errorcode_ as long
	if driveStatus band 0x8 then 'drive fault
		if not <?=lib()?>_driveLogErrorHandled then
			try
				errorcode_ = <?=lib()?>_deviceRead(0x603F, 0)
				if <?=lib()?>_disabled then
					select case errorcode_
					case 0x3120 'Under-voltage
					case else
						<?=lib()?>_driveLogError = log_prioWarning
					end select
				else
					<?=lib()?>_driveLogError = log_prioError
				end if
				if <?=lib()?>_driveLogError then
					<?logMessage(lib().'_driveLogError', '"'.lib().' drive error: "+drivelog_errorString(errorcode_)', [function() use ($ax) {?>
						com_putString("/error", hex$(errorcode_)+"h")
						com_putString("/drivestatus", bin$(driveStatus))
					<?}])?>
				end if
			catch else
			end try
			<?=lib()?>_driveLogErrorHandled = true
		end if
		driveLogResetFault(blinkHerz(1))
	else
		<?=lib()?>_driveLogErrorHandled = false
	end if
end function

public sub <?=lib()?>_driveLogInfo
	<?logInfo(lib().' drive information', [function() use ($ax) {
		if ($ax['device']=='stepim') {
			ll('com_putString("/version/software", '.lib().'_deviceReadString(0x'.($ax['bus']=='etc'?'2E00':'100A').', 0))');
			ll('com_putString("/version/hardware", '.lib().'_deviceReadString(0x'.($ax['bus']=='etc'?'2E01':'1009').', 0))');
		}
		ll('driveLogPutHealth()');
	}])?>
end sub

public sub <?=lib()?>_driveLogHistory
	dim i as long
	dim history_ as string
	dim historyCount_ as long
	<?logNotice(lib().' drive error history', [function() use ($ax) {
		if ($ax['device']=='stepim') {
			ll('historyCount_ = min(10, '.lib().'_deviceRead(0x1003, 0))');
			ll('for i = 1 to historyCount_');
				ll('history_ = history_ + drivelog_errorString('.lib().'_deviceRead(0x1003, i)) + chr$(10)');
			ll('next');
		} else {
			ll('history_ = drivelog_errorString('.lib().'_deviceRead(0x603F, 0))');
		}
		ll('com_putString("/errorhistory", history_)');
		ll('driveLogPutHealth()');
	}])?>
end sub

public sub <?=lib()?>_driveLogHealth
	<?logInfo(lib().' drive health', ['driveLogPutHealth()'])?>
end sub

sub driveLogPutHealth
	dim warnings_ as string
	
	com_putString("/drivestatus", bin$(driveStatus))
	
	if driveStatus band 0x80 then 'drive warnings
		<?if ($ax['device']=='cdhd') {?>
				warnings_ = bin$(<?=lib()?>_deviceRead(0x2011, 1))
				warnings_ = string$(32-len(warnings_), "0") + warnings_
				warnings_ = bin$(<?=lib()?>_deviceRead(0x2011, 2)) + warnings_
		<?}?>
		<?if ($ax['device']=='stepim') {?>
				warnings_ = bin$(<?=lib()?>_deviceRead(0x2011, 0))
		<?}?>
		com_putString("/warnings", warnings_)
	end if
	
	<?if ($ax['device']=='cdhd') {?>
		com_putLong("/temp_control",	<?=lib()?>_deviceRead(0x2044, 1))
		com_putLong("/temp_power",		<?=lib()?>_deviceRead(0x2044, 2))
		com_putLong("/temp_motor",		<?=lib()?>_deviceRead(0x20C7, 0))
	<?}?>
	<?if ($ax['device']=='stepim') {?>
		com_putLong("/temp_drive",		<?=lib()?>_deviceRead(0x2044, 0))
	<?}?>
	
	com_putDouble("/bus_voltage",		<?=lib()?>_deviceRead(0x6079, 0)/1000.0)
end sub

sub driveLogResetFault(byval value_ as long)
	<?=lib()?>_deviceWrite(0x6040, 0, 16, 0x80*value_)
end sub
<?
}
