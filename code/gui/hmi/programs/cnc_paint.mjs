import { shallowReactive, shallowRef } from 'vue'
import { BFormCheckbox } from 'bootstrap/vue'
import { url, poll } from 'web/utils'
import { hmiIndex } from 'hmi';



hmiIndex.addPage('cnc_paint', {
	targetGuard: 'app@cnc_paint',
	async setup() {

		const info = shallowRef();
		const paths = shallowReactive([]);

		const model = shallowRef('HAIKU');
		const thinking = shallowRef(false);
		const history = shallowReactive([]);
		const prompt = shallowRef('');
		const chatting = shallowRef(false);

		const ws = url('cnc_paint', 'app').webSocketJson((msg)=>{
			info.value = msg;
		});

		function getEventPos(event) {
			let svg = event.target.ownerSVGElement;
			let p = svg.createSVGPoint();
			p.x = event.clientX; p.y = event.clientY;
			p = p.matrixTransform(svg.getScreenCTM().inverse());
			return { x:p.x, y:-p.y };
		}

		let newPath = null;

		function pointerdown(event) {
			newPath = shallowReactive([getEventPos(event)]);
		}
		
		function pointermove(event) {
			if (!event.buttons)
				return;
			
			let lp = newPath[newPath.length-1];
			let np = getEventPos(event);
			const minDist = 1;
			
			if (Math.abs(lp.x-np.x)<minDist && Math.abs(lp.y-np.y)<minDist)
				return;
			
			if (newPath.length==1)
				paths.push(newPath);
			
			newPath.push(np);
		}
		
		function play() {
			ws.sendJson({ cmd:1, paths });
		}

		async function chat() {
			chatting.value = true;
			const request = {
				model: model.value,
				thinking: thinking.value,
				prompt: prompt.value,
			};
			history.push({ role: 'user', text: prompt.value });
			prompt.value = '';
			try {
				const response = await url('hmi.programs.cnc_paint.claude').postJson(request);
				if ('polylines' in response)
					paths.push(...response.polylines.filter(p => p.length >= 2));
				if ('thinking' in response)
					history.push({ role: 'assistant', text: response.thinking });
				if ('answer' in response)
					history.push({ role: 'assistant', text: response.answer });
			} catch {}
			chatting.value = false;
		}
		
		function clear() {
			paths.length = 0;
			prompt.value = '';
			history.length = 0;
		}

		await ws.sync;

		return { info, paths, history, model, thinking, prompt, chatting, pointerdown, pointermove, play, chat, clear };
	},
	components: { BFormCheckbox },
	template: //html
	`
	<div class="row mh-100">
		<div class="col-md-8 h-100 d-flex flex-column pb-3">
			<svg viewBox="-160 -160 320 320" style="touch-action: none">
				<circle @pointerdown="pointerdown" @pointermove="pointermove" cx="0" cy="0" r="160" fill="skyblue"/>
				<circle :cx="info.pos.x" :cy="-info.pos.y" r="5" fill="red"/>
				<polyline v-for="path in paths" :points="path.map(p=>[p.x,-p.y].join(',')).join(' ')"
					fill="none" stroke-width="3" stroke="black"/>
			</svg>
		</div>
		<div class="col-md d-flex flex-column h-100">
			<div class="d-flex gap-2 mb-3">
				<button @click="play" :disabled="!paths.length"
					class="btn btn-lg btn-success w-75"><i class="fas fa-play"></i></button>
				<button @click="clear"
					class="btn btn-warning w-25"><i class="fas fa-trash"></i></button>
			</div>
			<div class="mt-auto overflow-auto mb-3">
				<div v-for="msg in history"
					:class="msg.role === 'user' ? 'alert-primary text-end' : 'alert-success text-start'"
					class="alert"
				>{{ msg.text }}</div>
				<div v-show="chatting" class="alert alert-light"><i class="fas fa-spinner fa-spin"></i></div>
			</div>
			<div class="mb-3">
				<label class="form-label">{{ $t('hmi.cnc_paint.prompt', { model }) }}</label>
				<div class="input-group input-group-lg">
					<input v-model="prompt" @keyup.enter="chat" :disabled="chatting" class="form-control">
					<button @click="chat" :disabled="chatting || !prompt" class="btn btn-primary">
						<i class="fas fa-paper-plane"></i>
					</button>
				</div>
			</div>
			<div class="mb-3">
				<label class="form-label">{{ $t('hmi.cnc_paint.model') }}</label>
				<div class="d-flex gap-3 align-items-center">
					<select v-model="model" class="form-select">
						<option v-for="model in ['HAIKU','SONNET','OPUS']" :value="model">{{ model }}</option>
					</select>
					<BFormCheckbox v-model="thinking" switch>{{ $t('hmi.cnc_paint.thinking') }}</BFormCheckbox>
				</div>
			</div>
		</div>
	</div>
	`
})
