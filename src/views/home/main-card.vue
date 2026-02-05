<template>
  <div class="main-card w-100">
    <img :src="imgAttrs.imgSrc" alt="" />
    <div class="desc-wrap">
      {{ imgAttrs.desc }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'MainCard',

  props: {
    imgAttrs: {
      type: Object,
      default: () => ({}),
    },
  },

  setup(props, ctx) {
    return {}
  },
}
</script>

<style lang="less" scoped>
.main-card {
  @width: calc((94vw - 60px) / 4);
  position: relative;
  margin-right: 1vw;
  &:nth-child(4n) {
    margin-right: 0;
  }
  margin-bottom: 1vw;
  height: 180px;
  width: @width;
  border-radius: 4px;
  img {
    width: 100%;
    height: 100%;
    display: block;
    border-radius: 4px;
    object-fit: cover;
  }
  .desc-wrap {
    position: absolute;
    bottom: 0;
    left: 0;
    width: 100%;
    text-align: center;
    background-color: #cccccc66;
  }
}
</style>
