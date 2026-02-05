<template>
  <div ref="wrapRef" class="particles-cursor-animation p-r w-h-100">
    <canvas class="w-h-100 particles-cursor-animation-canvas"></canvas>
    <canvas class="track" ref="canvasRef"></canvas>
  </div>
</template>

<script setup>
import { onBeforeUnmount, onMounted, ref } from 'vue'
import GUI from 'lil-gui'
import * as THREE from 'three'
import { World } from '@/modules/three'
import fragmentShader from './shader/fragment.glsl'
import vertexShader from './shader/vertex.glsl'

const CANVAS_WIDTH = 128
const CANVAS_HEIGHT = 128
let textureIndex = 0
const debuggerObj = {
  changeTexture: () => {},
}

// Loaders
const textureLoader = new THREE.TextureLoader()
const textures = [
  textureLoader.load('./textures/particle-animation/picture-1.png'),
  textureLoader.load('./textures/particle-animation/picture-2.png'),
  textureLoader.load('./textures/particle-animation/picture-3.png'),
  textureLoader.load('./textures/particle-animation/picture-4.png'),
]
let world = null
const canvasRef = ref(null)
const wrapRef = ref(null)

// raycaster
const raycaster = new THREE.Raycaster()

// Coordinates
const screenCursor = new THREE.Vector2(9999, 9999)
const canvasCursor = new THREE.Vector2(9999, 9999)
const canvasCursorPre = new THREE.Vector2(9999, 9999)

const ponitMoveFunc = (e) => {
  screenCursor.x = (e.offsetX / world.size.width) * 2 - 1
  screenCursor.y = -(e.offsetY / world.size.height) * 2 + 1
}

onMounted(() => {
  const gui = new GUI({ container: wrapRef.value })
  /**
   * 2d canvas
   */
  canvasRef.value.width = CANVAS_WIDTH
  canvasRef.value.height = CANVAS_HEIGHT
  const ctx2d = canvasRef.value.getContext('2d')
  ctx2d.fillRect(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT)
  // Glow image
  const image = new Image()
  image.src = './textures/particle-animation/glow.png'

  // Interactive plane
  const interactivePlane = new THREE.Mesh(
    new THREE.PlaneGeometry(10, 10),
    new THREE.MeshBasicMaterial({ color: 'red', side: THREE.DoubleSide }),
  )
  interactivePlane.visible = false

  wrapRef.value.addEventListener('pointermove', ponitMoveFunc)

  /**
   * canvas texture
   */
  const canvasTexture = new THREE.CanvasTexture(canvasRef.value)

  /**
   * three
   */
  world = new World('.particles-cursor-animation-canvas', {})
  world.camera.updateCameraPosition({ x: 0, y: 0, z: 18 })
  world.camera.updateCameraFov(35)
  world.renderer.renderer.setClearColor('#181818')
  world.addMesh(interactivePlane)

  /**
   * Particles
   */
  const particlesGeometry = new THREE.PlaneGeometry(10, 10, 128, 128)
  particlesGeometry.setIndex(null)
  particlesGeometry.deleteAttribute('normal')

  const count = particlesGeometry.attributes.position.count
  const randomnessArray = new Float32Array(count)
  const anglesArray = new Float32Array(count)

  for (let i = 0; i < count; i++) {
    randomnessArray[i] = Math.random()
    anglesArray[i] = Math.random() * Math.PI * 2
  }
  particlesGeometry.setAttribute(
    'aRandomness',
    new THREE.Float32BufferAttribute(randomnessArray, 1),
  )
  particlesGeometry.setAttribute('aAngle', new THREE.Float32BufferAttribute(anglesArray, 1))

  const particlesMaterial = new THREE.ShaderMaterial({
    vertexShader,
    fragmentShader,
    uniforms: {
      uResolution: new THREE.Uniform(
        new THREE.Vector2(
          world.size.width * world.size.pixelRatio,
          world.size.height * world.size.pixelRatio,
        ),
      ),
      uPictureTexture: new THREE.Uniform(textures[0]),
      uDisplacementTexture: new THREE.Uniform(canvasTexture),
    },
    blending: THREE.AdditiveBlending,
  })
  const particles = new THREE.Points(particlesGeometry, particlesMaterial)
  world.addMesh(particles)
  debuggerObj.changeTexture = () => {
    particlesMaterial.uniforms.uPictureTexture.value = textures[++textureIndex % 4]
  }
  gui.add(debuggerObj, 'changeTexture')

  world.run(() => {
    /**
     * raycaster
     */
    raycaster.setFromCamera(screenCursor, world.camera.camera)
    const intersections = raycaster.intersectObject(interactivePlane)
    if (intersections.length) {
      const uv = intersections[0].uv
      canvasCursor.x = uv.x * CANVAS_WIDTH
      canvasCursor.y = (1 - uv.y) * CANVAS_HEIGHT
    }

    // cursor speed
    const distance = canvasCursorPre.distanceTo(canvasCursor)
    canvasCursorPre.copy(canvasCursor)
    const alpha = Math.min(distance * 0.1, 1)

    // displacement
    ctx2d.globalCompositeOperation = 'source-over'
    ctx2d.globalAlpha = 0.02
    ctx2d.fillRect(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT)

    ctx2d.globalCompositeOperation = 'lighten'
    const glowSize = CANVAS_WIDTH / 4
    ctx2d.globalAlpha = alpha

    ctx2d.drawImage(
      image,
      canvasCursor.x - glowSize / 2,
      canvasCursor.y - glowSize / 2,
      glowSize,
      glowSize,
    )

    // Texture
    canvasTexture.needsUpdate = true
  })
})
onBeforeUnmount(() => {
  world.dispose()
  wrapRef.value.removeEventListener('pointermove', ponitMoveFunc)
})
</script>

<style scoped lang="less">
.track {
  position: absolute;
  width: 128px;
  height: 128px;
  z-index: 10;
  top: 0;
  left: 0;
}
</style>
