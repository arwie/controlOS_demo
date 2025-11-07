// SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
// SPDX-License-Identifier: MIT

import { ref, useTemplateRef } from 'vue'
import { url } from 'web/utils'
import { ButtonBar } from 'web/widgets'
import { diagIndex } from 'diag'



diagIndex.addPage('issue', {
	setup() {

		const smtpEnabled = ref(false);

		url('diag.issue.report').fetchJson().then((data)=>{
			smtpEnabled.value = data.smtpEnabled;
		});

		const form = useTemplateRef('form');

		function send(ev) {
			url('diag.issue.report').query({action:'send'}).post(form.value.serialize())
			//gui.feedback(ev.target, $.post(ajaxUrl('issue', ), formData));
		}

		return { smtpEnabled, send }
	},
	components: { ButtonBar },
	template: //html
	`
	<form ref="form" action="diag.issue.report" method="post" target="_blank">
		<div class="mb-3">
			<label class="form-label">{{ $t('diag.issue.description') }}</label>
			<textarea name="description" class="form-control" rows="10"></textarea>
		</div>
		<div class="mb-3">
			<label class="form-label">{{ $t('diag.issue.contact') }}</label>
			<input type="text" name="name" class="form-control">
		</div>
		<div class="row mb-3">
			<div class="col">
				<label class="form-label">{{ $t('diag.issue.contactEmail') }}</label>
				<input type="email" name="email" class="form-control">
			</div>
			<div class="col">
				<label class="form-label">{{ $t('diag.issue.contactTelephone') }}</label>
				<input type="tel" name="phone" class="form-control">
			</div>
		</div>
		<ButtonBar>
			<button v-if="smtpEnabled" @click="send($event)" class="btn btn-primary">{{ $t('diag.issue.send') }}</button>
			<button type="submit" class="btn btn-secondary">{{ $t('diag.issue.download') }}</button>
		</ButtonBar>
	</form>
	`
})
