<template>
  <div class="main-card w-100"></div>
</template>

<script>
import { toRefs } from 'vue'

export default {
  name: 'MainCard',

  props: {},

  setup(props, ctx) {
    return {}
  },
}
</script>

<style lang="less" scoped>
.main-card {
  height: 100px;
  flex: 1;
  border-radius: 4px;
  border: 1px solid red;
}
</style>
