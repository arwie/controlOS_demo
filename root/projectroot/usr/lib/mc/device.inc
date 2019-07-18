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


function device(&$dev) { global $lib;
	static $dio = 64;

	$dev['device']		= conf('device',lib(),'device',    $dev['device']);
	$dev['simulated']	= device_simulated(lib())       || $dev['simulated'];
	$dev['address']		= conf('device',lib(),'address',   $dev['address'])		?: 0;
	$dev['bus']			= conf('device',lib(),'bus',       $dev['bus']);
	
	$dev['writeBit'] = $dev['writeBit'] ?: [];
	foreach ($dev['writeBit'] as &$bit) {
		$bit['offset'] = $bit['offset'] ?: 0;
		$bit['dio'] = $dio;
		$dio += $bit['size'];
	}
	
	set('device')[lib()] = $dev;
	$lib['device'] = get('device')[lib()];
	
	if ($dev['bus']) {
		l('common shared '.lib().'_deviceAddress as const long = '.get('device')[lib()]['address']);
	}
}


function deviceLibEnd($dev) {
	if (!$dev['bus']) return;
	
	l('public function '.lib().'_deviceRead(byval index_ as long, byval subindex_ as long) as long');
	ll(lib().'_deviceRead = '.$dev['bus'].'_read('.$dev['address'].', index_, subindex_)');
	l('end function');
	l('public sub '.lib().'_deviceWrite(byval index_ as long, byval subindex_ as long, byval size_ as long, byval value_ as long)');
	ll($dev['bus'].'_write('.$dev['address'].', index_, subindex_, size_, value_)');
	l('end sub');
	
	l('public function '.lib().'_deviceReadString(byval index_ as long, byval subindex_ as long) as string');
	ll(lib().'_deviceReadString = '.$dev['bus'].'_readString('.$dev['address'].', index_, subindex_)');
	l('end function');
	
	l('public function '.lib().'_deviceReadBit(byval index_ as long, byval subindex_ as long, byval bit_ as long) as long');
	ll(lib().'_deviceReadBit = getBit('.lib().'_deviceRead(index_, subindex_), bit_)');
	l('end function');
	
	if ($dev['writeBit']) {
		l('public sub '.lib().'_deviceWriteBit(byval index_ as long, byval subindex_ as long, byval bit_ as long, byval value_ as long)');
		ll(lib().'_deviceWriteBits(index_, subindex_, bit_, 1, value_)');
		l('end sub');
		l('public sub '.lib().'_deviceWriteBits(byval index_ as long, byval subindex_ as long, byval bit_ as long, byval range_ as long, byval value_ as long)');
		ll('dim dio_    as long = -1');
		ll('dim offset_ as long');
		ll('dim size_   as long');
		ll('select case (index_ shl 16) + subindex_');
		foreach (get('device')[lib()]['writeBit'] as $bit) {
			ll('case 0x'.dechex(($bit['index'] << 16) + $bit['subindex']));
			lll('dio_    = '.$bit['dio']);
			lll('offset_ = '.$bit['offset']);
			lll('size_   = '.$bit['size']);
		}
		ll('end select');
		ll('if (dio_ > 0) and (bit_ >= offset_) and (bit_-offset_+range_ <= size_) then');
		lll('system.dout[dio_+bit_-offset_][range_] = value_');
		ll('else');
			logThrow(['bitwise write to unassociated pdo'], [
				'com_putString("/index", hex$(index_)+"h")',
				'com_putLong("/subindex", subindex_)',
				'com_putLong("/bit", bit_)',
				'com_putLong("/range", range_)',
			]);
		ll('end if');
		l('end sub');
	}
}


function device_order($order) {
	$address = 1;
	foreach ($order as $lib) {
		if (get('device')[$lib] && !get('device')[$lib]['simulated'] && !get('device')[$lib]['address'])
			set('device')[$lib]['address'] = $address++;
	}
}


function device_busDevices($bus, $simulated=false) {
	$busDevs = [];
	foreach(get('device') as $dev) {
		if($dev['bus']==$bus && !$dev['simulated'])
			$busDevs[] = $dev;
	}
	return $busDevs;
}


function device_axes() {
	$axes = [];
	foreach(get('device') as $dev) {
		if($dev['elementid'])
			$axes[$dev['name']] = $dev;
	}
	return $axes;
}


function device_simulated($device=null) {
	$device = $device ?: lib();
	return conf('device',$device,'simulated') || (get('mc')['type']=='sim' && !conf('device'));
}






function io($dev) {
	device($dev);
}
