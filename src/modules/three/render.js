import { WebGLRenderer } from 'three'
export class Render {
  constructor(world) {
    this.world = world
    this.renderer = new WebGLRenderer({
      canvas: world.size.dom
    })
    this.updatePixelRate()
  }

  updatePixelRate() {
    const { size } = this.world
    this.renderer.setSize(size.width, size.height)
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
  }

  update() {
    const { camera } = this.world.camera
    const { scene } = this.world.scene
    this.renderer.render(scene, camera)
  }
  dispose() {
    this.renderer = null
    this.world = null
  }
}
