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


import {
	Bone,
	Mesh,
	MeshPhongMaterial,
} from '/static/three/three.module.js';
import { STLLoader } from '/static/three/STLLoader.js';



//material: Material or Material properties
//bones: Bone or [Bone]
export default function loadStl(file, material, bones = new Bone())
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
