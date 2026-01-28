<template>
  <div class="halftone-shading p-r w-h-100">
    <canvas class="w-h-100 halftone-shading-canvas"></canvas>
  </div>
</template>

<script setup>
import { onBeforeUnmount, onMounted } from 'vue'
import GUI from 'lil-gui'
import * as THREE from 'three'
import { World } from '@/modules/three'
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader.js'
import fragmentShader from './shader/fragment.glsl'
import vertexShader from './shader/vertex.glsl'

// Loaders
const gltfLoader = new GLTFLoader()

/**
 * Renderer
 */
const rendererParameters = {}
rendererParameters.clearColor = '#26132f'

const colorParameter = {
  color: '#ff794d',
  shaderColor: '#8e19b8',
  lightColor: '#e5ffe0',
}

let world = null

onMounted(() => {
  // Debug
  const gui = new GUI({ container: document.querySelector('.halftone-shading') })
  gui.addColor(colorParameter, 'color').onChange(() => {
    material.uniforms.uColor.value.set(colorParameter.color)
  })
  gui.addColor(colorParameter, 'shaderColor').onChange(() => {
    material.uniforms.uShaderColor.value.set(colorParameter.shaderColor)
  })
  gui.addColor(colorParameter, 'lightColor').onChange(() => {
    material.uniforms.uLightColor.value.set(colorParameter.lightColor)
  })
  gui.addColor(rendererParameters, 'clearColor').onChange(() => {
    world.renderer.renderer.setClearColor(rendererParameters.clearColor)
  })

  world = new World('.halftone-shading-canvas', {})

  const material = new THREE.ShaderMaterial({
    vertexShader,
    fragmentShader,
    // transparent: true,
    // depthWrite: false,
    uniforms: {
      uTime: new THREE.Uniform(0),
      uColor: new THREE.Uniform(new THREE.Color(colorParameter.color)),
      uResolution: new THREE.Uniform(
        new THREE.Vector2(
          world.size.width * world.size.pixelRatio,
          world.size.height * world.size.pixelRatio,
        ),
      ),
      uShaderColor: new THREE.Uniform(new THREE.Color(colorParameter.shaderColor)),
      uShaderRepeat: new THREE.Uniform(100),
      uLightColor: new THREE.Uniform(new THREE.Color(colorParameter.lightColor)),
      uLightRepeat: new THREE.Uniform(120),
    },
    // side: THREE.DoubleSide,
    // blending: THREE.AdditiveBlending,
  })

  gui.add(material.uniforms.uShaderRepeat, 'value').min(10).max(200).step(1).name('shaderRepeat')
  gui.add(material.uniforms.uLightRepeat, 'value').min(10).max(200).step(1).name('lightRepeat')

  /**
   * Objects
   */
  // Torus knot
  const torusKnot = new THREE.Mesh(new THREE.TorusKnotGeometry(0.6, 0.25, 128, 32), material)
  torusKnot.position.x = 3

  // Sphere
  const sphere = new THREE.Mesh(new THREE.SphereGeometry(), material)
  sphere.position.x = -3

  // Suzanne
  let suzanne = null
  gltfLoader.load('./model/hologram-shader/suzanne.glb', (gltf) => {
    suzanne = gltf.scene
    suzanne.traverse((child) => {
      if (child.isMesh) child.material = material
    })
    world.addMesh(suzanne)
  })

  world.renderer.renderer.setClearColor(rendererParameters.clearColor)
  world.camera.updateCameraPosition({ x: 7, y: 7, z: 7 })
  world.camera.updateCameraFov(25)
  world.addMesh(torusKnot, sphere)
  world.run((elTime) => {
    material.uniforms.uTime.value = elTime
    // Rotate objects
    if (suzanne) {
      suzanne.rotation.x = -elTime * 0.1
      suzanne.rotation.y = elTime * 0.2
    }

    sphere.rotation.x = -elTime * 0.1
    sphere.rotation.y = elTime * 0.2

    torusKnot.rotation.x = -elTime * 0.1
    torusKnot.rotation.y = elTime * 0.2
  })
  window.world = world
})
onBeforeUnmount(() => {
  world.dispose()
})
</script>
