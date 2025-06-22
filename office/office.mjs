// SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
// SPDX-License-Identifier: MIT

import { setRootView, addPage } from 'web'
import { RootView, PageLink } from 'web/widgets'



export const officeIndex = addPage('office');



setRootView({
	setup() {
		return {
			links: officeIndex.children,
		}
	},
	components: { RootView, PageLink },
	template: //html
	`
	<RootView>
		<template #navbar>
			<PageLink to="/diag/log" />
			<PageLink v-for="to in links" :to />
		</template>
	</RootView>
	`
})
