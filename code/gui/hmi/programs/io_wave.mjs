import { shallowRef } from 'vue'
import { url } from 'web/utils'
import { hmiIndex } from 'hmi'



hmiIndex.addPage('io_wave', {
	targetGuard: 'app@io_wave',
	async setup() {

		const info = shallowRef();

		const ws = url('io_wave', 'app').webSocketJson((msg)=>{
			info.value = msg;
		});
		await ws.sync;

		return { info };
	},
	template: //html
	`
	<h1 class="my-5 mx-4" style="font-size: 6rem;">
		Switches per second: <strong>{{ info.switches_per_second }}</strong>
	</h1>
	<svg viewBox="-10 -30 320 60">
		<circle v-for="io,x in info.out" :cx="20*x" cy="-15" r="7" :fill="io ? 'red'   : 'skyblue'"/>
		<circle v-for="io,x in info.in"  :cx="20*x" cy="+15" r="7" :fill="io ? 'green' : 'skyblue'"/>
	</svg>
	`
})
