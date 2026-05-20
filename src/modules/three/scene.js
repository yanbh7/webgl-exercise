import { Scene } from "three";

const disposeMaterial = (material) => {
  Object.values(material).forEach((value) => {
    if (value?.isTexture) {
      value.dispose();
    }
  });
  Object.values(material.uniforms ?? {}).forEach((uniform) => {
    if (uniform?.value?.isTexture) {
      uniform.value.dispose();
    }
  });
  material.dispose?.();
};

export class Tscene {
  constructor(world) {
    this.world = world;
    this.scene = new Scene();
  }
  dispose() {
    this.scene?.traverse((object) => {
      object.geometry?.dispose?.();

      if (Array.isArray(object.material)) {
        object.material.forEach(disposeMaterial);
      } else if (object.material) {
        disposeMaterial(object.material);
      }
    });

    this.scene?.clear();
    this.scene?.background?.dispose?.();
    this.scene?.environment?.dispose?.();
    this.scene = null;
    this.world = null;
  }
}
