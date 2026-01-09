import { PerspectiveCamera } from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls'
export class Camera {
  constructor(world) {
    this.world = world
    const { size } = world
    this.camera = new PerspectiveCamera(75, size.width / size.height, 0.1, 100)
    this.camera.position.set(1, 1, 1)
    this.world.addMesh(this.camera)
    this.useOrbit()
    this.updateCamera()
  }
  useOrbit() {
    this.control = new OrbitControls(this.camera, this.world.size.dom)
    this.control.enableDamping = true
  }
  updateCamera() {
    const { size } = this.world

    this.camera.aspect = size.width / size.height
    this.camera.updateProjectionMatrix()
  }
  updateCameraPosition(position) {
    const { x, y, z } = position
    const { x: ox, y: oy, z: oz } = this.camera.position
    this.camera.position.x = x ?? ox
    this.camera.position.y = y ?? oy
    this.camera.position.z = z ?? oz
  }

  updateCameraFov(fov) {
    this.camera.fov = fov;
  }
  update() {
    this.control.update()
  }
  dispose() {
    this.camera = null
    this.world = null
  }
}
