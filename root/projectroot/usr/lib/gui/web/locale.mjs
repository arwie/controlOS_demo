// SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
// SPDX-License-Identifier: MIT

import { createI18n } from 'vue/i18n'
import { NavDropdown } from 'web/widgets'



export const i18n = createI18n({
	legacy: false,
	fallbackLocale: 'en',
});


const langs = await (
	async function() {
		let langsModule;
		try {
			langsModule = await import('locale/langs');
		} catch (e) {
			langsModule = await import('locale/base/langs');
		}
		return langsModule.default;
	}
)();


export async function selectLocale(lang) {
	if (!i18n.global.availableLocales.includes(lang)) {
		let localeModule;
		try {
			localeModule = await import(`locale/base/${lang}`);
			i18n.global.setLocaleMessage(lang, localeModule.default);
		} catch (e) {}
		try {
			localeModule = await import(`locale/${lang}`);
			i18n.global.mergeLocaleMessage(lang, localeModule.default);
		} catch (e) {}
	}
	i18n.global.locale.value = document.documentElement.lang = lang;
}


//import fallback locale
await selectLocale('en');
//select browser locale
selectLocale(localStorage.getItem("_locale_") || navigator.language.split('-')[0]);



export const LocaleDropdown = {
	setup() {
		return {
			langs,
			select(lang) {
				selectLocale(lang);
				localStorage.setItem("_locale_", lang);
				document.getElementById('navbar-collapse')?.classList.remove('show');
			},
		}
	},
	components: { NavDropdown },
	template: //html
	`
	<NavDropdown icon="language" right>
		<button v-for="(name,lang) in langs" @click="select(lang)" class="dropdown-item">{{name}} ({{lang}})</button>
	</NavDropdown>
	`
}
