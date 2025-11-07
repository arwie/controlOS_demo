// SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
// SPDX-License-Identifier: MIT

import { addPage } from 'web'
import { NavDropdown, PageLink } from 'web/widgets'



export const systemIndex = addPage('system');



export const SystemDropdown = {
	setup() {
		return {
			links: systemIndex.children,
		}
	},
	components: { NavDropdown, PageLink },
	template: //html
	`
	<NavDropdown icon="cog" :title="$t('system.title')" right>
		<PageLink v-for="to in links" :to />
	</NavDropdown>
	`
}
