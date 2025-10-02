<template>
  <div class="flex items-center gap-4 mb-6">
    <div class="flex items-center">
      <AppRating :rating="rating" size="large" />
      <span class="ml-2 text-lg font-semibold">{{ rating }}%</span>
      <span class="ml-1 text-sm text-gray-400">User Score</span>
    </div>
    <span class="text-sm text-gray-400"
      >({{ voteCount.toLocaleString() }} votes)</span
    >
  </div>
</template>

<script setup lang="ts">
interface Props {
  rating: number;
  voteCount: number;
}

defineProps<Props>();
</script>
