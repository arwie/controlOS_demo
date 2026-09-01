import { ref } from 'vue'
import { url } from 'web/utils'



export const RobotOverride = {
	setup() {

		const override = ref();

		const ws = url('hmi.robot.override').webSocketJson((msg)=>{
			override.value = msg;
		});

		function set(value) {
			ws.sendJson(parseFloat(value));
		}

		return { override, set };
	},
	template: //html
	`
	<div class="d-flex align-items-center">
		<i class="fa fa-robot me-2"></i>
		<input
			:value="override"
			@input="set($event.target.value)"
			type="range"
			class="form-range"
		>
	</div>
	`
}
