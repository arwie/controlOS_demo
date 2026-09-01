import { ref, shallowRef } from 'vue'
import { url, poll } from 'web/utils'
import { PressButton } from 'web/widgets'
import { hmiIndex } from 'hmi';



hmiIndex.addPage('jog', {
	show: 'hmi.programs.jog',
	async setup() {

		const info = shallowRef();
		const speed = ref(3);
		const snap = ref({x:'', y:'', z:'', r:''});

		const ws = url('hmi.programs.jog.main').webSocketJson((msg)=>{
			info.value = msg;
		});

		function sendCmd(cmd, args={}) {
			args.cmd = cmd;
			if (cmd > 0) {
				args.speed = speed.value;
				args.snap = snap.value;
			}
			//console.log(args);
			ws.sendJson(args);
		}

		function moveStop()		{ sendCmd(0); }
		function moveDelta(dir)	{ sendCmd(1,  { dir }); }
		function moveConv(dir)	{ sendCmd(11, { dir }); }
		function moveExtra(dir)	{ sendCmd(12, { dir }); }
		
		function selectTool(event) {
			sendCmd(-1, { tool:parseInt(event.target.value) });
		}
		function gripTool() {
			sendCmd(-2, { grip:!info.value.gripped });
		}

		const watchdog = poll(100, ()=>{
			if (ws.readyState == WebSocket.OPEN)
				sendCmd(-1);
		});

		await ws.sync;

		return { info, speed, snap, moveStop, moveDelta, moveConv, moveExtra, selectTool, gripTool }
	},
	components: { PressButton },
	template: //html
	`
	<div class="mb-3">
		<label class="form-label">{{ $t('hmi.jog.pos') }}</label>
		<div class="row gy-1 gx-3">
			<div v-for="k in ['x','y','z','r']" class="input-group col-sm">
				<span class="input-group-text">{{k.toUpperCase()}}</span>
				<input :value="info.robot.pos[k].toFixed(2)" type="text" class="form-control" readonly>
			</div>
		</div>
	</div>

	<div class="mb-3">
		<label class="form-label">{{ $t('hmi.jog.snap') }}</label>
		<div class="row gy-1 gx-3">
			<div v-for="k in ['x','y','z','r']" class="input-group col-sm">
				<span class="input-group-text">{{k.toUpperCase()}}</span>
				<input v-model.number="snap[k]" type="number" class="form-control">
			</div>
		</div>
	</div>

	<div class="mb-3">
		<label class="form-label">{{ $t('hmi.jog.speed') }}</label>
		<input v-model.number="speed" type="range" min="0.1" max="8" step="0.1" class="form-range">
	</div>

	<div class="row my-5">
		<div class="col">
			<PressButton @press="moveDelta({z:1})" @release="moveStop" class="btn btn-lg btn-secondary w-100"><i class="fa fa-plus"></i> Z</PressButton>
		</div>
		<div class="col"></div>
		<div class="col">
			<PressButton @press="moveDelta({y:1})" @release="moveStop" class="btn btn-lg btn-secondary w-100"><i class="fa fa-plus"></i> Y</PressButton>
		</div>
		<div class="col"></div>
		<div class="col">
			<PressButton @press="moveDelta({r:1})" @release="moveStop" class="btn btn-lg btn-secondary w-100"><i class="fa fa-plus"></i> R</PressButton>
		</div>
	</div>
	<div class="row my-5">
		<div class="col"></div>
		<div class="col">
			<PressButton @press="moveDelta({x:-1})" @release="moveStop" class="btn btn-lg btn-secondary w-100"><i class="fa fa-minus"></i> X</PressButton>
		</div>
		<div class="col"></div>
		<div class="col">
			<PressButton @press="moveDelta({x:1})" @release="moveStop" class="btn btn-lg btn-secondary w-100"><i class="fa fa-plus" ></i> X</PressButton>
		</div>
		<div class="col"></div>
	</div>
	<div class="row my-5">
		<div class="col">
			<PressButton @press="moveDelta({z:-1})" @release="moveStop" class="btn btn-lg btn-secondary w-100"><i class="fa fa-minus" ></i> Z</PressButton>
		</div>
		<div class="col"></div>
		<div class="col">
			<PressButton @press="moveDelta({y:-1})" @release="moveStop" class="btn btn-lg btn-secondary w-100"><i class="fa fa-minus" ></i> Y</PressButton>
		</div>
		<div class="col"></div>
		<div class="col">
			<PressButton @press="moveDelta({r:-1})" @release="moveStop" class="btn btn-lg btn-secondary w-100"><i class="fa fa-minus"></i> R</PressButton>
		</div>
	</div>

	<hr class="my-4">

	<div class="row mb-3">
		<div class="col-lg">
			<label class="form-label">{{ $t('hmi.jog.conv') }}</label>
			<div class="input-group input-group-lg">
				<PressButton @press="moveConv(-1)" @release="moveStop" class="btn btn-secondary w-25">
					<i class="fas fa-minus"></i>
				</PressButton>
				<input :value="info.conv.pos.toFixed(2)" class="form-control text-center" disabled>
				<PressButton @press="moveConv(1)" @release="moveStop" class="btn btn-secondary w-25">
					<i class="fas fa-plus"></i>
				</PressButton>
			</div>
		</div>
		<div class="col-lg">
			<label class="form-label">{{ $t('hmi.jog.extra') }}</label>
			<div class="input-group input-group-lg">
				<PressButton @press="moveExtra(-1)" @release="moveStop" class="btn btn-secondary w-25">
					<i class="fas fa-minus"></i>
				</PressButton>
				<input :value="info.extra.pos.toFixed(2)" class="form-control text-center" disabled>
				<PressButton @press="moveExtra(1)" @release="moveStop" class="btn btn-secondary w-25">
					<i class="fas fa-plus"></i>
				</PressButton>
			</div>
		</div>
	</div>

	<hr class="my-4">

	<div class="mb-3">
		<label class="form-label">{{ $t('hmi.jog.tool') }}</label>
		<div class="row">
			<div class="col">
				<select @change="selectTool" :value="info.tool" class="form-select">
					<option value="0" >{{ $t('hmi.jog.tool_none') }}</option>
					<option value="1" >{{ $t('hmi.jog.tool_magnet') }}</option>
					<option value="2" >{{ $t('hmi.jog.tool_vacuum') }}</option>
					<option value="10">{{ $t('hmi.jog.tool_laser') }}</option>
					<option value="11">{{ $t('hmi.jog.tool_probe') }}</option>
				</select>
			</div>
			<div class="col-2">
				<div class="form-check form-switch mt-2">
					<input @change="gripTool" :value="info.gripped" type="checkbox" class="form-check-input" id="jog_grip">
					<label class="form-check-label" for="jog_grip">{{ $t('hmi.jog.grip') }}</label>
				</div>
			</div>
		</div>
	</div>
	`
})
