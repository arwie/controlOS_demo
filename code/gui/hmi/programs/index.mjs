import { ref } from 'vue'
import { url } from 'web/utils'
import { hmiIndex } from 'hmi'

import files from '/web.files'
import programs from '/hmi.programs.programs'



hmiIndex.addPage('programs', {
	async setup() {

		const selected = ref(null);

		const ws = url('hmi.programs.select').webSocketJson((msg)=>{
			selected.value = msg;
		});

		function select(program) {
			ws.sendJson(program);
		}

		await ws.sync;

		return { files, programs, selected, select };
	},
	template: //html
	`
	<div class="row pb-3 h-100">
		<div class="col-lg-5 d-flex flex-column h-100">
			<div class="card mb-3" style="min-height:0">
				<h5 class="card-header">{{ $t('hmi.programs.list') }}</h5>
				<div class="list-group list-group-flush h-100 overflow-scroll">
					<button
						v-for="program in programs"
						@click="select(program)"
						class="list-group-item list-group-item-action"
						:class="{active: program==selected}"
						style="min-height:4rem;"
					><strong>{{ $t('hmi.'+program+'.title') }}</strong></button>
				</div>
			</div>
			<button
				@click="select(null)"
				:disabled="!selected"
				class="btn btn-lg btn-secondary w-100 mt-auto"
			>{{ $t('cancel') }}</button>
		</div>
		<div v-if="selected" class="col-lg">
			<h1>{{ $t('hmi.'+selected+'.title') }}</h1>
			<p class="lead">{{ $t('hmi.'+selected+'.description', '') }}</p>
			<img
				v-if="'hmi/programs/'+selected+'.jpg' in files"
				:src="files['hmi/programs/'+selected+'.jpg']"
				class="mb-3 w-100"
			/>
		</div>
	</div>
	`
})
