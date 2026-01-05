import { shallowRef } from 'vue'
import { setRootView, addPage } from 'web'
import { url, poll } from 'web/utils'
import { RootView, PageLink } from 'web/widgets'

import { DiagDropdown } from 'diag'
import { PoweroffDropdown } from 'system/power'
import { LocaleDropdown } from 'web/locale'



export const hmiIndex = addPage('hmi');



setRootView({
	setup() {
		return {
			links: [...hmiIndex.children],
		}
	},
	components: { RootView, PageLink, DiagDropdown, LocaleDropdown, PoweroffDropdown },
	template: //html
	`
	<RootView :title="$t('title')">
		<template #navbar>
			<PageLink v-for="to in links" :to />
		</template>
		<template #navbar-right>
			<DiagDropdown />
			<LocaleDropdown />
			<PoweroffDropdown />
		</template>
	</RootView>
	`
});



addPage('/', {
	template: //html
	`
	<div class="jumbotron">
		<h1 class="display-4">Dipl.-Ing. Artur Wiebe</h1>
		<h2>Software-Ingenieur</h2>
		<hr class="my-4">
		
		<p class="lead">
			<i class="fa fa-envelope mr-3"></i>	<a href="mailto:artur@4wiebe.de">artur@4wiebe.de</a> <br>
			<i class="fa fa-phone mr-3"></i>	<a href="tel:+491632699840">+491632699840</a> <br>
			<i class="fa fa-globe mr-3"></i>	<a href="https://engineering.4wiebe.de" target="_blank">engineering.4wiebe.de</a> <br>
		</p>
	</div>
	`
});
