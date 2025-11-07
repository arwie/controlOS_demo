import { ref, useTemplateRef } from 'vue'
import { url, updateDeep } from 'web/utils'
import { ButtonBar, feedback } from 'web/widgets'
import { BFormCheckbox } from 'bootstrap/vue'
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
	components: { NetworkConf, ButtonBar, BFormCheckbox },
	template: //html
	`
	<div class="mb-3">
		<BFormCheckbox v-model="enabled" switch>{{ $t('system.network.enabled') }}</BFormCheckbox>
	</div>
	<div v-if="enabled">
		<div class="mb-3">
			<label class="form-label">{{ $t('system.network.ssid') }}</label>
			<input v-model="conf.ssid" type="text" class="form-control">
		</div>
		<div class="mb-3">
			<label class="form-label">{{ $t('system.network.password') }}</label>
			<input v-model="conf.psk" type="password" class="form-control">
		</div>
		<NetworkConf ref="wlanConf" type="wlan"/>
	</div>
	<ButtonBar>
		<button @click="save" class="btn btn-primary">{{ $t('save') }}</button>
	</ButtonBar>
	`
})
