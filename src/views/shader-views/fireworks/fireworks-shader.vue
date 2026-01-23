<template>
  <div class="fireworks-shader p-r w-h-100">
    <canvas class="w-h-100 fireworks-shader-canvas"></canvas>
  </div>
</template>

<script setup>
import { onBeforeUnmount, onMounted } from 'vue'
import GUI from 'lil-gui'
import * as THREE from 'three'
import gsap from 'gsap'
import { Sky } from 'three/examples/jsm/objects/Sky'
// import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader.js'

import { World } from '@/modules/three'
import fragmentShader from './shader/fragment.glsl?raw'
import vertexShader from './shader/vertex.glsl?raw'

let world = null

/**
 * texture loader
 */

const textureLoader = new THREE.TextureLoader()

const textures = [
  textureLoader.load('./particles/1.png'),
  textureLoader.load('./particles/2.png'),
  textureLoader.load('./particles/3.png'),
  textureLoader.load('./particles/4.png'),
  textureLoader.load('./particles/5.png'),
  textureLoader.load('./particles/6.png'),
  textureLoader.load('./particles/7.png'),
  textureLoader.load('./particles/8.png'),
]
textures.forEach((el) => {
  el.flipY = false
})

/**
 * Firework
 */

const createFirework = (count, position, size, textureIndex, radius, color) => {
  const positionArray = new Float32Array(count * 3)
  const sizeArray = new Float32Array(count)
  const timeMultip = new Float32Array(count)
  for (let i = 0; i < count; i++) {
    const i3 = i * 3

    const spherical = new THREE.Spherical(
      radius * (0.75 + Math.random() * 0.25),
      Math.random() * Math.PI,
      Math.random() * Math.PI * 2,
    )

    const position = new THREE.Vector3()
    position.setFromSpherical(spherical)
    positionArray[i3] = position.x
    positionArray[i3 + 1] = position.y
    positionArray[i3 + 2] = position.z

    sizeArray[i] = Math.random()

    timeMultip[i] = 1 + Math.random()
  }

  const material = new THREE.ShaderMaterial({
    vertexShader,
    fragmentShader,
    transparent: true,
    depthWrite: false,
    blending: THREE.AdditiveBlending,
    uniforms: {
      uSize: new THREE.Uniform(size),
      uResolution: new THREE.Uniform(world.size.resolution),
      uTexture: new THREE.Uniform(textures[textureIndex]),
      uColor: new THREE.Uniform(color),
      uProgress: new THREE.Uniform(0),
    },
  })
  const geometry = new THREE.BufferGeometry()
  geometry.setAttribute('position', new THREE.Float32BufferAttribute(positionArray, 3))
  geometry.setAttribute('aSize', new THREE.Float32BufferAttribute(sizeArray, 1))
  geometry.setAttribute('aTimeMultip', new THREE.Float32BufferAttribute(timeMultip, 1))

  const firework = new THREE.Points(geometry, material)
  firework.position.copy(position)

  const destroy = () => {
    material.dispose()
    geometry.dispose()
    world?.removeMesh?.(firework)
  }

  // Aniamte
  gsap.to(material.uniforms.uProgress, {
    value: 1,
    duration: 3,
    ease: 'linear',
    onComplete: destroy,
  })
  return firework
}

onMounted(() => {
  // Debug
  const gui = new GUI({ container: document.querySelector('.fireworks-shader') })

  world = new World('.fireworks-shader-canvas', {})

  world.camera.updateCameraPosition({ x: 1.5, y: 0, z: 6 })
  world.camera.updateCameraFov(25)

  // Sky
  // Add Sky
  const sky = new Sky()
  sky.scale.setScalar(450000)
  world.addMesh(sky)

  const sun = new THREE.Vector3()
  const { renderer } = world.renderer

  const effectController = {
    turbidity: 10,
    rayleigh: 3,
    mieCoefficient: 0.005,
    mieDirectionalG: 0.95,
    elevation: -2.2,
    azimuth: 180,
    exposure: renderer.toneMappingExposure,
  }

  function guiChanged() {
    const uniforms = sky.material.uniforms
    uniforms['turbidity'].value = effectController.turbidity
    uniforms['rayleigh'].value = effectController.rayleigh
    uniforms['mieCoefficient'].value = effectController.mieCoefficient
    uniforms['mieDirectionalG'].value = effectController.mieDirectionalG

    const phi = THREE.MathUtils.degToRad(90 - effectController.elevation)
    const theta = THREE.MathUtils.degToRad(effectController.azimuth)

    sun.setFromSphericalCoords(1, phi, theta)

    uniforms['sunPosition'].value.copy(sun)

    renderer.toneMappingExposure = effectController.exposure
    world.renderer.update()
  }

  gui.add(effectController, 'turbidity', 0.0, 20.0, 0.1).onChange(guiChanged)
  gui.add(effectController, 'rayleigh', 0.0, 4, 0.001).onChange(guiChanged)
  gui.add(effectController, 'mieCoefficient', 0.0, 0.1, 0.001).onChange(guiChanged)
  gui.add(effectController, 'mieDirectionalG', 0.0, 1, 0.001).onChange(guiChanged)
  gui.add(effectController, 'elevation', -10, 90, 0.1).onChange(guiChanged)
  gui.add(effectController, 'azimuth', -180, 180, 0.1).onChange(guiChanged)
  gui.add(effectController, 'exposure', 0, 1, 0.0001).onChange(guiChanged)

  guiChanged()
  world.run(() => {})

  // window.Tworld = world
})

const createFireworkFn = () => {
  const count = Math.round(400 + Math.random() * 1000)
  const position = new THREE.Vector3(
    (Math.random() - 0.5) * 2,
    Math.random(),
    (Math.random() - 0.5) * 2,
  )

  const size = 0.3 + Math.random() * 0.1
  const textureIndex = Math.floor(Math.random() * textures.length)
  const radius = 0.5 + Math.random()
  const color = new THREE.Color()
  color.setHSL(Math.random(), 1, 0.7)
  world.addMesh(createFirework(count, position, size, textureIndex, radius, color))
}

window.addEventListener('click', createFireworkFn)

onBeforeUnmount(() => {
  world.dispose()
  window.removeEventListener('click', createFireworkFn)
})
</script>

<style lang="less" scoped></style>
