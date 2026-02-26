<template>
  <div ref="wrapRef" class="gpgpu-flow-field p-r w-h-100">
    <canvas class="w-h-100 gpgpu-flow-field-canvas"></canvas>
  </div>
</template>

<script setup>
import { onBeforeMount, onBeforeUnmount, onMounted, ref } from 'vue'
import GUI from 'lil-gui'
import * as THREE from 'three'
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader'
import { DRACOLoader } from 'three/examples/jsm/loaders/DRACOLoader'
import { GPUComputationRenderer } from 'three/examples/jsm/misc/GPUComputationRenderer'
import { World } from '@/modules/three'
import fragmentShader from './shader/fragment.glsl'
import vertexShader from './shader/vertex.glsl'
import particlesShader from './shader/particles.glsl'

// Loaders
const dracoLoader = new DRACOLoader()
dracoLoader.setDecoderPath('./draco/')
const gltfLoader = new GLTFLoader()
gltfLoader.setDRACOLoader(dracoLoader)

const loadModel = async () => {
  const gltf = await gltfLoader.loadAsync('./model/gpgpu-flow-field/model.glb')
  return gltf
}

let world = null
let gui = null
const wrapRef = ref(null)
const particles = {}
const debugObject = {
  clearColor: '#29191f',
}

let previousTime = 0

// Base Geometry
const baseGeometry = {}
baseGeometry.instance = null
baseGeometry.count = 0
/**
 * GPGPU
 */
const gpgpu = {}
const loadedUpdate = (gltf) => {
  baseGeometry.instance = gltf.scene.children[0].geometry
  baseGeometry.count = baseGeometry.instance.attributes.position.count
  gpgpu.size = Math.ceil(Math.sqrt(baseGeometry.count))

  // Geometry
  particles.geometry = new THREE.BufferGeometry()
  particles.geometry.setDrawRange(0, baseGeometry.count)
  const particlesUvArray = new Float32Array(baseGeometry.count * 2)
  const sizesArray = new Float32Array(baseGeometry.count)

  for (let y = 0; y < gpgpu.size; y++) {
    for (let x = 0; x < gpgpu.size; x++) {
      const index = y * gpgpu.size + x
      // Particles UVs
      particlesUvArray[index * 2 + 0] = (x + 0.5) / gpgpu.size
      particlesUvArray[index * 2 + 1] = (y + 0.5) / gpgpu.size
      // Sizes
      sizesArray[index] = Math.random()
    }
  }

  particles.geometry.setAttribute('aParticlesUv', new THREE.BufferAttribute(particlesUvArray, 2))
  particles.geometry.setAttribute('aSize', new THREE.BufferAttribute(sizesArray, 1))
  particles.geometry.setAttribute('aColor', baseGeometry.instance.attributes.color)
  // Material
  particles.material = new THREE.ShaderMaterial({
    vertexShader,
    fragmentShader,
    uniforms: {
      uSize: new THREE.Uniform(0.07),
      uResolution: new THREE.Uniform(new THREE.Vector2(1920, 980)),
      uParticles: new THREE.Uniform(null),
    },
  })

  // Points
  particles.points = new THREE.Points(particles.geometry, particles.material)
}

onBeforeMount(async () => {})

onMounted(async () => {
  gui = new GUI({ container: wrapRef.value })
  const gltf = await loadModel()
  loadedUpdate(gltf)
  world = new World('.gpgpu-flow-field-canvas', {})
  world.camera.updateCameraPosition({ x: 6, y: 6, z: 18 })
  world.camera.updateCameraFov(35)
  world.renderer.renderer.setClearColor('#29191f')

  gpgpu.computation = new GPUComputationRenderer(gpgpu.size, gpgpu.size, world.renderer.renderer)
  world.addMesh(particles.points)
  // base particles
  const baseTexture = gpgpu.computation.createTexture()

  for (let i = 0; i < baseGeometry.count; i++) {
    const x = baseGeometry.instance.attributes.position.array[i * 3 + 0]
    const y = baseGeometry.instance.attributes.position.array[i * 3 + 1]
    const z = baseGeometry.instance.attributes.position.array[i * 3 + 2]

    baseTexture.image.data[i * 4 + 0] = x
    baseTexture.image.data[i * 4 + 1] = y
    baseTexture.image.data[i * 4 + 2] = z
    baseTexture.image.data[i * 4 + 3] = Math.random() // Alive (a = 0) or Dead (a = 1)
  }
  // Particles variable
  gpgpu.particlesVariable = gpgpu.computation.addVariable(
    'uParticles',
    particlesShader,
    baseTexture,
  )

  gpgpu.particlesVariable.material.uniforms.uTime = new THREE.Uniform(0)
  gpgpu.particlesVariable.material.uniforms.uDeltaTime = new THREE.Uniform(0)
  gpgpu.particlesVariable.material.uniforms.uBase = new THREE.Uniform(baseTexture)
  gpgpu.particlesVariable.material.uniforms.uFlowFieldInfluence = new THREE.Uniform(0.25)
  gpgpu.particlesVariable.material.uniforms.uFlowFieldStrength = new THREE.Uniform(2)
  gpgpu.particlesVariable.material.uniforms.uFlowFieldFrequency = new THREE.Uniform(0.5)
  gpgpu.computation.setVariableDependencies(gpgpu.particlesVariable, [gpgpu.particlesVariable])
  // Init
  gpgpu.computation.init()

  // Debug
  gpgpu.debug = new THREE.Mesh(
    new THREE.PlaneGeometry(3, 3),
    new THREE.MeshBasicMaterial({
      map: gpgpu.computation.getCurrentRenderTarget(gpgpu.particlesVariable).texture,
    }),
  )

  particles.material.uniforms.uParticles.value = gpgpu.computation.getCurrentRenderTarget(
    gpgpu.particlesVariable,
  ).texture

  gpgpu.debug.position.set(3, 0, 0)
  gpgpu.debug.visible = false
  world.addMesh(gpgpu.debug)

  particles.material.uniforms.uResolution.value.set(
    world.size.width * world.size.pixelRatio,
    world.size.height * world.size.pixelRatio,
  )

  world.size.setResizeCallback(() => {
    if (!particles.material) {
      return
    }
    particles.material.uniforms.uResolution.value.set(
      world.size.width * world.size.pixelRatio,
      world.size.height * world.size.pixelRatio,
    )
  })

  /**
   * Tweaks
   */
  gui.addColor(debugObject, 'clearColor').onChange(() => {
    world.renderer.renderer.setClearColor(debugObject.clearColor)
  })
  gui.add(particles.material.uniforms.uSize, 'value').min(0).max(1).step(0.001).name('uSize')
  gui
    .add(gpgpu.particlesVariable.material.uniforms.uFlowFieldInfluence, 'value')
    .min(0)
    .max(1)
    .name('uFlowFieldInfluence')
  gui
    .add(gpgpu.particlesVariable.material.uniforms.uFlowFieldStrength, 'value')
    .min(0)
    .max(10)
    .name('uFlowFieldStrength')
  gui
    .add(gpgpu.particlesVariable.material.uniforms.uFlowFieldFrequency, 'value')
    .min(0)
    .max(1)
    .step(0.001)
    .name('uFlowFieldFrequency')

  world.run((elapsedTime) => {
    const deltaTime = elapsedTime - previousTime
    previousTime = elapsedTime
    gpgpu.particlesVariable.material.uniforms.uTime.value = elapsedTime
    gpgpu.particlesVariable.material.uniforms.uDeltaTime.value = deltaTime

    // GPGPU update
    gpgpu.computation.compute()
    particles.material.uniforms.uParticles.value = gpgpu.computation.getCurrentRenderTarget(
      gpgpu.particlesVariable,
    ).texture
  })
})
onBeforeUnmount(() => {
  world.dispose()
})
</script>
