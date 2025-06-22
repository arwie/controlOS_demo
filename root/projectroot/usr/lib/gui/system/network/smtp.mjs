// SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
// SPDX-License-Identifier: MIT

import { ref } from 'vue'
import { url, updateDeep } from 'web/utils'
import { ButtonBar, feedback } from 'web/widgets'
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
	components: { ButtonBar },
	template: //html
	`
	<div class="mb-3 form-check form-switch">
		<input v-model="enabled" type="checkbox" id="network_smtpEnabled" class="form-check-input">
		<label class="form-check-label" for="network_smtpEnabled" data-l10n-id="network_enabled"></label>
	</div>
	<div v-if="enabled">
		<div class="mb-3">
			<div class="form-check form-check-inline">
				<input v-model="conf.smtp.ssl" type="radio" value="yes" id="network_smtpYes" class="form-check-input">
				<label class="form-check-label" for="network_smtpYes" data-l10n-id="network_ssl"></label>
			</div>
			<div class="form-check form-check-inline">
				<input v-model="conf.smtp.ssl" type="radio" value="no" id="network_smtpNo" class="form-check-input">
				<label class="form-check-label" for="network_smtpNo" data-l10n-id="network_starttls"></label>
			</div>
		</div>
		<div class="row">
			<div class="mb-3 col-md">
				<label class="form-label" data-l10n-id="network_host"></label>
				<input v-model="conf.smtp.host" type="text" class="form-control">
			</div>
			<div class="mb-3 col-md">
				<label class="form-label" data-l10n-id="network_port"></label>
				<input v-model="conf.smtp.port" type="number" class="form-control">
			</div>
		</div>
		<div class="row">
			<div class="mb-3 col-md">
				<label class="form-label" data-l10n-id="network_user"></label>
				<input v-model="conf.smtp.user" type="text" class="form-control">
			</div>
			<div class="mb-3 col-md">
				<label class="form-label" data-l10n-id="network_password"></label>
				<input v-model="conf.smtp.pass" type="password" class="form-control">
			</div>
		</div>
	</div>
	<ButtonBar>
		<button @click="save" class="btn btn-primary" data-l10n-id="network_save"></button>
	</ButtonBar>
	`
})
