// SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
// SPDX-License-Identifier: MIT

import { ref } from 'vue'
import { url, poll } from 'web/utils'
import { PageLink } from 'web/widgets'
import { systemIndex } from 'system'



export const networkIndex = systemIndex.addPage('network', {
	setup() {
		return {
			links: networkIndex.children,
		}
	},
	components: { PageLink },
	template: //html
	`
	<div class="row h-100 mb-3">
		<div class="col-lg-3 nav nav-pills flex-column mb-4">
			<PageLink v-for="to in links" :to :data-l10n-id="'network_'+to.path" />
		</div>
		<div class="col-lg h-100">
			<RouterView />
		</div>
	</div>
	`
})



const statusPage = networkIndex.addPage('status', {
	setup() {

		const status = ref();

		poll(3000, async ()=>{
			status.value = await url('system.network.status').fetch();
		});

		return { status }
	},
	template: //html
	`
	<textarea v-text="status" type="text" class="form-control h-100 mb-3" style="font-family:monospace" readonly></textarea>
	`
})



networkIndex.redirect = statusPage;
