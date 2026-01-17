import { shallowReactive, shallowRef } from 'vue'
import { url, poll } from 'web/utils'
import { hmiIndex } from 'hmi';



hmiIndex.addPage('cnc_paint', {
	targetGuard: 'app@cnc_paint',
	async setup() {

		const info = shallowRef();
		const paths = shallowReactive([]);

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
		
		function clear() {
			paths.length = 0;
		}

		await ws.sync;

		return { info, paths, pointerdown, pointermove, play, clear };
	},
	template: //html
	`
	<div class="row">
		<div class="col-md-9">
			<button @click="play" :disabled="!paths.length"
				class="btn btn-lg btn-success w-100"><i class="fas fa-play"></i></button>
		</div>
		<div class="col-md-3">
			<button @click="clear"
				class="btn btn-lg btn-warning w-100"><i class="fas fa-trash"></i></button>
		</div>
	</div>
	<svg viewBox="-160 -160 320 320" class="my-4" touch-action="none">
		<circle @pointerdown="pointerdown" @pointermove="pointermove" cx="0" cy="0" r="160" fill="skyblue"/>
		<circle :cx="info.pos.x" :cy="-info.pos.y" r="5" fill="red"/>
		<polyline v-for="path in paths" :points="path.map(p=>[p.x,-p.y].join(',')).join(' ')"
			fill="none" stroke-width="3" stroke="black"/>
	</svg>
	`
})
