// SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
// SPDX-License-Identifier: MIT

import { onUnmounted } from 'vue'


const ports = {
	app:	33000,
}



export function url(url='', port=null, host=null) {

	host ??= location.hostname;
	port = ports[port] || port || location.port;
	let query = '';

	return {

		query(params) {
			if (params)
				query = `?${new URLSearchParams(params).toString()}`;
			return this;
		},

		async fetch(options={}, responseType='text') {
			const response = await fetch(this, options);
			if (!response.ok) {
				throw new Error(`url fetch error: ${response.status}`);
			}
			return response[responseType]();
		},

		async fetchJson(options={}) {
			const result = await this.fetch(options)
			return jsonParse(result)
		},

		post(body, options={}) {
			return this.fetch({ method:'POST', body, ...options});
		},

		async postJson(body, options={}) {
			if (body && !(body instanceof Blob)) {
				body = jsonStringify(body);
			}
			const result = await this.post(body, options);
			return jsonParse(result);
		},

		put(body, options={}) {
			return this.fetch({ method:'PUT', body, ...options});
		},

		webSocket(handler) {
			const ws = new WebSocket(this.toString('ws:'));
			ws.sync = new Promise(resolve => {
				ws.onmessage = (msg) => {
					handler(msg.data);
					resolve();
				};
			});
			onUnmounted(()=>{
				ws.onclose = ws.onerror = ws.onmessage = null;
				ws.close();
			});
			return ws;
		},

		webSocketJson(handler) {
			const ws = this.webSocket(
				msg => handler(jsonParse(msg))
			);
			ws.sendJson = function(data={}) {
				ws.send(jsonStringify(data));
			};
			return ws;
		},

		toString(protocol=location.protocol) {
			return `${protocol}//${host}:${port}/${url}${query}`;
		},
	};
}


export function poll(period, func) {
	func.sync = new Promise(async resolve => {
		await func();
		resolve();
	});
	func.interval = setInterval(func, period);
	func.clear = () => clearInterval(func.interval);
	onUnmounted(func.clear);
	return func;
}


export function jsonStringify(msg) {
	return JSON.stringify(msg, (k, v) => (v === undefined) ? null : v);
}

export function jsonParse(msg) {
	return msg ? JSON.parse(msg) : null;
}


export function isObject(item) {
	return (item && typeof item === 'object' && !Array.isArray(item));
}

export function updateDeep(target, source) {
	if (isObject(source)) {
		for (const key in target) {
			if (isObject(target[key])) {
				updateDeep(target[key], source[key]);
			} else if(Object.hasOwn(source, key)) {
				target[key] = source[key];
			}
		}
	}
}
