// SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
// SPDX-License-Identifier: MIT

import { addPage } from 'web'
import { url } from 'web/utils'
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
	<NavDropdown icon="cog" data-l10n-id="system" right>
		<PageLink v-for="to in links" :to />
	</NavDropdown>
	`
}


export const PoweroffDropdown = {
	setup() {
		return {
			poweroff() {
				url('system.poweroff').post();
			}
		}
	},
	components: { NavDropdown },
	template: //html
	`
	<NavDropdown icon="power-off" right>
		<button @click="poweroff" class="dropdown-item" data-l10n-id="poweroff"></button>
	</NavDropdown>
	`
}
