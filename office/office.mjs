// SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
// SPDX-License-Identifier: MIT

import { setRootView, addPage } from 'web'
import { RootView, PageLink } from 'web/widgets'
import { LocaleDropdown } from 'web/locale'



export const officeIndex = addPage('office');



setRootView({
	setup() {
		return {
			links: officeIndex.children,
		}
	},
	components: { RootView, PageLink, LocaleDropdown },
	template: //html
	`
	<RootView title="controlOS - Office">
		<template #navbar>
			<PageLink to="/diag/log" />
			<PageLink v-for="to in links" :to />
		</template>
		<template #navbar-right>
			<LocaleDropdown />
		</template>
	</RootView>
	`
})
