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
}
</script>

<style lang="less" scoped>
.main-card {
  @width: calc((97vw - 60px) / 4);
  position: relative;
  margin-right: 1vw;
  &:nth-child(4n) {
    margin-right: 0;
  }
  margin-bottom: 1vw;
  width: @width;
  border-radius: 4px;
  overflow: hidden;

  /* 现代浏览器：使用 aspect-ratio */
  aspect-ratio: 300 / 180;

  /* 回退：使用伪元素创建内在比例（180 / 300 = 60%）*/
  &::before {
    content: '';
    display: block;
    padding-top: 60%;
  }

  /* 如果支持 aspect-ratio，隐藏回退占位 */
  @supports (aspect-ratio: 1 / 1) {
    &::before {
      display: none;
    }
  }

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
