<template>
  <div class="hologram-shader p-r w-h-100">
    <canvas class="w-h-100 hologram-shader-canvas"></canvas>
  </div>
</template>

<script setup>
import { onBeforeUnmount, onMounted, ref, watch } from "vue";
import GUI from "lil-gui";
import * as THREE from "three";
import { GLTFLoader } from "three/examples/jsm/loaders/GLTFLoader.js";

import { World } from "@/modules/three";
import fragmentShader from "./shader/fragmentShader.glsl";
import vertexShader from "./shader/vertexShader.glsl";

// Loaders
const gltfLoader = new GLTFLoader();
/**
 * Renderer
 */
const rendererParameters = {};
rendererParameters.clearColor = "#1d1f2a";
/**
 * Material
 */

const colorParameter = {
  color: "#70c1ff",
};
const material = new THREE.ShaderMaterial({
  vertexShader,
  fragmentShader,
  transparent: true,
  depthWrite: false,
  uniforms: {
    uTime: new THREE.Uniform(0),
    uColor: new THREE.Uniform(new THREE.Color(colorParameter.color)),
  },
  side: THREE.DoubleSide,
  blending: THREE.AdditiveBlending,
});

/**
 * Objects
 */
// Torus knot
const torusKnot = new THREE.Mesh(new THREE.TorusKnotGeometry(0.6, 0.25, 128, 32), material);
torusKnot.position.x = 3;

// Sphere
const sphere = new THREE.Mesh(new THREE.SphereGeometry(), material);
sphere.position.x = -3;

const isLoaded = ref(false);
// Suzanne
let suzanne = null;
gltfLoader.load("./model/hologram-shader/suzanne.glb", (gltf) => {
  suzanne = gltf.scene;
  suzanne.traverse((child) => {
    if (child.isMesh) child.material = material;
  });
  isLoaded.value = true;
});
let world = null;
watch(isLoaded, (val) => {
  if (val) {
    world.addMesh(suzanne);
  }
});

onMounted(() => {
  // Debug
  const gui = new GUI({ container: document.querySelector(".hologram-shader") });
  gui.addColor(colorParameter, "color").onChange(() => {
    material.uniforms.uColor.value.set(colorParameter.color);
  });

  world = new World(".hologram-shader-canvas", {});
  world.renderer.renderer.setClearColor(rendererParameters.clearColor);

  gui.addColor(rendererParameters, "clearColor").onChange(() => {
    world.renderer.renderer.setClearColor(rendererParameters.clearColor);
  });

  world.camera.updateCameraPosition({ x: 7, y: 7, z: 7 });
  world.camera.updateCameraFov(25);
  world.addMesh(torusKnot, sphere);

  world.run((elTime) => {
    material.uniforms.uTime.value = elTime;
    // Rotate objects
    if (suzanne) {
      suzanne.rotation.x = -elTime * 0.1;
      suzanne.rotation.y = elTime * 0.2;
    }

    sphere.rotation.x = -elTime * 0.1;
    sphere.rotation.y = elTime * 0.2;

    torusKnot.rotation.x = -elTime * 0.1;
    torusKnot.rotation.y = elTime * 0.2;
  });

  // window.Tworld = world
});

onBeforeUnmount(() => {
  world.dispose();
});
</script>

<style lang="less" scoped></style>
