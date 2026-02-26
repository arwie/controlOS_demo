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
			const data = list.value.filter((io) => filterRegex.test(io.module) || filterRegex.test(io.name))
				.sort((a, b) => a.module.localeCompare(b.module) || a.name.localeCompare(b.name));
			for (const io of data) {
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

		function ordSendValue(io, ord) {
			if (['bool','int','float'].includes(io.type)) {
				ord = parseFloat(ord.replace(",","."));
				if (isNaN(ord))
					return;
			}
			ws.sendJson({id:io.id, ord});
		}

		await ws.sync;
		return { filter, lists, data, val, ord, ordToggle, ordSendValue }
	},
	template: //html
	`
	<div class="input-group mb-3">
		<button v-if="filter" @click="filter=''" class="btn btn-secondary"><i class="fas fa-times"></i></button>
		<span v-else class="input-group-text"><i class="fas fa-search"></i></span>
		<input v-model.trim="filter" type="text" placeholder="match1 match2 match3 ..." class="form-control">
	</div>
	<div class="row h-100" style="min-height:0">
		<div v-for="(list, cls) in lists" class="col-xxl h-100 overflow-y-scroll">
			<table class="table table-hover">
				<colgroup>
					<col style="width:auto">
					<col style="width:auto">
					<col style="width:auto">
					<col style="min-width:130px">
					<col style="min-width:220px">
				</colgroup>  
			<thead>
				<tr>
					<th colspan="2">{{ $t('studio.simio.cls_'+cls) }}</th>
					<th>{{ $t('studio.simio.type') }}</th>
					<th class="text-end">{{ $t('studio.simio.value') }}</th>
					<th>{{ $t('studio.simio.override') }}</th>
				</tr>
			</thead>
			<tbody>
				<tr v-for="io in list" :key="io.id" :class="{'table-info':io.sim, 'table-warning':io.sim&&ord(io)!==null, 'table-danger':!io.sim&&ord(io)!==null}">
					<td><span class="form-control-plaintext">{{ io.module }}</span></td>
					<th><span class="form-control-plaintext">{{ io.name }}</span></th>
					<td><span class="form-control-plaintext">{{ io.type }}</span></td>
					<td class="text-end">
						<span :class="{'fw-bold text-success':val(io)}" class="form-control-plaintext">{{val(io)}}</span>
					</td>
					<td>
						<div class="input-group bg-light">
							<label class="input-group-text">
								<input class="form-check-input mt-0"
									:checked="ord(io) !== null"
									@click="ordToggle(io)"
									type="checkbox"
								>
							</label>
							<input class="form-control"
								:placeholder="ord(io)"
								@keyup.enter="ordSendValue(io, $event.target.value); $event.target.value = null;"
								@blur="$event.target.value = null"
							>
							<button class="w-25 btn btn-outline-success"
								v-if="['bool'].includes(io.type)"
								@click="ordSendValue(io, $event.target.innerText)"
							>1</button>
							<button class="w-25 btn btn-outline-primary"
								v-if="['bool','int','float'].includes(io.type)"
								@click="ordSendValue(io, $event.target.innerText)"
							>0</button>
						</div>
					</td>
				</tr>
			</tbody>
			</table>
		</div>
	</div>
	`
})
