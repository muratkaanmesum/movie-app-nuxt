<template>
  <button
    class="flex items-center gap-2 bg-gray-800 hover:bg-gray-700 px-4 py-2 rounded-lg transition-colors"
    :class="{ 'bg-red-600 hover:bg-red-700': isFavorite }"
    @click="$emit('toggle')"
  >
    <Icon
      :name="isFavorite ? 'mdi:heart' : 'mdi:heart-outline'"
      class="w-5 h-5"
    />
    {{ isFavorite ? "Remove from Favorites" : "Add to Favorites" }}
  </button>
</template>

<script setup lang="ts">
interface Props {
  id: number;
  isFavorite: boolean;
}

defineProps<Props>();
defineEmits<{
  toggle: [];
}>();
</script>
