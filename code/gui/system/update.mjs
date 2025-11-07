// SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
// SPDX-License-Identifier: MIT

import { ref } from 'vue'
import { url } from 'web/utils'
import { ButtonBar, FileButton, ConfirmButton, feedback } from 'web/widgets'
import { systemIndex } from 'system'



systemIndex.addPage('update', {
	async setup() {

		const release = ref();
		const revertDate = ref();

		release.value = await url('system.update.release').fetchJson();

		url('system.update.revert').fetch().then((mtime)=>{
			if (mtime)
				revertDate.value = mtime * 1000;
		});

		function upload(file, element) {
			feedback(element, url('system.update.release').put(file));
		}

		function revert(ev) {
			feedback(ev.target, url('system.update.revert').post());
		}

		return { release, upload, revertDate, revert }
	},
	components: { ButtonBar, FileButton, ConfirmButton },
	template: //html
	`
	<div class="accordion" id="update_accordion">
		<div class="accordion-item">
			<h2 class="accordion-header">
				<button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#update_file">{{ $t('system.update.file') }}</button>
			</h2>
			<div id="update_file" class="accordion-collapse collapse show" data-bs-parent="#update_accordion">
				<div class="accordion-body">
					<div class="mb-3">
						<label class="form-label">{{ $t('system.update.version') }}</label>
						<dl class="form-control">
							<dt>{{ $t('system.update.versionName') }}</dt>
							<dd>{{release.PTXDIST_BSP_VERSION}}</dd>
							<dt>{{ $t('system.update.buildDate') }}</dt>
							<dd>{{release.PTXDIST_BUILD_DATE}}</dd>
						</dl>
					</div>
					<ButtonBar>
						<FileButton @file="upload" class="btn-primary">{{ $t('system.update.file') }}</FileButton>
					</ButtonBar>
				</div>
			</div>
		</div>
		<div v-if="revertDate" class="accordion-item">
			<h2 class="accordion-header">
				<button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#update_revert">{{ $t('system.update.revert') }}</button>
			</h2>
			<div id="update_revert" class="accordion-collapse collapse" data-bs-parent="#update_accordion">
				<div class="accordion-body">
					<dl class="form-control">
						<dt>{{ $t('system.update.revertDate') }}</dt>
						<dd>{{ $d(revertDate, { year:'numeric', month:'numeric', day:'numeric', hour:'2-digit', minute:'2-digit', hour12:false }) }}</dd>
					</dl>
					<ButtonBar>
						<ConfirmButton @click="revert" class="btn-danger">{{ $t('system.update.revert') }}</ConfirmButton>
					</ButtonBar>
				</div>
			</div>
		</div>
	</div>
	`
})
