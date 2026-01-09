<template>
  <div class="raging-sea p-r w-h-100">
    <canvas class="w-h-100 raging-sea-canvas"></canvas>
  </div>
</template>

<script setup>
import { onBeforeUnmount, onMounted } from 'vue'
import GUI from 'lil-gui'
import { ShaderMaterial, PlaneGeometry, Mesh, Vector2, Color } from 'three'
import { World } from '@/modules/three'
import fragmentShader from './shader/fragment.glsl?raw'
import vertexShader from './shader/vertex.glsl?raw'

const debugObj = {
  depthColor: '#186691',
  surfaceColor: '#9bd8ff',
}
const water = new Mesh(
  new PlaneGeometry(2, 2, 128, 128),
  new ShaderMaterial({
    vertexShader,
    fragmentShader,
    uniforms: {
      uTime: { value: 0 },
      uBigWavesElevation: { value: 0.2 },
      uBigWavesFrenquency: { value: new Vector2(4, 1.5) },
      uBigWavesSpeed: { value: 0.75 },

      uSmallWavesElevation: { value: 0.15 },
      uSmallWavesFrenquency: { value: 3 },
      uSmallWavesSpeed: { value: 0.2 },
      uSmallWavesIterations: { value: 4 },

      uDepthColor: { value: new Color(debugObj.depthColor) },
      uSurfaceColor: { value: new Color(debugObj.surfaceColor) },
      uColorOffset: { value: 0.08 },
      uColorMultiplier: { value: 5 },
    },
  }),
)
water.rotation.x = -Math.PI * 0.5
let world = null

onMounted(() => {
  // Debug
  const gui = new GUI({ container: document.querySelector('.raging-sea') })

  gui
    .add(water.material.uniforms.uBigWavesElevation, 'value')
    .min(0)
    .max(1)
    .step(0.001)
    .name('海拔')
  gui
    .add(water.material.uniforms.uBigWavesFrenquency.value, 'x')
    .min(0)
    .max(10)
    .step(0.001)
    .name('x轴频率')
  gui
    .add(water.material.uniforms.uBigWavesFrenquency.value, 'y')
    .min(0)
    .max(10)
    .step(0.001)
    .name('z轴频率')

  gui.add(water.material.uniforms.uBigWavesSpeed, 'value').min(0).max(4).step(0.001).name('Speed')
  gui.addColor(debugObj, 'depthColor').onChange((color) => {
    water.material.uniforms.uDepthColor.value.set(color)
  })
  gui.addColor(debugObj, 'surfaceColor').onChange((color) => {
    water.material.uniforms.uSurfaceColor.value.set(color)
  })

  gui
    .add(water.material.uniforms.uColorOffset, 'value')
    .min(0)
    .max(1)
    .step(0.001)
    .name('ColorOffset')
  gui
    .add(water.material.uniforms.uColorMultiplier, 'value')
    .min(0)
    .max(10)
    .step(0.001)
    .name('ColorMultip')
  gui
    .add(water.material.uniforms.uSmallWavesElevation, 'value')
    .min(0)
    .max(1)
    .step(0.001)
    .name('uSmallWavesElevation')
  gui
    .add(water.material.uniforms.uSmallWavesFrenquency, 'value')
    .min(0)
    .max(30)
    .step(0.001)
    .name('uSmallWavesFrenquency')
  gui
    .add(water.material.uniforms.uSmallWavesSpeed, 'value')
    .min(0)
    .max(4)
    .step(0.001)
    .name('uSmallWavesSpeed')
  gui
    .add(water.material.uniforms.uSmallWavesIterations, 'value')
    .min(1)
    .max(7)
    .step(1)
    .name('uSmallWavesIterations')

  world = new World('.raging-sea-canvas', {})
  world.addMesh(water)
  world.run((elTime) => {
    water.material.uniforms.uTime.value = elTime
  })
})

onBeforeUnmount(() => {
  world.dispose()
})
</script>

<style lang="less" scoped></style>
