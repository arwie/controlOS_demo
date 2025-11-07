// SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
// SPDX-License-Identifier: MIT

import { ref, shallowRef, computed } from 'vue'
import { url } from 'web/utils'
import { studioIndex } from 'studio'


studioIndex.addPage('simio', {
	targetGuard: 'app@simio',
	async setup() {
		const filter = ref('');
		const list = shallowRef([])
		const data = shallowRef();

		const ws = url('simio', 'app').webSocketJson((msg)=>{
			if (msg.list) {
				list.value = msg.list;
			}
			data.value = msg.data;
		});

		const lists = computed(() => {
			const filterRegex = RegExp(filter.value.replaceAll(/ +/g,'|'), 'i');
			const result = {
				Input:  [],
				Output: [],
			};
			for (const io of list.value.filter((io) => filterRegex.test(io.name)).sort((a, b) => Intl.Collator().compare(a.name, b.name))) {
				result[io.cls].push(io);
			}
			return result;
		});

		function val(io) {
			const ioData = data.value[io.id];
			return io.type == 'float' ? ioData.val.toFixed(3) : ioData.val;
		}

		function ord(io) {
			return data.value[io.id].ord;
		}

		function ordToggle(io) {
			ws.sendJson({id:io.id, ord:(ord(io) !== null ? null : val(io))});
		}

		function ordSendPreset(io, ord) {
			ws.sendJson({id:io.id, ord});
		}

		function ordSendValue(io, event) {
			if (event.keyCode != 13)
				return true;
			let ord = event.target.value;
			if (['bool','int','float'].includes(io.type)) {
				ord = parseFloat(ord.replace(",","."));
				if (isNaN(ord))
					return;
			}
			ws.sendJson({id:io.id, ord});
			event.target.value = null;
		}

		await ws.sync;
		return { filter, lists, data, val, ord, ordToggle, ordSendPreset, ordSendValue }
	},
	template: //html
	`
	<div class="input-group mb-3">
		<button v-if="filter" @click="filter=''" class="btn btn-secondary"><i class="fas fa-times"></i></button>
		<span v-else class="input-group-text"><i class="fas fa-search"></i></span>
		<input v-model.trim="filter" type="text" placeholder="match1 match2 match3 ..." class="form-control">
	</div>
	<div class="row h-100" style="min-height:0">
		<div v-for="(list, cls) in lists" class="col-xxl h-100 overflow-scroll">
			<table class="table table-hover">
				<colgroup>
					<col style="width:auto">
					<col style="width:auto">
					<col style="min-width:150px">
					<col style="min-width:220px">
				</colgroup>  
			<thead>
				<tr>
					<th>{{ $t('studio.simio.cls_'+cls) }}</th>
					<th>{{ $t('studio.simio.type') }}</th>
					<th class="text-end">{{ $t('studio.simio.value') }}</th>
					<th>{{ $t('studio.simio.override') }}</th>
				</tr>
			</thead>
			<tbody>
				<tr v-for="io in list" :key="io.id" :class="{'table-info':io.sim, 'table-warning':io.sim&&ord(io)!==null, 'table-danger':!io.sim&&ord(io)!==null}">
					<th><span class="form-control-plaintext">{{io.name}}</span></th>
					<td><span class="form-control-plaintext">{{io.type}}</span></td>
					<td class="text-end">
						<span :class="{'fw-bold text-success':val(io)}" class="form-control-plaintext">{{val(io)}}</span>
					</td>
					<td>
						<div class="input-group bg-light">
							<label class="input-group-text">
								<input @click="ordToggle(io)" :checked="ord(io)!==null" type="checkbox" class="form-check-input mt-0">
							</label>
							<input @keypress="ordSendValue(io, $event)" :placeholder="ord(io)" type="text" class="form-control">
							<button v-if="['bool'].includes(io.type)"               @click="ordSendPreset(io, 1)" class="w-25 btn btn-outline-success">1</button>
							<button v-if="['bool','int','float'].includes(io.type)" @click="ordSendPreset(io, 0)" class="w-25 btn btn-outline-primary">0</button>
						</div>
					</td>
				</tr>
			</tbody>
			</table>
		</div>
	</div>
	`
})
