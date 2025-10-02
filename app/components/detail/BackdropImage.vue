<template>
  <div
    v-if="backdrop"
    class="absolute inset-0 w-full h-[60vh] bg-cover bg-center bg-no-repeat opacity-20"
    :style="`background-image: url(https://image.tmdb.org/t/p/original${backdrop})`"
  />
</template>

<script setup lang="ts">
interface Props {
  backdrop: string | null
}

defineProps<Props>()
</script>
