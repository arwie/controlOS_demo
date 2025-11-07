// SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
// SPDX-License-Identifier: MIT

import { addPage } from 'web'
import { NavDropdown, PageLink } from 'web/widgets'



export const diagIndex = addPage('diag');



export const DiagDropdown = {
	setup() {
		return {
			links: diagIndex.children,
		}
	},
	components: { NavDropdown, PageLink },
	template: //html
	`
	<NavDropdown icon="eye" :title="$t('diag.title')" right>
		<PageLink v-for="to in links" :to />
	</NavDropdown>
	`
}
