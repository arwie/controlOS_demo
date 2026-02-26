// SPDX-FileCopyrightText: 2026 Artur Wiebe <artur@4wiebe.de>
// SPDX-License-Identifier: MIT

import { shallowRef, ref, computed, reactive } from 'vue'
import { url } from 'web/utils'
import { diagIndex } from 'diag'


diagIndex.addPage('watch', {
	targetGuard: 'app@watch',
	async setup() {

		const data = shallowRef();
		const filter = ref('');
		const filterRegex = computed(() => RegExp(filter.value.replaceAll(/ +/g,'|'), 'i'))
		const expanded = reactive(new Set())

		const ws = url('watch', 'app').webSocketJson((msg)=>{
			data.value = msg;
		});
		await ws.sync;

		const sorted = function(obj) {
			return Object.fromEntries(Object.entries(obj).sort(([a], [b]) => a.localeCompare(b)));
		}

		const format = function(value, expand=false) {
			return JSON.stringify(
				value,
				(k, v) => typeof v === 'number' ? parseFloat(v.toFixed(3)) : v,
				expand ? 4 : 0,
			);
		}

		return { data, sorted, format, filter, filterRegex, expanded }
	},
	template: //html
	`
	<div class="input-group mb-3">
		<button v-if="filter" @click="filter=''" class="btn btn-secondary"><i class="fas fa-times"></i></button>
		<span v-else class="input-group-text"><i class="fas fa-search"></i></span>
		<input v-model.trim="filter" type="text" placeholder="match1 match2 match3 ..." class="form-control">
	</div>
	<div class="overflow-y-scroll">
		<table class="table table-hover">
			<tbody v-for="(ws, module) in sorted(data)" class="table-group-divider">
				<template v-for="(value, name) in sorted(ws)">
				<tr v-if="filterRegex.test(module) || filterRegex.test(name)">
					<td>{{ module }}</td>
					<th>{{ name }}</th>
					<td :class="{'fw-bold':value}"
						@click="expanded.add(module+name)"
						style="white-space:pre-wrap; cursor:pointer"
						width="60%"
					>{{ format(value, expanded.has(module+name)) }}</td>
				</tr>
				</template>
			</tbody>
		</table>
	</div>
	`
})
