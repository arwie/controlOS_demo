// SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
// SPDX-License-Identifier: MIT

import { ref } from 'vue'
import { url, poll } from 'web/utils'
import { ButtonBar } from 'web/widgets'
import { systemIndex } from 'system'



systemIndex.addPage('remote', {
	setup() {
		const port   = ref('');
		const status = ref();
		
		const update = poll(3000, async ()=>{
			status.value = await url('system.remote.service').fetch();
		});
		
		async function enable(en) {
			await url('system.remote.service').query(en && {port:port.value}).post();
			update();
		}

		return { port, status, enable }
	},
	components: { ButtonBar },
	template: //html
	`
	<div class="mb-3">
		<label class="form-label">{{ $t('system.remote.port') }}</label>
		<input v-model="port" type="number" step="1" min="60000" max="65500" class="form-control">
	</div>
	<ButtonBar>
		<button @click="enable(true)" :disabled="!port" class="btn btn-primary">{{ $t('system.remote.enable') }}</button>
		<button @click="enable(false)" class="btn btn-secondary">{{ $t('system.remote.disable') }}</button>
	</ButtonBar>
	<div v-if="status" class="alert alert-success mt-4">
		<p>{{ $t('system.remote.active') }}</p>
		<pre v-text="status"></pre>
	</div>
	`
})
