<template>
  <div class="coffee-smoke p-r w-h-100">
    <canvas class="w-h-100 coffee-smoke-canvas"></canvas>
  </div>
</template>

<script setup>
import GUI from "lil-gui";
import * as THREE from "three";
import { GLTFLoader } from "three/examples/jsm/loaders/GLTFLoader.js";
import { onMounted } from "vue";
import { World } from "@/modules/three";
import vertexShader from "./shader/vertexShader.glsl";
import fragmentShader from "./shader/fragmentShader.glsl";

// Loaders
const textureLoader = new THREE.TextureLoader();
const gltfLoader = new GLTFLoader();

// Textures
const perlinTexture = textureLoader.load("./model/coffee-smoke/perlin.png");
perlinTexture.wrapS = THREE.RepeatWrapping;
perlinTexture.wrapT = THREE.RepeatWrapping;
/**
 * Smoke
 */
// Geometry
const smokeGeometry = new THREE.PlaneGeometry(1, 1, 16, 64);
smokeGeometry.translate(0, 0.5, 0);
smokeGeometry.scale(1.5, 6, 1.5);
// Material
const smokeMaterial = new THREE.ShaderMaterial({
  vertexShader,
  fragmentShader,
  side: THREE.DoubleSide,
  transparent: true,
  depthWrite: false,
  uniforms: {
    uPerlinTexture: new THREE.Uniform(perlinTexture),
    uTime: new THREE.Uniform(0),
  },
});

// Mesh
const smoke = new THREE.Mesh(smokeGeometry, smokeMaterial);

onMounted(() => {
  // Debug
  const gui = new GUI({ container: document.querySelector(".coffee-smoke") });

  const world = new World(".coffee-smoke-canvas");
  world.camera.updateCameraFov(25);
  world.camera.updateCameraPosition({ x: 8, y: 10, z: 12 });
  /**
   * Model
   */
  gltfLoader.load("./model/coffee-smoke/bakedModel.glb", (gltf) => {
    gltf.scene.getObjectByName("baked").material.map.anisotropy = 8;
    world.addMesh(gltf.scene);
  });

  world.addMesh(smoke);
  world.run((time) => {
    // Update Smoke
    smoke.material.uniforms.uTime.value = time;
  });
});
</script>

<style lang="less" scoped></style>
