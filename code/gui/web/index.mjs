// SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
// SPDX-License-Identifier: MIT

import { createApp, shallowRef } from 'vue'
import { createRouter, createWebHashHistory } from 'vue/router'
import { url, poll, isObject } from 'web/utils'
import { i18n } from 'web/locale'



let rootView;

export const app = createApp({
	setup() {
		return { rootView }
	},
	template: '<component :is="rootView"/>'
});
app.config.compilerOptions.whitespace = 'preserve';
app.use(i18n);

export function setRootView(component) {
	rootView = component;
}


const routes = [];
export let router;

export function addPage(path, component, parent=null) {
	const route = {
		path: parent ? path : `/${path}`,
		name: parent ? `${parent.name}.${path}` : path,
		component,
		children: [],
		addPage(path, component) {
			return addPage(path, component, this);
		},
		open(query) {
			router.push({ ...this, query });
		},
	}
	if (component && component.targetGuard) {
		route.beforeEnter = () => target(component.targetGuard) || parent || { path:'/' };
	}
	(parent?.children || routes).push(route);
	return route;
}


const targets = shallowRef([]);

export function target(target) {
	return targets.value.includes(target);
}



export default async function() {
	router = createRouter({
		history: createWebHashHistory(),
		routes,
	});
	app.use(router);

	function disconnected() {
		if (watchdog !== null) {
			watchdog = null;
			console.log('GUI: disconnected!');
			document.getElementById('gui-disconnected')?.showModal();
			poll(3000, ()=>{
				url('web.targets').post(null, { signal: AbortSignal.timeout(3000) })
					.then(()=>location.reload())
					.catch(()=>console.log('GUI: trying to reconnect...'));
			});
		}
	}
	let watchdog = true;

	const ws = url('web.targets').webSocketJson((msg)=>{
		if (Array.isArray(msg)) {
			targets.value = msg;
			for (const matched of router.currentRoute.value.matched) {
				const guard = matched.beforeEnter?.();
				if (isObject(guard)) {
					router.replace(guard);
				}
			}
		}
		clearTimeout(watchdog);
		watchdog = setTimeout(disconnected, 15000);
	});
	ws.onclose = ws.onerror = disconnected;

	await ws.sync;
	app.mount('#gui-view');
}
