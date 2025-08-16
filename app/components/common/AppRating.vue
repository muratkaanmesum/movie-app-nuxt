<script setup lang="ts">
defineProps({
  rating: {
    type: Number,
    required: true,
    default: 0,
  },
})
</script>

<template>
  <div class="bg-black rounded-full">
    <div class="relative w-10 h-10">
      <svg class="w-full h-full" viewBox="0 0 36 36">
        <path
          class="text-gray-700"
          stroke="currentColor"
          stroke-width="3"
          fill="none"
          d="M18 2.0845
             a 15.9155 15.9155 0 0 1 0 31.831
             a 15.9155 15.9155 0 0 1 0 -31.831"
        />
        <path
          :class="{
            'text-lime-400': rating > 70,
            'text-yellow-400': rating > 40 && rating <= 70,
            'text-red-500': rating <= 40,
          }"
          stroke="currentColor"
          stroke-width="3"
          :stroke-dasharray="`${rating}, 100`"
          fill="none"
          d="M18 2.0845
             a 15.9155 15.9155 0 0 1 0 31.831
             a 15.9155 15.9155 0 0 1 0 -31.831"
        />
      </svg>
      <div class="absolute inset-0 flex items-center justify-center text-white text-xs font-bold">
        {{ rating }}%
      </div>
    </div>
  </div>
</template>
