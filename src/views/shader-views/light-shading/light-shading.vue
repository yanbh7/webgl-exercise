<template>
  <div class="light-shading p-r w-h-100">
    <canvas class="w-h-100 light-shading-canvas"></canvas>
  </div>
</template>

<script setup>
import { onBeforeUnmount, onMounted } from "vue";
import GUI from "lil-gui";
import * as THREE from "three";
import { GLTFLoader } from "three/examples/jsm/loaders/GLTFLoader";
import { World } from "@/modules/three";
import fragmentShader from "./shader/fragment.glsl";
import vertexShader from "./shader/vertex.glsl";

let world = null;
let gui = null;
let isDisposed = false;

// Loaders
const gltfLoader = new GLTFLoader();

/**
 * Material
 */
const materialParameters = {};
materialParameters.color = "#ffffff";

const material = new THREE.ShaderMaterial({
  vertexShader,
  fragmentShader,
  uniforms: {
    uColor: new THREE.Uniform(new THREE.Color(materialParameters.color)),
  },
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

// Suzanne
let suzanne = null;
gltfLoader.load("./model/hologram-shader/suzanne.glb", (gltf) => {
  if (isDisposed) {
    gltf.scene.traverse((child) => {
      child.geometry?.dispose?.();
      child.material?.dispose?.();
    });
    return;
  }

  suzanne = gltf.scene;
  suzanne.traverse((child) => {
    if (child.isMesh) child.material = material;
  });
  world?.addMesh(suzanne);
});

onMounted(() => {
  // Debug
  gui = new GUI({ container: document.querySelector(".light-shading") });
  gui.addColor(materialParameters, "color").onChange(() => {
    material.uniforms.uColor.value.set(materialParameters.color);
  });

  world = new World(".light-shading-canvas", {});
  world.camera.updateCameraPosition({ x: 7, y: 7, z: 7 });
  world.camera.updateCameraFov(25);
  world.addMesh(torusKnot, sphere);
  if (suzanne) {
    world.addMesh(suzanne);
  }

  world.run((elTime) => {
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
});

onBeforeUnmount(() => {
  isDisposed = true;
  gui?.destroy();
  world?.dispose();
});
</script>
