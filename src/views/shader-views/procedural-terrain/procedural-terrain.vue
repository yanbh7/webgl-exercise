<template>
  <div ref="wrapRef" class="procedural-terrain p-r w-h-100">
    <canvas class="w-h-100 procedural-terrain-canvas"></canvas>
  </div>
</template>

<script setup>
import { onBeforeUnmount, onMounted, ref } from 'vue'
import GUI from 'lil-gui'
import * as THREE from 'three'
import { HDRLoader } from 'three/examples/jsm/loaders/HDRLoader.js'
import { Brush, Evaluator, SUBTRACTION } from 'three-bvh-csg'
import CustomShaderMaterial from 'three-custom-shader-material/vanilla'

import { World } from '@/modules/three'
import fragmentShader from './shader/fragment.glsl'
import vertexShader from './shader/vertex.glsl'

// Loaders
const hdrLoader = new HDRLoader()

let world = null
let gui = null
const wrapRef = ref(null)

onMounted(() => {
  gui = new GUI({ container: wrapRef.value })

  world = new World('.procedural-terrain-canvas', {})
  world.camera.updateCameraPosition({ x: -10, y: 6, z: -2 })
  world.camera.updateCameraFov(35)

  /**
   * Environment map
   */
  hdrLoader.load('./textures/procedural-terrain/spruit_sunrise.hdr', (environmentMap) => {
    environmentMap.mapping = THREE.EquirectangularReflectionMapping

    world.scene.scene.background = environmentMap
    world.scene.scene.backgroundBlurriness = 0.5
    world.scene.scene.environment = environmentMap
  })

  /**
   * Terrain
   */
  // Geometry
  const terrainGeometry = new THREE.PlaneGeometry(10, 10, 500, 500)
  terrainGeometry.rotateX(-Math.PI / 2)
  terrainGeometry.deleteAttribute('uv')
  terrainGeometry.deleteAttribute('normal')
  // Material
  const debugObject = {}
  debugObject.colorWaterDeep = '#002b3d'
  debugObject.colorWaterSurface = '#66a8ff'
  debugObject.colorSand = '#ffe894'
  debugObject.colorGrass = '#85d534'
  debugObject.colorRock = '#bfbd8d'
  debugObject.colorSnow = '#ffffff'

  const uniforms = {
    uTime: new THREE.Uniform(0),
    uPositionFrequency: new THREE.Uniform(0.25),
    uStrength: new THREE.Uniform(2.0),
    uWarpStrength: new THREE.Uniform(5.0),
    uWarpFrequency: new THREE.Uniform(0.1),
    uColorWaterDeep: new THREE.Uniform(new THREE.Color(debugObject.colorWaterDeep)),
    uColorWaterSurface: new THREE.Uniform(new THREE.Color(debugObject.colorWaterSurface)),
    uColorSand: new THREE.Uniform(new THREE.Color(debugObject.colorSand)),
    uColorGrass: new THREE.Uniform(new THREE.Color(debugObject.colorGrass)),
    uColorRock: new THREE.Uniform(new THREE.Color(debugObject.colorRock)),
    uColorSnow: new THREE.Uniform(new THREE.Color(debugObject.colorSnow)),
  }

  gui.add(uniforms.uPositionFrequency, 'value', 0.01, 1, 0.001).name('position frequency')
  gui.add(uniforms.uStrength, 'value', 0, 10, 0.001).name('strength')
  gui.add(uniforms.uWarpStrength, 'value', 0, 10, 0.001).name('warp strength')
  gui.add(uniforms.uWarpFrequency, 'value', 0.01, 1, 0.001).name('warp frequency')
  gui
    .addColor(debugObject, 'colorWaterDeep')
    .name('color water deep')
    .onChange((value) => {
      uniforms.uColorWaterDeep.value.set(value)
    })
  gui
    .addColor(debugObject, 'colorWaterSurface')
    .name('color water surface')
    .onChange((value) => {
      uniforms.uColorWaterSurface.value.set(value)
    })
  gui
    .addColor(debugObject, 'colorSand')
    .name('color sand')
    .onChange((value) => {
      uniforms.uColorSand.value.set(value)
    })
  gui
    .addColor(debugObject, 'colorGrass')
    .name('color grass')
    .onChange((value) => {
      uniforms.uColorGrass.value.set(value)
    })
  gui
    .addColor(debugObject, 'colorRock')
    .name('color rock')
    .onChange((value) => {
      uniforms.uColorRock.value.set(value)
    })
  gui
    .addColor(debugObject, 'colorSnow')
    .name('color snow')
    .onChange((value) => {
      uniforms.uColorSnow.value.set(value)
    })

  const material = new CustomShaderMaterial({
    // CSM
    baseMaterial: THREE.MeshStandardMaterial,
    fragmentShader,
    vertexShader,
    uniforms,

    // MeshStandardMaterial props
    metalness: 0,
    roughness: 0.5,
    color: '#85d534',
  })

  const depthMaterial = new CustomShaderMaterial({
    // CSM
    baseMaterial: THREE.MeshDepthMaterial,
    vertexShader,
    uniforms,

    depthPacking: THREE.RGBADepthPacking,
  })

  // Mesh
  const terrain = new THREE.Mesh(terrainGeometry, material)
  terrain.customDepthMaterial = depthMaterial
  terrain.receiveShadow = true
  terrain.castShadow = true
  /**
   * Board
   */
  const boardFill = new Brush(new THREE.BoxGeometry(11, 2, 11))
  const boardHole = new Brush(new THREE.BoxGeometry(10, 2.1, 10))

  /**
   * Evaluate CSG
   */
  const evaluator = new Evaluator()
  const board = evaluator.evaluate(boardFill, boardHole, SUBTRACTION)
  board.geometry.clearGroups()
  board.material = new THREE.MeshStandardMaterial({
    color: '#ffffff',
    roughness: 0.3,
    metalness: 0,
  })

  board.castShadow = true
  board.receiveShadow = true

  /**
   * Water
   */
  const water = new THREE.Mesh(
    new THREE.PlaneGeometry(10, 10, 1, 1),
    new THREE.MeshPhysicalMaterial({
      transmission: 1,
      roughness: 0.3,
    }),
  )
  water.rotation.x = -Math.PI * 0.5
  water.position.y = -0.1
  /**
   * Lights
   */
  const directionalLight = new THREE.DirectionalLight('#ffffff', 2)
  directionalLight.position.set(6.25, 3, 4)
  directionalLight.castShadow = true
  directionalLight.shadow.mapSize.set(1024, 1024)
  directionalLight.shadow.camera.near = 0.1
  directionalLight.shadow.camera.far = 30
  directionalLight.shadow.camera.top = 8
  directionalLight.shadow.camera.right = 8
  directionalLight.shadow.camera.bottom = -8
  directionalLight.shadow.camera.left = -8

  world.addMesh(directionalLight, board, terrain, water)

  world.renderer.renderer.shadowMap.enabled = true
  world.renderer.renderer.shadowMap.type = THREE.PCFSoftShadowMap
  world.renderer.renderer.toneMapping = THREE.ACESFilmicToneMapping
  world.renderer.renderer.toneMappingExposure = 1

  world.size.setResizeCallback(() => {})

  world.run((elTime) => {
    uniforms.uTime.value = elTime
  })
})
onBeforeUnmount(() => {
  world.dispose()
})
</script>
