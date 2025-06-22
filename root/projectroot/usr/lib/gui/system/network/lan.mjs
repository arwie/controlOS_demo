// SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
// SPDX-License-Identifier: MIT

import { ref, shallowRef, useTemplateRef, useId } from 'vue'
import { url, updateDeep } from 'web/utils'
import { ButtonBar, feedback } from 'web/widgets'
import { networkIndex } from 'system/network'



export const NetworkConf = {
	props: ['type'],
	expose: ['save'],
	setup(props) {

		const confStatic = ref({
			Network: {
				DHCP:		'no',
				Address:	'192.168.178.56/24',
				Gateway:	'192.168.178.1',
				DNS:		'9.9.9.9',
			},
		});
		const confDhcp = ref({
			DHCP: {
				Hostname:	'robot',
			}
		});
		const conf = shallowRef();

		const networkUrl = url(`system.network.${props.type}.network`);

		networkUrl.fetchJson().then((data)=>{
			conf.value = data?.Network?.DHCP == 'no' ? confStatic.value : confDhcp.value;
			updateDeep(conf.value, data);
		});

		function save() {
			if (conf.value)
				return networkUrl.postJson(conf.value);
		}

		return { conf, confDhcp, confStatic, idDhcp:useId(), idStatic:useId(), save }
	},
	template: //html
	`
	<div class="mb-3">
		<div class="form-check form-check-inline">
			<input v-model="conf" type="radio" :value="confDhcp" :id="idDhcp" class="form-check-input">
			<label :for="idDhcp" class="form-check-label" data-l10n-id="network_dhcp"></label>
		</div>
		<div class="form-check form-check-inline">
			<input v-model="conf" type="radio" :value="confStatic" :id="idStatic" class="form-check-input">
			<label :for="idStatic" class="form-check-label" data-l10n-id="network_maunal"></label>
		</div>
	</div>
	<div v-if="conf===confStatic">
		<div class="mb-3">
			<label class="form-label" data-l10n-id="network_address"></label>
			<input v-model="conf.Network.Address" type="text" class="form-control">
		</div>
		<div class="mb-3">
			<label class="form-label" data-l10n-id="network_gateway"></label>
			<input v-model="conf.Network.Gateway" type="text" class="form-control">
		</div>
		<div class="mb-3">
			<label class="form-label" data-l10n-id="network_dns"></label>
			<input v-model="conf.Network.DNS" type="text" class="form-control">
		</div>
	</div>
	<div v-if="conf===confDhcp">
		<div class="mb-3">
			<label class="form-label" data-l10n-id="network_hostname"></label>
			<input v-model="conf.DHCP.Hostname" type="text" class="form-control">
		</div>
	</div>
	`
}



networkIndex.addPage('lan', {
	targetGuard: 'network@lan',
	setup() {

		const lanConf = useTemplateRef('lanConf')
		
		function save(ev) {
			feedback(ev.target, lanConf.value.save());
		}

		return { save }
	},
	components: { NetworkConf, ButtonBar },
	template: //html
	`
	<NetworkConf ref="lanConf" type="lan"/>
	<ButtonBar>
		<button @click="save" class="btn btn-primary" data-l10n-id="network_save"></button>
	</ButtonBar>
	`
})
