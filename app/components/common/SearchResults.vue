<script setup lang="ts">
import type { SearchResult } from "~/composables/search";

defineProps<{
  results: SearchResult[];
  isLoading: boolean;
  searchQuery: string;
  showResults: boolean;
}>();

defineEmits<{
  selectResult: [result: SearchResult];
}>();
</script>

<template>
  <div
    v-if="showResults || isLoading"
    class="absolute z-32 mt-1 w-full bg-white rounded-lg shadow-lg max-h-64 overflow-y-auto"
    @mousedown.prevent
  >
    <div v-if="isLoading" class="flex justify-center items-center py-4">
      <div
        class="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-500"
      ></div>
    </div>

    <div
      v-else-if="results.length === 0 && searchQuery"
      class="py-4 px-4 text-center text-gray-500"
    >
      No movies found matching "{{ searchQuery }}"
    </div>

    <ul v-else class="py-2">
      <li
        v-for="result in results"
        :key="result.id"
        class="px-4 py-2 hover:bg-gray-100 cursor-pointer flex items-center"
        @click="$emit('selectResult', result)"
      >
        <div class="w-10 h-14 flex-shrink-0 mr-3">
          <img
            v-if="result.poster_path"
            :src="`https://image.tmdb.org/t/p/w92${result.poster_path}`"
            :alt="result.title"
            class="w-full h-full object-cover rounded"
          />
          <div
            v-else
            class="w-full h-full bg-gray-200 rounded flex items-center justify-center text-gray-400 text-xs"
          >
            No image
          </div>
        </div>

        <div class="flex-1">
          <div class="font-medium text-gray-900">{{ result.title }}</div>
          <div v-if="result.release_date" class="text-sm text-gray-500">
            {{ new Date(result.release_date).getFullYear() }}
          </div>
        </div>
        <div
          class="text-xs bg-gray-200 rounded-full px-2 py-1 text-gray-700 capitalize"
        >
          {{ result.type }}
        </div>
      </li>
    </ul>
  </div>
</template>
