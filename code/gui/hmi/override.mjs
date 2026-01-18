import { ref } from 'vue'
import { url, poll } from 'web/utils'
import { target } from 'web'



export const RobotOverride = {
	setup() {

		const overrideUrl = url('robot_override', 'app');

		const override = ref(null);

		const overridePoll = poll(500, async ()=>{
			override.value = target('app@robot_override') ? await overrideUrl.fetchJson() : null;
		});

		async function set(value) {
			await overrideUrl.postJson(parseFloat(value));
			overridePoll();
		}

		return { override, set };
	},
	template: //html
	`
	<div class="d-flex align-items-center">
		<i :class="{'text-primary':override!==null}" class="fa fa-robot me-2"></i>
		<input
			:value="override"
			:disabled="override===null"
			@input="set($event.target.value)"
			type="range"
			class="form-range"
		>
	</div>
	`
}
