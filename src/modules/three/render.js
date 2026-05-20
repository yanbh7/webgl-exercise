import { WebGLRenderer } from "three";
export class Render {
  constructor(world) {
    this.world = world;
    this.renderer = new WebGLRenderer({
      canvas: world.size.dom,
      antialias: true,
    });
    this.updatePixelRate();
  }

  updatePixelRate() {
    const { size } = this.world;
    if (!this.renderer || !size) {
      return;
    }

    this.renderer.setSize(size.width, size.height);
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
  }

  update() {
    if (!this.renderer || !this.world?.camera || !this.world?.scene) {
      return;
    }

    const { camera } = this.world.camera;
    const { scene } = this.world.scene;
    this.renderer.render(scene, camera);
  }
  updateToneMapping(mappingType) {
    this.renderer.toneMapping = mappingType;
  }
  dispose() {
    this.renderer?.dispose();
    this.renderer = null;
    this.world = null;
  }
}
