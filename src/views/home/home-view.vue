<script setup>
import MainCardVue from './main-card.vue'
import pageConfig from './home-page.config.js'
import { useRouter } from 'vue-router'

const pages = Object.values(pageConfig)
const reoter = useRouter()

const onClick = async (page) => {
  const { module, compName } = page
  reoter.push({ name: 'shader-exercise', query: { module, compName } })
}
</script>

<template>
  <main class="main">
    <template v-for="page in pages" :key="page.compName">
      <MainCardVue :imgAttrs="page" @click="onClick(page)" />
    </template>
  </main>
</template>

<style lang="less" scoped>
.main {
  display: flex;
  justify-content: flex-start;
  align-content: flex-start;
  flex-wrap: wrap;
  align-items: center;
  height: calc(100% - 55px);
  overflow-y: auto;
}
</style>
