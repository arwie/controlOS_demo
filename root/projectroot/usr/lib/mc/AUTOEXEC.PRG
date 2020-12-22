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
?>


<?
	$etc = !empty(device_busDevices('etc'));
	$can = !empty(device_busDevices('can'));
	$axes = device_axes();
?>


program continue
	dim error_ as string

	onError
		catch else
			log_message(log_prioError, AUTOEXEC.PRG.error, "init", "onError")
			com_putLong("/error", AUTOEXEC.PRG.errornumber)
			log_putTrnErr()
			log_send()
	end onError


	state_init()
	log_init()
	state_start()
	log_start()


	if system.numberaxes < <?=count($axes)?> then
		log_message(log_prioCritical, "MC license not sufficient!", "init", "numberaxes")
		com_putLong("/numberaxes", system.numberaxes)
		log_send()
	end if

<?
	foreach($axes as $ax=>$axis) {
		ll('error_ = vesexecute("a'.$axis['elementid'].'.axisname = '.$ax.'")');
	}
?>

	loadGlobal INIT.LIB

<?if ($etc) {?>
	loadGlobal ETHERCAT.LIB
	loadGlobal EC_CDHD.LIB
	loadGlobal ETC.LIB
<?}?>
<?if ($can) {?>
	loadGlobal CANDS402.LIB
	loadGlobal ISMAPPER.LIB
	loadGlobal CAN.LIB
<?}?>

<?
	foreach (array_reverse(get('libs')['app']) as $l=>$lib) {
		if ($lib['axis'] || $lib['robot'])
			ll('error_ = vesexecute("withGlobal '.$l.'")');
		ll('loadGlobal '.$lib['file']);
	}
?>

	loadGlobal DRIVELOG.LIB
	loadGlobal SIMIO.LIB
	loadGlobal DEBUG.LIB
	loadGlobal SYSTEM.LIB

	load INIT.PRG

terminate program
