// SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
// SPDX-License-Identifier: MIT

import { ref, watch } from 'vue';
import { url } from 'web/utils';


export default class SqliteTable {
	constructor(handler) {
		this.handler = handler;
	}

	url(action, args={}) {
		return url(this.handler).query({ action, ...args });
	}


	list(args={}) {
		return this.url('list', args).fetchJson();
	}

	load(id, args={}) {
		return this.url('load', { id, ...args }).fetchJson();
	}
	
	
	create(args={}) {
		return this.url('create', args).postJson();
	}

	copy(id, args={}) {
		return this.url('copy', { id, ...args }).postJson();
	}

	remove(id, args={}) {
		return this.url('remove', { id, ...args }).postJson();
	}

	save(id, data, args={}) {
		return this.url('save', { id, ...args }).postJson(data);
	}

	swap(id, swap, args={}) {
		return this.url('swap', { id, swap, ...args }).postJson();
	}


	autosaveRef(id, initialData) {
		const dataRef = ref(initialData);
		watch(dataRef, (data, old)=>{
			if (old) {// do not save on initial load
				this.save(id, data);
			}
		}, { deep:true });
		return dataRef;
	}
}
