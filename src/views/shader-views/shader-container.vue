<template>
  <div class="shader-container">
    <component :is="compMap[componentName]"></component>
  </div>
</template>

<script setup>
import { markRaw, onBeforeMount, ref } from 'vue'
import { useRoute } from 'vue-router'

// 将短横线、下划线或空格分隔的名称转换为 camelCase（例如: ring-sea -> ringSea）
const camelCase = (str = '') => {
  return String(str)
    .toLowerCase()
    .replace(/[-_\s]+([a-z0-9])/g, (_, ch) => ch.toUpperCase())
}

const importModules = () => {
  // 自动导出 shader-views 下所有子目录的 index.js 模块（必须使用字面量模式）
  const modules = {}
  const files = import.meta.glob('./*/index.js')
  for (const filePath in files) {
    const moduleName = filePath.replace(/(\.\/|\/index\.js)/g, '')
    const key = camelCase(moduleName)
    modules[moduleName] = files[filePath]
    modules[key] = modules[moduleName]
  }
  return modules
}

const modules = importModules()
const compMap = ref({})
const route = useRoute()
const { module, compName } = route.query

const componentName = ref(compName)

onBeforeMount(async () => {
  if (compMap.value[compName]) {
    return
  }
  const comp = await modules[module]?.()
  compMap.value[compName] = markRaw(comp.default)
})
</script>

<style lang="less" scoped>
.shader-container {
  display: flex;
  flex: 1;
}
</style>
