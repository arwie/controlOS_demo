// SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
// SPDX-License-Identifier: MIT

import { ref } from 'vue'
import { url, poll } from 'web/utils'
import { feedback } from 'web/widgets'
import { systemIndex } from 'system'



systemIndex.addPage('timedate', {
	async setup() {

		const statusUrl   = url('system.timedate.status');
		const timeUrl     = url('system.timedate.time');
		const timezoneUrl = url('system.timedate.timezone');

		const status = ref();
		poll(1000, async ()=>{
			status.value = await statusUrl.fetch();
		});

		const timeSync = ref();
		timeUrl.fetchJson().then((data)=>{
			if (data.NTPSynchronized != 'yes')
				poll(1000, ()=>{
					timeSync.value = Date.now();
				});
		});
		async function setTime(ev) {
			const timestamp = Math.round(Date.now() / 1000);
			await feedback(ev.target, timeUrl.postJson(timestamp));
		};

		const timezone = ref(null);
		async function setTimezone(ev) {
			await feedback(ev.target, timezoneUrl.postJson(timezone.value));
			timezone.value = null;
		};

		const timezones = ref(await timezoneUrl.fetchJson());

		return { status, timezone, timezones, setTimezone, timeSync, setTime }
	},
	template: //html
	`
	<div class="mb-4">
		<label class="form-label">{{ $t('system.timedate.status') }}</label>
		<textarea v-text="status" type="text" class="form-control" rows=8 style="font-family:monospace" readonly></textarea>
	</div>
	<div v-if="timezones.length > 1" class="row mb-4">
		<label class="form-label">{{ $t('system.timedate.timezone') }}</label>
		<div class="col">
			<select v-model="timezone" class="form-select">
				<option :value="null"></option>
				<option v-for="tz in timezones" :key="tz" :value="tz">{{ tz }}</option>
			</select>
		</div>
		<div class="col-2">
			<button @click="setTimezone" class="btn btn-primary w-100" :disabled="!timezone">{{ $t('apply') }}</button>
		</div>
	</div>
	<div v-if="timeSync" class="alert alert-warning">
		<div class="row">
			<div class="col" style="white-space:pre-wrap">
				{{ $t('system.timedate.timeSync', { time: $d(timeSync, { year:'numeric', month:'numeric', day:'numeric', hour:'2-digit', minute:'2-digit', second:'2-digit', hour12:false }) }) }}
			</div>
			<div class="col-2">
				<button @click="setTime" class="btn btn-success w-100">{{$t('send')}}</button>
			</div>
		</div>
	</div>
	`
})
