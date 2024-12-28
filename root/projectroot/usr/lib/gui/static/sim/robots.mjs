// Copyright (c) 2024 Artur Wiebe <artur@4wiebe.de>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
// associated documentation files (the "Software"), to deal in the Software without restriction,
// including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


import {
	Bone,
	Vector3,
	MathUtils,
} from '/static/three/three.module.js';



export class Robot extends Bone {
}



export class LinearDeltaRobot extends Robot {
	constructor(params) {
		super();

		this.plate = new Bone();
		this.add(this.plate);

		this.arms = [];
		this.rods = [];

		for (let theta of [0, 120, 240]) {

			let rail = new Bone();
			rail.rotateZ(MathUtils.degToRad(theta));
			rail.translateX(params.outerRadius);
			rail.rotateY(MathUtils.degToRad(180 - params.axisAngle));
			this.add(rail);

			let arm = new Bone();
			rail.add(arm);
			this.arms.push(arm);

			for (let side of [1, -1]) {

				let rodsOnPlate = new Bone();
				rodsOnPlate.rotateZ(MathUtils.degToRad(theta));
				rodsOnPlate.translateX(params.innerRadius);
				this.plate.add(rodsOnPlate);

				let rod = new Bone();
				rod.translateY(side * params.rodsDistance / 2);
				rod.connectPlate = function() {
					rod.lookAt(rodsOnPlate.localToWorld(new Vector3(0, rod.position.y, 0)));
					rod.rotation.z = 0;
				};
				arm.add(rod);
				this.rods.push(rod);
			}
		}
	}
	
	setPose(axes, pos) {
		this.arms[0].position.x = axes[0];
		this.arms[1].position.x = axes[1];
		this.arms[2].position.x = axes[2];
		this.plate.position.x = pos.x;
		this.plate.position.y = pos.y;
		this.plate.position.z = pos.z;
		for (let rod of this.rods)
			rod.connectPlate();
	}
}
