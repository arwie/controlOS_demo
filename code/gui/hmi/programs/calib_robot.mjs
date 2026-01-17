import { shallowRef, ref } from 'vue'
import { url, poll } from 'web/utils'
import { ButtonBar, feedback } from 'web/widgets'
import { hmiIndex } from 'hmi'



hmiIndex.addPage('calib_robot', {
	targetGuard: 'app@calib_robot',
	setup() {

		const drivesUrl = url('calib_robot', 'app');

		const calibPos = ref(310);
		const drives = shallowRef([]);

		const drivesPoll = poll(500, async ()=>{
			drives.value = await drivesUrl.fetchJson();
		});

		async function save(ev, name) {
			await feedback(ev.target, drivesUrl.postJson({ name, calibPos:calibPos.value }));
			drivesPoll();
		}

		return { calibPos, drives, save };
	},
	template: //html
	`
	<div class="mb-4">
		<label class="form-label">{{ $t('hmi.calib_robot.calibPos') }}</label>
		<input v-model.number="calibPos" type="number" step="any" class="form-control">
	</div>
	<div v-for="drive in drives" :key="drive.name" class="mb-3">
		<label class="form-label">{{ drive.name }}</label>
		<div class="row gy-2">
			<div class="col-lg input-group">
				<span class="input-group-text">{{ $t('hmi.calib_robot.encoder') }}</span>
				<input :value="drive.encoder.toFixed(2)" readonly class="form-control">
			</div>
			<div class="col-lg input-group">
				<span class="input-group-text">{{ $t('hmi.calib_robot.offset') }}</span>
				<input :value="(calibPos - drive.encoder).toFixed(2)" readonly class="form-control">
			</div>
			<div class="col-lg input-group">
				<span class="input-group-text">{{ $t('hmi.calib_robot.savedOffset') }}</span>
				<input :value="drive.offset.toFixed(2)" readonly class="form-control">
			</div>
			<div class="col-lg-auto">
				<button @click="save($event, drive.name)" class="btn btn-primary">{{ $t('save') }}</button>
			</div>
		</div>
	</div>
	`
})
