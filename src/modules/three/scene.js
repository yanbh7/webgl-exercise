import { Scene } from 'three'

export class Tscene {
  constructor(world) {
    this.world = world
    this.scene = new Scene()
  }
  dispose() {
    this.scene = null
    this.world = null
  }
}
