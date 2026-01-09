<script setup>
import MainCardVue from './main-card.vue'
import pageConfig from './home-page.config.js'
import { useRouter } from 'vue-router'

const pages = Object.values(pageConfig)
const reoter = useRouter()

const onClick = async (page) => {
  reoter.push({ name: 'shader-exercise', query: page })
}
</script>

<template>
  <main class="main">
    <template v-for="page in pages" :key="page.compName">
      <MainCardVue @click="onClick(page)" />
    </template>
  </main>
</template>

<style lang="less" scoped>
.main {
  display: flex;
  justify-content: start;
  flex-wrap: wrap;
  align-items: center;
}
</style>
