// SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
// SPDX-License-Identifier: MIT

import { ref } from 'vue'
import { NavDropdown } from 'web/widgets'



export const LocaleDropdown = {
	setup() {
		return {
			langs: document.querySelector('meta[name=availableLanguages]').content.split(','),
			select(lang) {
				document.l10n.requestLanguages([lang]);
				document.getElementById('navbar-collapse')?.classList.remove('show');
			},
		}
	},
	components: { NavDropdown },
	template: //html
	`
	<NavDropdown icon="language" data-l10n-id="locale" right>
		<button v-for="lang in langs" @click="select(lang)" :data-l10n-id="'locale_'+lang" class="dropdown-item"></button>
	</NavDropdown>
	`
}



export const langRef = ref();

new MutationObserver(() => langRef.value = document.documentElement.lang)
	.observe(document.documentElement, { attributes:true, attributeFilter:['lang'] });
