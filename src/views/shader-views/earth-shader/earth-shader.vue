<template>
  <div class="earth-shader p-r w-h-100">
    <canvas class="w-h-100 earth-shader-canvas"></canvas>
  </div>
</template>

<script setup>
import { onBeforeUnmount, onMounted } from 'vue'
import GUI from 'lil-gui'
import * as THREE from 'three'
import { World } from '@/modules/three'
import fragmentShader from './shader/fragment.glsl'
import vertexShader from './shader/vertex.glsl'
import atmosVertexShader from './shader/atmosphereVertex.glsl'
import atmosFragmentShader from './shader/atmosphereFragment.glsl'

// Loaders
const textureLoader = new THREE.TextureLoader()

const earthDayTexture = textureLoader.load('./textures/earth/day.jpg')
earthDayTexture.colorSpace = THREE.SRGBColorSpace
earthDayTexture.anisotropy = 8
const earthNightTexture = textureLoader.load('./textures/earth/night.jpg')
earthNightTexture.colorSpace = THREE.SRGBColorSpace
earthNightTexture.anisotropy = 8
const earthSpecularTexture = textureLoader.load('./textures/earth/specularClouds.jpg')
earthSpecularTexture.anisotropy = 8

let world = null

/**
 * Earth
 */

const earthParameter = {
  atmosphereDayColor: '#00aaff',
  atmosphereTwilightColor: '#ff6600',
}
// Mesh
const earthGeometry = new THREE.SphereGeometry(2, 64, 64)
const earthMaterial = new THREE.ShaderMaterial({
  vertexShader,
  fragmentShader,
  uniforms: {
    uDayTexture: new THREE.Uniform(earthDayTexture),
    uNightTexture: new THREE.Uniform(earthNightTexture),
    uSpecularTexture: new THREE.Uniform(earthSpecularTexture),
    uSunDirection: new THREE.Uniform(new THREE.Vector3(0, 0, 1)),
    uAtmosphereDayColor: new THREE.Uniform(new THREE.Color(earthParameter.atmosphereDayColor)),
    uAtmosphereTwilightColor: new THREE.Uniform(
      new THREE.Color(earthParameter.atmosphereTwilightColor),
    ),
  },
})
const earth = new THREE.Mesh(earthGeometry, earthMaterial)
/**
 * Atmosphere
 */
const atmosphereMaterial = new THREE.ShaderMaterial({
  side: THREE.BackSide,
  transparent: true,
  vertexShader: atmosVertexShader,
  fragmentShader: atmosFragmentShader,
  uniforms: {
    uSunDirection: new THREE.Uniform(new THREE.Vector3(0, 0, 1)),
    uAtmosphereDayColor: new THREE.Uniform(new THREE.Color(earthParameter.atmosphereDayColor)),
    uAtmosphereTwilightColor: new THREE.Uniform(
      new THREE.Color(earthParameter.atmosphereTwilightColor),
    ),
  },
})

const atmosphereMesh = new THREE.Mesh(earthGeometry, atmosphereMaterial)
atmosphereMesh.scale.setScalar(1.04)

/**
 * Sun
 */

const sunSphercial = new THREE.Spherical(1, Math.PI * 0.5, 0.5)
const sunDirection = new THREE.Vector3()

// Debug
const debugSun = new THREE.Mesh(
  new THREE.IcosahedronGeometry(0.1, 2),
  new THREE.MeshBasicMaterial(),
)
// Update
const updateSun = () => {
  sunDirection.setFromSpherical(sunSphercial)
  debugSun.position.copy(sunDirection).multiplyScalar(5)

  earthMaterial.uniforms.uSunDirection.value.copy(sunDirection)
  atmosphereMaterial.uniforms.uSunDirection.value.copy(sunDirection)
}

updateSun()

onMounted(() => {
  // Debug
  const gui = new GUI({ container: document.querySelector('.earth-shader'), width: 300 })
  gui.addColor(earthParameter, 'atmosphereDayColor').onChange(() => {
    earthMaterial.uniforms.uAtmosphereDayColor.value.set(earthParameter.atmosphereDayColor)
    atmosphereMaterial.uniforms.uAtmosphereDayColor.value.set(earthParameter.atmosphereDayColor)
  })
  gui.addColor(earthParameter, 'atmosphereTwilightColor').onChange(() => {
    earthMaterial.uniforms.uAtmosphereTwilightColor.value.set(
      earthParameter.atmosphereTwilightColor,
    )
    atmosphereMaterial.uniforms.uAtmosphereTwilightColor.value.set(
      earthParameter.atmosphereTwilightColor,
    )
  })
  gui.add(sunSphercial, 'phi').min(0).max(Math.PI).onChange(updateSun)
  gui.add(sunSphercial, 'theta').min(0).max(Math.PI).onChange(updateSun)
  world = new World('.earth-shader-canvas', {})

  world.camera.updateCameraPosition({ x: 12, y: 5, z: 4 })
  world.camera.updateCameraFov(25)
  world.renderer.renderer.setClearColor('#000011')
  world.addMesh(earth, debugSun, atmosphereMesh)
  world.run((elapsedTime) => {
    earth.rotation.y = elapsedTime * 0.1
  })

  // console.log('world.renderer.r:', world.renderer.renderer.capabilities.getMaxAnisotropy())
})
onBeforeUnmount(() => {
  world.dispose()
})
</script>
