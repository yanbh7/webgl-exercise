<template>
  <div class="animated-galaxy p-r w-h-100">
    <canvas class="w-h-100 animated-galaxy-canvas"></canvas>
  </div>
</template>

<script setup>
import { onMounted } from "vue";
import * as THREE from "three";
import GUI from "lil-gui";
import { World } from "@/modules/three";
import vertexShader from "./shader/vertexShader.glsl";
import fragmentShader from "./shader/fragmentShader.glsl";
/**
 * Galaxy
 */
const parameters = {};
parameters.count = 200000;
parameters.size = 0.005;
parameters.radius = 5;
parameters.branches = 3;
parameters.spin = 1;
parameters.randomness = 0.5;
parameters.randomnessPower = 3;
parameters.insideColor = "#ff6030";
parameters.outsideColor = "#1b3984";

let geometry = null;
let material = null;
let points = null;

const generateGalaxy = (world) => {
  const { scene, renderer } = world;
  if (points !== null) {
    geometry.dispose();
    material.dispose();
    scene.scene.remove(points);
  }

  /**
   * Geometry
   */
  geometry = new THREE.BufferGeometry();

  const positions = new Float32Array(parameters.count * 3);
  const colors = new Float32Array(parameters.count * 3);
  const scales = new Float32Array(parameters.count);
  const randomness = new Float32Array(parameters.count * 3);

  const insideColor = new THREE.Color(parameters.insideColor);
  const outsideColor = new THREE.Color(parameters.outsideColor);

  for (let i = 0; i < parameters.count; i++) {
    const i3 = i * 3;

    // Position
    const radius = Math.random() * parameters.radius;

    const branchAngle = ((i % parameters.branches) / parameters.branches) * Math.PI * 2;

    const randomX =
      Math.pow(Math.random(), parameters.randomnessPower) *
      (Math.random() < 0.5 ? 1 : -1) *
      parameters.randomness *
      radius;
    const randomY =
      Math.pow(Math.random(), parameters.randomnessPower) *
      (Math.random() < 0.5 ? 1 : -1) *
      parameters.randomness *
      radius;
    const randomZ =
      Math.pow(Math.random(), parameters.randomnessPower) *
      (Math.random() < 0.5 ? 1 : -1) *
      parameters.randomness *
      radius;

    randomness[i3 + 0] = randomX;
    randomness[i3 + 1] = randomY;
    randomness[i3 + 2] = randomZ;

    positions[i3] = Math.cos(branchAngle) * radius;
    positions[i3 + 1] = 0;
    positions[i3 + 2] = Math.sin(branchAngle) * radius;

    // Color
    const mixedColor = insideColor.clone();
    mixedColor.lerp(outsideColor, radius / parameters.radius);

    colors[i3] = mixedColor.r;
    colors[i3 + 1] = mixedColor.g;
    colors[i3 + 2] = mixedColor.b;
    // Scale
    scales[i] = Math.random();
  }

  geometry.setAttribute("position", new THREE.BufferAttribute(positions, 3));
  geometry.setAttribute("color", new THREE.BufferAttribute(colors, 3));
  geometry.setAttribute("aScale", new THREE.BufferAttribute(scales, 1));
  geometry.setAttribute("aRandomness", new THREE.BufferAttribute(randomness, 3));
  /**
   * Material
   */
  material = new THREE.ShaderMaterial({
    depthWrite: false,
    blending: THREE.AdditiveBlending,
    vertexColors: true,
    vertexShader,
    fragmentShader,
    uniforms: {
      uSize: { value: 30 * renderer.renderer.getPixelRatio() },
      uTime: { value: 0 },
    },
  });

  /**
   * Points
   */
  points = new THREE.Points(geometry, material);

  scene.scene.add(points);
};

onMounted(() => {
  // Debug
  const gui = new GUI({ container: document.querySelector(".animated-galaxy") });

  const world = new World(".animated-galaxy-canvas");

  const generateGalaxy2 = () => generateGalaxy(world);
  generateGalaxy2();
  world.run((time) => {
    material.uniforms.uTime.value = time;
  });

  gui.add(parameters, "count").min(100).max(1000000).step(100).onFinishChange(generateGalaxy2);
  gui.add(parameters, "radius").min(0.01).max(20).step(0.01).onFinishChange(generateGalaxy2);
  gui.add(parameters, "branches").min(2).max(20).step(1).onFinishChange(generateGalaxy2);
  gui.add(parameters, "randomness").min(0).max(2).step(0.001).onFinishChange(generateGalaxy2);
  gui.add(parameters, "randomnessPower").min(1).max(10).step(0.001).onFinishChange(generateGalaxy2);
  gui.addColor(parameters, "insideColor").onFinishChange(generateGalaxy2);
  gui.addColor(parameters, "outsideColor").onFinishChange(generateGalaxy2);
});
</script>

<style lang="less" scoped></style>
