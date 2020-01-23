// Copyright (c) 2019 Artur Wiebe <artur@4wiebe.de>
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


import * as THREE				from '/static/three/build/three.module.js';
import { OrbitControls }		from '/static/three/examples/jsm/ext/OrbitControls.js';




export default class Scene extends THREE.Scene {
	constructor() {
		super();
		
		this.renderer = new THREE.WebGLRenderer();
		this.renderer.domElement.style.width  = '100%';
		this.renderer.domElement.style.height = '100%';
		this.renderer.setClearColor(0xffffff);
		
		this.camera = new THREE.PerspectiveCamera(50, 0, 0.1, 10000);
		this.camera.position.set(-2000, -2000, 2000);
		this.camera.up.set(0, 0, 1);
		this.add(this.camera);
		
		this.camera.add(new THREE.PointLight(0xffffff, 0.5));
		let hemiLight = new THREE.HemisphereLight(0xffffff, 0x444444);
		hemiLight.position.set(0, 0, 1);
		this.add(hemiLight);
		
		this.controls = new OrbitControls(this.camera, this.renderer.domElement);
		this.controls.rotateSpeed = 0.5;
		this.controls.addEventListener('change', this.render.bind(this));
		
		new ResizeObserver(()=>{
			const canvas = this.renderer.domElement;
			this.renderer.setSize(canvas.clientWidth, canvas.clientHeight, false);
			this.camera.aspect = canvas.clientWidth / canvas.clientHeight;
			this.camera.updateProjectionMatrix();
			this.render();
		}).observe(this.renderer.domElement);
	}
	
	setWorld(world) {
		this.remove(this.sceneWorld);
		this.sceneWorld = world;
		this.add(this.sceneWorld)
	}
	
	get element() {
		return this.renderer.domElement;
	}
	
	render() {
		this.renderer.render(this, this.camera);
	}
}
