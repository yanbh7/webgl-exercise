import { Vector2 } from 'three'

export class Size {
  constructor(world) {
    this.world = world
    this.height = 100
    this.width = 100
    this.resolution = new Vector2(this.width, this.height)
    this.resizeEvent()
  }

  resizeEvent() {
    this.dom = document.querySelector(this.world.container)
    this.height = this.dom.offsetHeight
    this.width = this.dom.offsetWidth
    this.ob = new ResizeObserver((entries) => {
      const { width, height } = entries[0].contentRect
      this.height = height
      this.width = width
      this.resolution = new Vector2(this.width, this.height)

      this.world.renderer?.updatePixelRate?.()
      this.world.camera?.updateCamera?.()
    })
    this.ob.observe(this.dom.parentElement)
  }
  dispose() {
    this.ob.unobserve(this.dom.parentElement)
    this.ob = null
    this.dom = null
    this.world = null
  }
}
