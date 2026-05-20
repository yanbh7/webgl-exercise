<template>
  <div ref="wrapRef" class="particles-morph-animation p-r w-h-100">
    <canvas class="w-h-100 particles-morph-animation-canvas"></canvas>
  </div>
</template>

<script setup>
import { onBeforeUnmount, onMounted, ref } from "vue";
import GUI from "lil-gui";
import gsap from "gsap";
import * as THREE from "three";
import { GLTFLoader } from "three/examples/jsm/loaders/GLTFLoader";
import { DRACOLoader } from "three/examples/jsm/loaders/DRACOLoader";
import { World } from "@/modules/three";
import fragmentShader from "./shader/fragment.glsl";
import vertexShader from "./shader/vertex.glsl";

const particles = {
  index: 0,
  morph: () => {},
  colorA: "#ff7300",
  colorB: "#3355ff",
};
// Loaders
const dracoLoader = new DRACOLoader();
dracoLoader.setDecoderPath("./draco/");
const gltfLoader = new GLTFLoader();
gltfLoader.setDRACOLoader(dracoLoader);

let isDisposed = false;

const loadParticles = () => {
  gltfLoader.load("./model/particles-morph/models.glb", (gltf) => {
    if (isDisposed || !world) {
      gltf.scene.traverse((child) => {
        child.geometry?.dispose?.();
        child.material?.dispose?.();
      });
      return;
    }

  /**
   * Positions
   */
  const positions = gltf.scene.children.map((el) => el.geometry.attributes.position);
  particles.maxCount = Math.max(...positions.map((el) => el.count));
  particles.newPosition = [];
  positions.forEach((el) => {
    const originArray = el.array;
    let newArray = null;
    if (originArray.length === particles.maxCount * 3) {
      newArray = originArray;
      particles.newPosition.push(new THREE.Float32BufferAttribute(newArray, 3));
      return;
    }
    newArray = new Float32Array(particles.maxCount * 3);
    for (let i = 0; i < particles.maxCount; i++) {
      const i3 = i * 3;
      if (i3 < originArray.length) {
        newArray[i3 + 0] = originArray[i3 + 0];
        newArray[i3 + 1] = originArray[i3 + 1];
        newArray[i3 + 2] = originArray[i3 + 2];
      } else {
        const randomIndex = Math.floor(el.count * Math.random()) * 3;
        newArray[i3 + 0] = originArray[randomIndex + 0];
        newArray[i3 + 1] = originArray[randomIndex + 1];
        newArray[i3 + 2] = originArray[randomIndex + 2];
      }
    }
    particles.newPosition.push(new THREE.Float32BufferAttribute(newArray, 3));
  });

  /**
   * Particles
   */
  // Geometry

  const sizesArray = new Float32Array(particles.maxCount);
  for (let i = 0; i < particles.maxCount; i++) {
    sizesArray[i] = Math.random();
  }
  particles.geometry = new THREE.BufferGeometry();
  particles.geometry.setAttribute("position", particles.newPosition[particles.index]);
  particles.geometry.setAttribute("aPositionTarget", particles.newPosition[3]);
  particles.geometry.setAttribute("aSize", new THREE.Float32BufferAttribute(sizesArray, 1));
  // particles.geometry.setIndex(null)

  // Material
  particles.material = new THREE.ShaderMaterial({
    vertexShader,
    fragmentShader,
    transparent: true,
    blending: THREE.AdditiveBlending,
    depthWrite: false,
    uniforms: {
      uSize: new THREE.Uniform(0.4),
      uResolution: new THREE.Uniform(
        new THREE.Vector2(world.size.width * world.size.pixelRatio, world.size.height * world.size.pixelRatio),
      ),
      uProgress: new THREE.Uniform(0),
      uColorA: new THREE.Uniform(new THREE.Color(particles.colorA)),
      uColorB: new THREE.Uniform(new THREE.Color(particles.colorB)),
    },
  });

  // Points
  particles.points = new THREE.Points(particles.geometry, particles.material);
  particles.points.frustumCulled = false;
  // console.log(particles.points.geometry.boundingSphere)
  world.addMesh(particles.points);

  particles.morph = (index) => {
    // Update attributes
    particles.geometry.attributes.position = particles.newPosition[particles.index];
    particles.geometry.attributes.aPositionTarget = particles.newPosition[index];

    // Animate uProgress
    gsap.fromTo(particles.material.uniforms.uProgress, { value: 0 }, { value: 1, duration: 3, ease: "linear" });

    particles.index = index;
  };

  gui.addColor(particles, "colorA").onChange(() => {
    particles.material.uniforms.uColorA.value.set(particles.colorA);
  });
  gui.addColor(particles, "colorB").onChange(() => {
    particles.material.uniforms.uColorB.value.set(particles.colorB);
  });

  gui.add(particles.material.uniforms.uProgress, "value").min(0).max(1).step(0.001).name("Progress").listen();
  particles.morph0 = () => particles.morph(0);
  particles.morph1 = () => particles.morph(1);
  particles.morph2 = () => particles.morph(2);
  particles.morph3 = () => particles.morph(3);

  gui.add(particles, "morph0");
  gui.add(particles, "morph1");
  gui.add(particles, "morph2");
  gui.add(particles, "morph3");
  });
};

const debugObject = {};

let world = null;
let gui = null;
const wrapRef = ref(null);

onMounted(() => {
  gui = new GUI({ container: wrapRef.value });
  debugObject.clearColor = "#160920";

  world = new World(".particles-morph-animation-canvas", {});
  world.camera.updateCameraPosition({ x: 0, y: 0, z: 18 });
  world.camera.updateCameraFov(35);
  loadParticles();

  gui.addColor(debugObject, "clearColor").onChange(() => {
    world.renderer.renderer.setClearColor(debugObject.clearColor);
  });
  world.renderer.renderer.setClearColor(debugObject.clearColor);

  world.size.setResizeCallback(() => {
    if (!particles.material) {
      return;
    }
    particles.material.uniforms.uResolution.value.set(
      world.size.width * world.size.pixelRatio,
      world.size.height * world.size.pixelRatio,
    );
  });

  world.run(() => {});
});
onBeforeUnmount(() => {
  isDisposed = true;
  gsap.killTweensOf(particles.material?.uniforms.uProgress);
  gui?.destroy();
  world?.dispose();
  dracoLoader.dispose();
});
</script>
