// SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
// SPDX-License-Identifier: MIT

import { ref } from 'vue'
import { url, updateDeep } from 'web/utils'
import { ButtonBar, feedback } from 'web/widgets'
import { networkIndex } from 'system/network'



networkIndex.addPage('syswlan', {
	targetGuard: 'network@syswlan',
	setup() {

		const enabled = ref(false);
		const conf = ref({
			ssid:				'controlOS',
			wpa_passphrase:		'',
			channel:			11,
			country_code:		'DE',
		});

		const hostapdUrl = url('system.network.syswlan.hostapd');
		
		hostapdUrl.fetchJson().then((data)=>{
			enabled.value = data != null;
			if (enabled.value)
				updateDeep(conf.value, data);
		});
		
		function save(ev) {
			feedback(ev.target, hostapdUrl.postJson(enabled.value && conf.value));
		}

		return { enabled, conf, save }
	},
	components: { ButtonBar },
	template: //html
	`
	<div class="mb-3 form-check form-switch">
		<input v-model="enabled" type="checkbox" id="network_syswlanEnabled" class="form-check-input">
		<label class="form-check-label" for="network_syswlanEnabled" data-l10n-id="network_enabled"></label>
	</div>
	<div v-if="enabled">
		<div class="mb-3">
			<label class="form-label" data-l10n-id="network_ssid"></label>
			<input v-model="conf.ssid" type="text" class="form-control">
		</div>
		<div class="mb-3">
			<label class="form-label" data-l10n-id="network_password"></label>
			<input v-model="conf.wpa_passphrase" type="text" minlength="8" class="form-control">
		</div>
		<div class="row">
			<div class="mb-3 col-md">
				<label class="form-label" data-l10n-id="network_country"></label>
				<input v-model="conf.country_code" type="text" class="form-control">
			</div>
			<div class="mb-3 col-md">
				<label class="form-label" data-l10n-id="network_channel"></label>
				<select v-model="conf.channel" class="form-select">
					<option v-for="channel in [1,2,3,4,5,6,7,8,9,10,11,12,13]">{{channel}}</option>
				</select>
			</div>
		</div>
	</div>
	<ButtonBar>
		<button @click="save" class="btn btn-primary" data-l10n-id="network_save"></button>
	</ButtonBar>
	`
})
