// SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
// SPDX-License-Identifier: MIT

import { ref } from 'vue'
import { url, updateDeep } from 'web/utils'
import { ButtonBar, feedback } from 'web/widgets'
import { BFormCheckbox } from 'bootstrap/vue'
import { networkIndex } from 'system/network'



networkIndex.addPage('smtp', {
	setup() {

		const enabled = ref(false);
		const conf = ref({
			smtp: {
				ssl:		'yes',
				host:		'',
				port:		'',
				user:		'',
				pass:		'',
			},
		});

		const confUrl = url('system.network.smtp.conf');
		
		confUrl.fetchJson().then((data)=>{
			enabled.value = data != null;
			if (enabled.value)
				updateDeep(conf.value, data);
		});
		
		function save(ev) {
			feedback(ev.target, confUrl.postJson(enabled.value && conf.value));
		}

		return { enabled, conf, save }
	},
	components: { ButtonBar, BFormCheckbox },
	template: //html
	`
	<div class="mb-3">
		<BFormCheckbox v-model="enabled" switch>{{ $t('system.network.enabled') }}</BFormCheckbox>
	</div>
	<div v-if="enabled">
		<div class="mb-3">
			<div class="form-check form-check-inline">
				<input v-model="conf.smtp.ssl" type="radio" value="yes" id="network_smtpYes" class="form-check-input">
				<label class="form-check-label" for="network_smtpYes">{{ $t('system.network.ssl') }}</label>
			</div>
			<div class="form-check form-check-inline">
				<input v-model="conf.smtp.ssl" type="radio" value="no" id="network_smtpNo" class="form-check-input">
				<label class="form-check-label" for="network_smtpNo">{{ $t('system.network.starttls') }}</label>
			</div>
		</div>
		<div class="row">
			<div class="mb-3 col-md">
				<label class="form-label">{{ $t('system.network.host') }}</label>
				<input v-model="conf.smtp.host" type="text" class="form-control">
			</div>
			<div class="mb-3 col-md">
				<label class="form-label">{{ $t('system.network.port') }}</label>
				<input v-model="conf.smtp.port" type="number" class="form-control">
			</div>
		</div>
		<div class="row">
			<div class="mb-3 col-md">
				<label class="form-label">{{ $t('system.network.user') }}</label>
				<input v-model="conf.smtp.user" type="text" class="form-control">
			</div>
			<div class="mb-3 col-md">
				<label class="form-label">{{ $t('system.network.password') }}</label>
				<input v-model="conf.smtp.pass" type="password" class="form-control">
			</div>
		</div>
	</div>
	<ButtonBar>
		<button @click="save" class="btn btn-primary">{{ $t('save') }}</button>
	</ButtonBar>
	`
})
