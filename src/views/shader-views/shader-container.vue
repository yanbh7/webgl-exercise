<template>
  <div class="shader-container">
    <component v-if="componentName && compMap[componentName]" :is="compMap[componentName]"></component>
  </div>
</template>

<script setup>
import { markRaw, ref, watch } from "vue";
import { useRoute, useRouter } from "vue-router";

const camelCase = (str = "") => {
  return String(str)
    .toLowerCase()
    .replace(/[-_\s]+([a-z0-9])/g, (_, ch) => ch.toUpperCase());
};

const importModules = () => {
  const modules = {};
  const files = import.meta.glob("./*/index.js");

  for (const filePath in files) {
    const moduleName = filePath.replace(/(\.\/|\/index\.js)/g, "");
    const key = camelCase(moduleName);
    modules[moduleName] = files[filePath];
    modules[key] = modules[moduleName];
  }

  return modules;
};

const modules = importModules();
const compMap = ref({});
const route = useRoute();
const router = useRouter();
const componentName = ref("");

const loadComponent = async ({ module, compName }) => {
  if (typeof module !== "string" || typeof compName !== "string") {
    router.replace({ name: "home" });
    return;
  }

  componentName.value = compName;

  if (compMap.value[compName]) {
    return;
  }

  const loader = modules[module] ?? modules[camelCase(module)];
  if (!loader) {
    router.replace({ name: "home" });
    return;
  }

  const comp = await loader();
  if (!comp?.default) {
    router.replace({ name: "home" });
    return;
  }

  compMap.value[compName] = markRaw(comp.default);
};

watch(() => route.query, loadComponent, { immediate: true });
</script>

<style lang="less" scoped>
.shader-container {
  display: flex;
  flex: 1;
  padding-bottom: 10px;
}
</style>
