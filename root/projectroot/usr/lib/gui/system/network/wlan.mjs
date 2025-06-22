import { ref, useTemplateRef } from 'vue'
import { url, updateDeep } from 'web/utils'
import { ButtonBar, feedback } from 'web/widgets'
import { networkIndex } from 'system/network'
import { NetworkConf } from 'system/network/lan'



networkIndex.addPage('wlan', {
	targetGuard: 'network@wlan',
	setup() {

		const enabled = ref(false);
		const conf = ref({
			ssid:	'',
			psk:	'',
		});

		const wlanConf = useTemplateRef('wlanConf');

		const wpaUrl = url('system.network.wlan.wpa');
		
		wpaUrl.fetchJson().then((data)=>{
			enabled.value = data != null;
			if (enabled.value)
				updateDeep(conf.value, data);
		});
		
		function save(ev) {
			feedback(ev.target, Promise.all([
				wpaUrl.postJson(enabled.value && conf.value),
				wlanConf.value?.save(),
			]));
		}

		return { enabled, conf, save }
	},
	components: { NetworkConf, ButtonBar },
	template: //html
	`
	<div class="mb-3 form-check form-switch">
		<input v-model="enabled" type="checkbox" id="network_wlanEnabled" class="form-check-input">
		<label class="form-check-label" for="network_wlanEnabled" data-l10n-id="network_enabled"></label>
	</div>
	<div v-if="enabled">
		<div class="mb-3">
			<label class="form-label" data-l10n-id="network_ssid"></label>
			<input v-model="conf.ssid" type="text" class="form-control">
		</div>
		<div class="mb-3">
			<label class="form-label" data-l10n-id="network_password"></label>
			<input v-model="conf.psk" type="password" class="form-control">
		</div>
		<NetworkConf ref="wlanConf" type="wlan"/>
	</div>
	<ButtonBar>
		<button @click="save" class="btn btn-primary" data-l10n-id="network_save"></button>
	</ButtonBar>
	`
})
