import { useTemplateRef, onMounted } from 'vue'
import { url } from 'web/utils'
import { studioIndex } from 'studio'

import {
	Bone,
	CylinderGeometry,
	MeshPhongMaterial,
	Mesh,
	MathUtils,
	AxesHelper,
} from 'three';
import { Scene, loadStl } from 'sim';
import { LinearDeltaRobot } from 'sim/robots';

import files from '/web.files';



class IgusDeltaRobot extends LinearDeltaRobot {
	constructor() {
		super({
			axisAngle:    45,
			outerRadius:  392.15,
			innerRadius:  42,
			rodsLength:   400,
			rodsDistance: 80,
		});

		loadStl(files['sim/robot/base.stl'],  {color:'DarkSlateGray'}, this);
		loadStl(files['sim/robot/plate.stl'], {color:'OrangeRed'}, this.plate);
		loadStl(files['sim/robot/arm.stl'],   {color:'OrangeRed'}, this.arms);
		loadStl(files['sim/robot/rod.stl'],   {color:'SlateGray'}, this.rods);

		this.tool = loadStl(files['sim/robot/tool.stl'], {color:'FireBrick'});
		this.tool.position.z = -50;
		this.plate.add(this.tool);

		this.add(new AxesHelper(200));
		this.plate.add(new AxesHelper(100));
	}
}


class Conv extends Bone {
	constructor() {
		super();

		this.position.set(+150, -100, -650);
		this.rotation.z = MathUtils.degToRad(90);

		loadStl(files['sim/conv.stl'], {color:'Black', transparent:true, opacity:0.7}, this);
		this.add(new AxesHelper(100));

		this.belt = new Bone();
		this.add(this.belt);
	}

	setPos(pos) {
		this.belt.position.x = pos;
	}

	placeItem(item, pos, belt_pos) {
		item.position.x = pos.x - belt_pos;
		item.position.y = pos.y;
		this.belt.add(item);
	}

	removeItem(item_name) {
		this.belt.getObjectByName(item_name)?.dispose();
	}
}


class Item extends Bone {
	constructor(name, radius=15, height=10) {
		super();
		this.name = name;
		this.geometry = new CylinderGeometry(radius, radius, height, 16);
		let cylinder = new Mesh(this.geometry, Item.material);
		cylinder.rotation.x = MathUtils.degToRad(90);
		cylinder.position.z = height / 2;
		this.add(cylinder);
	}

	static material = new MeshPhongMaterial({color:'Green'});

	dispose() {
		this.removeFromParent();
		this.geometry.dispose();
	}
}



studioIndex.addPage('sim', {
	targetGuard: 'app@sim',
	async setup() {

		const scene = new Scene();
		const robot = new IgusDeltaRobot();
		const conv = new Conv();

		scene.add(robot, conv);

		const ws = url('sim', 'app').webSocketJson((msg)=>{
			switch (msg.cmd) {
				case 0:
					robot.setPose(msg.robot.axes, msg.robot.pos);
					conv.setPos(msg.conv.pos);
					break;
				case 11:
					conv.placeItem(new Item(msg.id), msg.item.pos, msg.item.conv);
					break;
				case 12:
					conv.removeItem(msg.id);
					break;
			}
			scene.render();
		});

		const container = useTemplateRef('scene');
		onMounted(()=>{
			container.value.appendChild(scene.element);
		});

		function send(cmd, args={}) {
			args.cmd = cmd;
			ws.sendJson(args);
		}

		await ws.sync;
		return { send }
	},
	template: //html
	`
	<div class="row h-100">
		<div class="col-xl pb-3 mh-100">
			<div ref="scene" class="h-100"></div>
		</div>
		<div class="col-md-2">
			<div class="mb-3 d-grid gap-3">
				<button @click="send(1)" class="btn btn-success btn-lg w-100">
					<i class="fas fa-play"></i>
				</button>
				<button @click="send(2)" class="btn btn-danger btn-lg w-100">
					<i class="fas fa-stop"></i>
				</button>
			</div>
		</div>
	</div>
	`
})
