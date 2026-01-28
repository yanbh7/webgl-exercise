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

// Loaders
const textureLoader = new THREE.TextureLoader()

const earthDayTexture = textureLoader.load('./textures/earth/day.jpg')
earthDayTexture.colorSpace = THREE.SRGBColorSpace
const earthNightTexture = textureLoader.load('./textures/earth/night.jpg')
earthNightTexture.colorSpace = THREE.SRGBColorSpace
const earthSpecularTexture = textureLoader.load('./textures/earth/specularClouds.jpg')

let world = null

/**
 * Earth
 */
// Mesh
const earthGeometry = new THREE.SphereGeometry(2, 64, 64)
const earthMaterial = new THREE.ShaderMaterial({
  vertexShader,
  fragmentShader,
  uniforms: {
    uDayTexture: new THREE.Uniform(earthDayTexture),
    uNightTexture: new THREE.Uniform(earthNightTexture),
    uSpecularTexture: new THREE.Uniform(earthSpecularTexture),
  },
})
const earth = new THREE.Mesh(earthGeometry, earthMaterial)

onMounted(() => {
  // Debug
  const gui = new GUI({ container: document.querySelector('.earth-shader') })

  world = new World('.earth-shader-canvas', {})

  world.camera.updateCameraPosition({ x: 12, y: 5, z: 4 })
  world.camera.updateCameraFov(25)
  world.renderer.renderer.setClearColor('#000011')
  world.addMesh(earth)
  world.run((elapsedTime) => {
    earth.rotation.y = elapsedTime * 0.1
  })

  // 1. 定义一个球坐标：半径 5，极角 90度 (PI/2)，方位角 45度 (PI/4)
  const radius = 5
  const phi = Math.PI / 2 // 位于赤道平面
  const theta = Math.PI / 4 // 绕Y轴转45度
  const spherical = new THREE.Spherical(radius, phi, theta)

  // 2. 创建一个向量
  const vector = new THREE.Vector3()

  // 3. 将球坐标转换为 x, y, z
  vector.setFromSpherical(spherical)

  console.log(vector) // 输出转换后的 x, y, z 坐标
})
onBeforeUnmount(() => {
  world.dispose()
})
</script>
