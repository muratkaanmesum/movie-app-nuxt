<script setup lang="ts">
defineProps<{
  src: string
  class?: string
}>()
</script>
<template>
  <img :class="['w-full', 'h-full', $props.class]" :src="src" />
</template>
