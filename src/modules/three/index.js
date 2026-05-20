import { Clock } from "three";
import { Camera } from "./camera";
import { Render } from "./render";
import { Tscene as Scene } from "./scene";
import { Size } from "./size";

export class World {
  static instance = null;
  constructor(container, options = {}) {
    this.container = container;
    this.options = options;
    this.rafId = null;
    this.disposed = false;

    this.size = new Size(this);
    this.scene = new Scene(this);
    this.camera = new Camera(this);
    this.renderer = new Render(this);

    this.time = new Clock();
  }

  static use(...args) {
    if (!World.instance) {
      World.instance = new World(...args);
    }
    return World.instance;
  }
  run(callback) {
    const tick = () => {
      if (this.disposed) {
        return;
      }

      // Update controls
      const elTime = this.time.getElapsedTime();

      callback?.(elTime, this);

      this.camera?.update();

      // Render
      this.renderer?.update();

      // Call tick again on the next frame
      this.rafId = window.requestAnimationFrame(tick);
    };
    tick();
  }

  addMesh(...mesh) {
    this.scene?.scene?.add(...mesh);
  }

  removeMesh(...mesh) {
    this.scene?.scene?.remove(...mesh);
  }

  updateCameraPositon(position) {
    this.camera.updateCameraPosition(position);
  }

  dispose() {
    if (this.disposed) {
      return;
    }

    this.disposed = true;

    if (this.rafId !== null) {
      window.cancelAnimationFrame(this.rafId);
      this.rafId = null;
    }

    this.size?.dispose();
    this.camera?.dispose();
    this.scene?.dispose();
    this.renderer?.dispose();

    this.size = null;
    this.scene = null;
    this.camera = null;
    this.renderer = null;
    this.time = null;

    if (World.instance === this) {
      World.instance = null;
    }
  }
}
