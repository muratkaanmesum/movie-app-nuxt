<script setup lang="ts">
defineProps<{
  color?: string
  customClass?: string
  state: boolean
}>()
</script>
<template>
  <div :class="['loader', $props.customClass]" :style="{ borderColor: color }" v-show="state"></div>
</template>
