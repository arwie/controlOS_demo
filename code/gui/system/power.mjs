// SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
// SPDX-License-Identifier: MIT

import { url } from 'web/utils'
import { NavDropdown } from 'web/widgets'



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
		<button @click="poweroff" class="dropdown-item">{{$t('system.poweroff')}}</button>
	</NavDropdown>
	`
}
