<script setup lang="ts">
interface Genre {
  id: number;
  name: string;
}

interface Props {
  selectedGenres: number[];
  minRating: number;
  minYear: number;
  maxYear: number;
  genres: Genre[];
}

interface Emits {
  (e: 'update:selected-genres', value: number[]): void;
  (e: 'update:min-rating' | 'update:min-year' | 'update:max-year', value: number): void;
  (e: 'clear' | 'apply'): void;
}

defineProps<Props>();
defineEmits<Emits>();
</script>

<template>
  <div class="w-72 flex-shrink-0">
    <div class="bg-gray-800 rounded-lg p-4 mb-6">
      <div class="flex items-center justify-between mb-4">
        <h3 class="text-lg font-semibold">Filters</h3>
        <button
          class="text-blue-400 hover:text-blue-300 text-sm"
          @click="$emit('clear')"
        >
          Clear
        </button>
      </div>

      <div class="mb-6">
        <h4 class="font-medium mb-3">Genres</h4>
        <div class="max-h-48 overflow-y-auto">
          <label
            v-for="genre in genres"
            :key="genre.id"
            class="flex items-center mb-2 cursor-pointer hover:bg-gray-700 rounded px-2 py-1"
          >
            <input
              :checked="selectedGenres.includes(genre.id)"
              type="checkbox"
              :value="genre.id"
              class="mr-2 accent-blue-500"
              @change="
                (event) => {
                  const target = event.target as HTMLInputElement;
                  const value = parseInt(target.value);
                  const newGenres = target.checked
                    ? [...selectedGenres, value]
                    : selectedGenres.filter(id => id !== value);
                  $emit('update:selected-genres', newGenres);
                }
              "
            >
            <span class="text-sm">{{ genre.name }}</span>
          </label>
        </div>
      </div>

      <div class="mb-6">
        <h4 class="font-medium mb-3">User Rating</h4>
        <div class="flex items-center gap-2">
          <input
            :value="minRating"
            type="range"
            min="0"
            max="10"
            step="0.5"
            class="flex-1 accent-blue-500"
            @input="$emit('update:min-rating', parseFloat(($event.target as HTMLInputElement).value))"
          >
          <span class="text-sm">{{ minRating }}+</span>
        </div>
      </div>

      <div class="mb-6">
        <h4 class="font-medium mb-3">Release Year</h4>
        <div class="flex gap-2">
          <input
            :value="minYear"
            type="number"
            :min="1900"
            :max="maxYear"
            class="w-20 bg-gray-700 border border-gray-600 rounded px-2 py-1 text-sm"
            placeholder="From"
            @input="$emit('update:min-year', parseInt(($event.target as HTMLInputElement).value))"
          >
          <span class="text-gray-400 self-center">to</span>
          <input
            :value="maxYear"
            type="number"
            :min="minYear"
            :max="new Date().getFullYear()"
            class="w-20 bg-gray-700 border border-gray-600 rounded px-2 py-1 text-sm"
            placeholder="To"
            @input="$emit('update:max-year', parseInt(($event.target as HTMLInputElement).value))"
          >
        </div>
      </div>

      <button
        class="w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded transition-colors"
        @click="$emit('apply')"
      >
        Apply Filters
      </button>
    </div>

    <div class="bg-gray-800 rounded-lg p-4">
      <h3 class="text-lg font-semibold mb-4">Where To Watch</h3>
      <p class="text-gray-400 text-sm">
        Coming soon - streaming service filters
      </p>
    </div>
  </div>
</template>
