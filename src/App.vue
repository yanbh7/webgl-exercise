<script setup>
import { RouterLink, RouterView } from "vue-router";
</script>

<template>
  <header>
    <div class="wrapper">
      <h1>Examples</h1>
      <nav>
        <RouterLink to="/">Home</RouterLink>
      </nav>
    </div>
  </header>

  <RouterView v-slot="{ Component }">
    <component :is="Component" />
  </RouterView>
</template>

<style scoped>
header {
  line-height: 1.5;
  height: 55px;
}
h1 {
  margin-right: 20px;
}
.wrapper {
  display: flex;
  align-items: center;
}
</style>
