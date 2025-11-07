// SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
// SPDX-License-Identifier: MIT

import { ref, shallowReactive, watch } from 'vue'
import { target } from 'web'
import { url } from 'web/utils'
import { FileButton, feedback } from 'web/widgets'
import { BFormCheckbox } from 'bootstrap/vue'
import { diagIndex } from 'diag'


import config from '/diag.log.config'
config.desktop = document.documentElement.clientWidth > 1600;


const prioClasses = ['table-critical','table-critical','table-critical','table-danger','table-warning','table-info','',''];

const maskFields = ['MESSAGE','PRIORITY','SYSLOG_IDENTIFIER'];



const Message = {
	props: ['msg'],
	emits: ['pin'],
	setup(props) {

		const msg = props.msg;

		const timestamp = parseInt(msg._SOURCE_REALTIME_TIMESTAMP ?? msg.__REALTIME_TIMESTAMP) / 1000;

		msg.PRIORITY = parseInt(msg.PRIORITY);

		function value(field) {
			const value = msg[field];
			if (value===null || Array.isArray(value) || value.length>4096) {
				const a = document.createElement('a');
				a.href = url('diag.log.cat').query({field, cursor:msg.__CURSOR});
				a.download = field;
				a.textContent = 'download';
				return a.outerHTML;
			}
			const div = document.createElement('div');
			div.textContent = value;
			return div.innerHTML;
		}

		const details = ref(0);

		function fields() {
			if (details.value) {
				const fields = Object.keys(msg).sort();
				switch (details.value) {
					case 1: return fields.filter(f => !f.startsWith('_') && !maskFields.includes(f));
					case 2: return fields.filter(f => !f.startsWith('__'));
					default: return fields;
				}
			}
		}

		return { msg, timestamp, prioClasses, value, details, fields, config };
	},
	template: //html
	`
	<tr @click="details=details?0:1" :class="prioClasses[msg.PRIORITY]">
		<td>
			{{ $d(timestamp, { year:'numeric', month:'numeric', day:'numeric', hour:'2-digit', minute:'2-digit', second:'2-digit', hour12:false }) }}
			<div v-if="details && config.desktop" class="my-3 d-grid gap-2">
				<button @click.stop="details++"
					class="btn btn-light"><i class="fas fa-plus-circle"></i></button>
				<button @click.stop="$emit('pin')"
					class="btn btn-light"><i class="fas fa-thumbtack"></i></button>
			</div>
		</td>
		<td>{{ $t('diag.log.priority_' + msg.PRIORITY) }}</td>
		<td v-if="config.hosts.length>1">{{msg._HOSTNAME}}</td>
		<td>{{msg.SYSLOG_IDENTIFIER}}</td>
		<td width="70%">
			<strong v-html="value('MESSAGE')" style="white-space:pre-wrap"></strong>
			<table v-if="details" @click.stop class="table table-sm mt-3">
				<tbody>
					<tr v-for="key in fields()">
						<td width="20%">{{key}}</td>
						<td v-html="value(key)" style="white-space:pre-wrap"></td>
					</tr>
				</tbody>
			</table>
		</td>
	</tr>
	`
}



diagIndex.addPage('log', {
	async setup() {

		const messages		= shallowReactive([]);
		
		const follow		= ref(null);
		const priority		= ref(target('debug') ? 7 : 5);
		const identifier	= ref('');
		const host			= ref('');
		const date			= ref(null);
		const grep			= ref(null);
		const filter		= ref(null);
		const pinned		= ref(null);

		watch(follow, (value)=>{
			if (value) {
				date.value   = undefined;
				pinned.value = undefined;
				update();
			} else {
				disconnect();
				if (value !== undefined && !messages.length)
					update();
			}
		});
		watch(date, (value)=>{
			if (value) {
				follow.value = undefined;
				pinned.value = undefined;
			}
			if (value !== undefined)
				update();
		});
		watch(pinned, (value)=>{
			if (value) {
				follow.value = undefined;
				date.value   = undefined;
			}
			if (value !== undefined)
				update();
		});
		watch([priority, identifier, host, grep, filter], update);

		function query(lines, extendMsg, args={}) {
			args.priority = priority.value;
			if (identifier.value)
				args.identifier = identifier.value;
			if (grep.value)
				args.grep = grep.value;

			let filterValue = filter.value;
			if (host.value)
				filterValue += ' _HOSTNAME='+host.value;
			if (filterValue)
				args.filter = filterValue;

			function logFeed(onMsg) {
				const feed = url('diag.log.feed').query(args).webSocketJson(onMsg);
				if (!extendMsg)
					feed.onopen = ()=>{
						messages.length = 0;
					};
				return feed;
			}

			if (!lines) {
				return logFeed((msg)=>{
					messages.unshift(msg);
					if (messages.length > 300)
						messages.pop();
				});
			}

			args.lines = lines;
			if (extendMsg) {
				args.cursor = extendMsg.__CURSOR;
			}

			if (lines>0) {
				return logFeed((msg)=>{
					messages.unshift(msg);
				});
			} else {
				return logFeed((msg)=>{
					messages.push(msg);
				});
			}
		}

		function extend(lines) {
			const msg = messages[lines>0 ? 0 : messages.length-1];
			query(lines, msg)
				.onclose = ()=>{
					scroll(msg, lines>0 ? 'end' : 'start', false);
				};
		}

		let logFeed;

		function update() {
			disconnect();
			
			if (follow.value) {
				logFeed = query();
				logFeed.onclose = logFeed.onerror = ()=>{ follow.value = null; }
				return;
			}
			if (date.value) {
				query(300, null, {date:date.value});
				return;
			}
			if (pinned.value) {
				query(5, pinned.value)
					.onopen = ()=>{
						messages.splice(0, messages.length, pinned.value);
						query(-20, pinned.value)
							.onclose = ()=>{
								scroll(pinned.value);
							};
					};
				return;
			}
			query(-150);
		}

		function disconnect() {
			if (logFeed) {
				logFeed.onclose = logFeed.onerror = null;
				logFeed.close();
			}
		}

		if (config.extlog) {
			update();
		} else {
			follow.value = true;
		}

		function extendNewer() {
			extend(25);
		}

		function extendOlder() {
			follow.value = undefined;
			if (messages.length) {
				extend(-50);
			} else {
				update();
			}
		}

		function scroll(msg, block='center', open=true) {
			setTimeout(()=>{
				document.getElementById(msg.__CURSOR).scrollIntoView({block, behavior:'smooth'});
			}, 50);
		}

		async function fetchIdentifiers() {
			const data = await url('diag.log.field').query({field:'SYSLOG_IDENTIFIER'}).fetchJson();
			identifiers.push(...data.sort());
		}

		async function extlogImport(file, element) {
			await feedback(element, url('extlog.journal').put(file));
			update();
			fetchIdentifiers();
		}

		const identifiers = shallowReactive([]);

		await new Promise(resolve => {
			setTimeout(()=>{
				resolve();
				fetchIdentifiers();
			}, 50);
		});

		return { messages, follow, date, pinned, grep, filter, priority, identifier, identifiers, host, config, extendNewer, extendOlder, scroll, extlogImport }
	},
	components: { Message, FileButton, BFormCheckbox },
	template: //html
	`
	<div class="row h-100">

	<component is="style">
		.table-critical > td { background: salmon; }
	</component>

	<div class="col-xl-2 d-flex flex-column">
		<button v-if="config.desktop" @click="extendNewer" :disabled="follow || !messages.length" class="btn btn-secondary w-100 mb-3">{{ $t('diag.log.extendNewer') }}</button>
		
		<div v-if="!config.extlog" :class="follow ? 'alert-success' : 'alert-warning'" class="alert">
			<BFormCheckbox v-model="follow">{{ $t('diag.log.follow') }}</BFormCheckbox>
		</div>
		<FileButton v-else @file="extlogImport" class="btn-primary w-100 mb-3">{{ $t('diag.log.extlogImport') }}</FileButton>
		
		<div class="row">
			<div class="col col-xl-12">
				<div class="mb-3">
					<label class="form-label">{{ $t('diag.log.priority') }}</label>
					<select v-model="priority" class="form-select">
						<option v-for="prio in [0,1,2,3,4,5,6,7]" :value="prio">{{ $t('diag.log.priority_' + prio) }}</option>
					</select>
				</div>
				<div class="mb-3">
					<label class="form-label">{{ $t('diag.log.identifier') }}</label>
					<select v-model="identifier" class="form-select">
						<option value="">-</option>
						<option v-for="ident in identifiers" :value="ident">{{ident}}</option>
					</select>
				</div>
			</div>
			<div class="col col-xl-12">
				<div v-if="config.hosts.length>1" class="mb-3">
					<label class="form-label">{{ $t('diag.log.host') }}</label>
					<select v-model="host" class="form-select">
						<option value="">-</option>
						<option v-for="hst in config.hosts" :value="hst">{{hst}}</option>
					</select>
				</div>
				<div class="mb-3">
					<label class="form-label">{{ $t('diag.log.date') }}</label>
					<div class="input-group">
						<input v-model.lazy.trim="date" type="text" placeholder="YYYY-MM-DD" class="form-control">
						<button @click="date=null" class="btn btn-secondary"><i class="fas fa-times"></i></button>
					</div>
				</div>
			</div>
		</div>
		
		<div v-if="config.desktop" class="mb-3">
			<label class="form-label">{{ $t('diag.log.grep') }}</label>
			<div class="input-group">
				<input v-model.lazy.trim="grep" type="text" placeholder="regexp" class="form-control">
				<button @click="grep=null" class="btn btn-secondary"><i class="fas fa-times"></i></button>
			</div>
		</div>
		<div v-if="config.desktop" class="mb-3">
			<label class="form-label">{{ $t('diag.log.filter') }}</label>
			<div class="input-group">
				<input v-model.lazy.trim="filter" type="text" placeholder="FIELD=value FIELD=value" class="form-control">
				<button @click="filter=null" class="btn btn-secondary"><i class="fas fa-times"></i></button>
			</div>
		</div>
		<div v-if="config.desktop && pinned" class="mb-3">
			<label class="form-label">{{ $t('diag.log.pinned') }}</label>
			<div class="input-group">
				<input :value="pinned.MESSAGE" @click="scroll(pinned)" type="text" class="form-control" style="cursor:pointer" readonly>
				<button @click="pinned=null" class="btn btn-secondary"><i class="fas fa-times"></i></button>
			</div>
		</div>
		
		<button v-if="config.desktop" @click="extendOlder" class="btn btn-secondary w-100 mt-auto mb-3">{{ $t('diag.log.extendOlder') }}</button>
	</div>

	<div class="col-xl h-100 overflow-scroll" id="log">
		<div v-if="!messages.length" class="alert alert-info">{{ $t('diag.log.empty') }}</div>
		<table class="table table-sm table-hover">
			<tbody>
				<Message
					v-for="msg in messages"
					:key="msg.__CURSOR"
					:id="msg.__CURSOR"
					:msg="msg"
					@pin="pinned=msg"
				/>
			</tbody>
		</table>
	</div>

	</div>
	`
})
