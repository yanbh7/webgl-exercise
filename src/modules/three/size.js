import { Vector2 } from "three";

export class Size {
  constructor(world) {
    this.world = world;
    this.height = 100;
    this.width = 100;
    this.resolution = new Vector2(this.width, this.height);
    this.pixelRatio = Math.min(window.devicePixelRatio, 2);
    this.onResize = null;
    this.resizeEvent();
  }

  resizeEvent() {
    this.dom = document.querySelector(this.world.container);
    if (!this.dom) {
      throw new Error(`Canvas container not found: ${this.world.container}`);
    }

    this.height = this.dom.offsetHeight;
    this.width = this.dom.offsetWidth;
    this.ob = new ResizeObserver((entries) => {
      if (!this.world) {
        return;
      }

      const { width, height } = entries[0].contentRect;
      this.height = height;
      this.width = width;
      this.resolution = new Vector2(this.width, this.height);
      this.pixelRatio = Math.min(window.devicePixelRatio, 2);
      this.onResize?.();
      this.world.renderer?.updatePixelRate?.();
      this.world.camera?.updateCamera?.();
    });
    this.ob.observe(this.dom.parentElement);
  }

  setResizeCallback(func) {
    this.onResize = func;
  }
  dispose() {
    if (this.ob && this.dom?.parentElement) {
      this.ob.unobserve(this.dom.parentElement);
      this.ob.disconnect();
    }

    this.ob = null;
    this.dom = null;
    this.onResize = null;
    this.world = null;
  }
}
