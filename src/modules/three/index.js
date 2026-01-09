
import { Clock, ShaderMaterial, PlaneGeometry, Mesh } from 'three'
import { Camera } from './camera'
import { Render } from './render'
import { Tscene as Scene } from './scene'
import { Size } from './size'

export class World {
  static instance = null
  constructor(container, options = {}) {
    this.container = container
    this.options = options
    this.handleOptions()

    this.size = new Size(this)
    this.scene = new Scene(this)
    this.camera = new Camera(this)
    this.renderer = new Render(this)

    this.time = new Clock()
  }

  static use(...args) {
    if (!World.instance) {
      return new World(args)
    }
    return World.instance
  }
  run(callback) {
    const tick = () => {
      // Update controls
      const elTime = this.time.getElapsedTime()

      callback?.(elTime, this)

      this.camera.update()

      // Render
      this.renderer.update()

      // Call tick again on the next frame
      window.requestAnimationFrame(tick)
    }
    tick()
  }

  addMesh(mesh) {
    this.scene.scene.add(mesh)
  }

  updateCameraPositon(position) {
    this.camera.updateCameraPosition(position)
  }

  handleOptions() {
    this.options
  }
  dispose() {
    this.size.dispose()
    this.scene.dispose()
    this.camera.dispose()
    this.renderer.dispose()
  }
}
