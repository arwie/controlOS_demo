// SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
// SPDX-License-Identifier: MIT

import {
	Scene as THREE_Scene,
	WebGLRenderer,
	HemisphereLight,
	PointLight,
	PerspectiveCamera,
	OrthographicCamera,
	Bone,
	Mesh,
	MeshPhongMaterial,
} from 'three';
import { OrbitControls } from 'three/controls/OrbitControls';
import { STLLoader } from 'three/loaders/STLLoader';



export class Scene extends THREE_Scene {
	constructor() {
		super();
		
		this.renderer = new WebGLRenderer({antialias:true});
		this.renderer.domElement.style.width  = '100%';
		this.renderer.domElement.style.height = '100%';
		this.renderer.setClearColor(0xffffff);
		
		let hemiLight = new HemisphereLight(0xffffff, 0x444444, 3);
		hemiLight.position.set(0, 0, 1);
		this.add(hemiLight);
		
		this.cameraLight = new PointLight(0xffffff, 20, 0, 0.2);
		this.setCamera();
		
		new ResizeObserver(()=>{
			this.renderer.setSize(this.element.clientWidth, this.element.clientHeight, false);
			this.camera.elementResize();
			this.render();
		}).observe(this.element);
	}
	
	get element() {
		return this.renderer.domElement;
	}
	
	setCamera(perspective=true) {
		if (this.camera) 
			this.camera.controls.enabled = false;
		
		const setupCameraDefaults = (camera, zoom, elementResize)=>{
			camera.position.set(0, 0, camera.far / 10);
			camera.zoom = zoom
			camera.up.set(0, 0, 1);
			camera.elementResize = ()=>{
				elementResize(camera, this.element.clientWidth, this.element.clientHeight);
				camera.updateProjectionMatrix();
			}
			camera.elementResize();
			camera.controls = new OrbitControls(camera, this.element);
			camera.controls.rotateSpeed = 0.5;
			camera.controls.addEventListener('change', this.render.bind(this));
			return camera;
		}
		
		if (perspective) {
			this.camera = (this.perspectiveCamera ??= setupCameraDefaults(new PerspectiveCamera(33, 0, 0.1, 100000), 1, (camera, w,h)=>{
				camera.aspect = w / h;
			}));
		} else {
			this.camera = (this.orthographicCamera ??= setupCameraDefaults(new OrthographicCamera(0, 0, 0, 0, 0, 100000), 0.15, (camera, w,h)=>{
				camera.left		= w / -2;
				camera.right	= w /  2;
				camera.top		= h /  2;
				camera.bottom	= h / -2;
			}));
		}
		
		this.camera.add(this.cameraLight);
		this.camera.controls.enabled = true;
		this.add(this.camera);
		this.camera.elementResize();
		this.render();
	}
	
	render() {
		this.renderer.render(this, this.camera);
	}
}



//material: Material or Material properties
//bones: Bone or [Bone]
export function loadStl(file, material, bones = new Bone())
{
	if (file)
		new STLLoader().load(file, (geometry) => {

			if (!material.isMaterial)
				material = new MeshPhongMaterial(material);

			if (geometry.hasColors) {
				material.vertexColors = true;
				material.opacity = geometry.alpha;
			}

			for (let bone of (Array.isArray(bones) ? bones : [bones]))
				bone.add(new Mesh(geometry, material));

		});

	return bones;
}
