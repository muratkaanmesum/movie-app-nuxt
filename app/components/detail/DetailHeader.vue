<template>
  <div class="flex flex-col lg:flex-row gap-8 mb-8">
    <div class="flex-shrink-0">
      <AppImage
        v-if="poster"
        :src="poster"
        :alt="title"
        class="w-80 h-auto rounded-lg shadow-lg"
      />
      <div
        v-else
        class="w-80 h-[450px] bg-gray-800 rounded-lg flex items-center justify-center"
      >
        <span class="text-gray-400">No Poster Available</span>
      </div>
    </div>

    <div class="flex-1">
      <div class="flex items-start justify-between mb-4">
        <div>
          <h1 class="text-4xl font-bold mb-2">{{ title }}</h1>
          <p v-if="tagline" class="text-xl text-gray-300 italic mb-4">
            {{ tagline }}
          </p>
          <div class="flex items-center gap-4 mb-4">
            <span class="text-sm text-gray-400">{{ date }}</span>
            <span v-if="runtime" class="text-sm text-gray-400">{{
              runtime
            }}</span>
            <div class="flex gap-2">
              <span
                v-for="genre in genres"
                :key="genre.id"
                class="bg-gray-700 px-2 py-1 rounded text-xs"
              >
                {{ genre.name }}
              </span>
            </div>
          </div>
        </div>

        <FavoriteButton
          :id="id"
          :is-favorite="isFavorite"
          @toggle="$emit('toggleFavorite')"
        />
      </div>

      <UserScore :rating="rating" :vote-count="voteCount" />

      <div class="mb-6">
        <h3 class="text-xl font-semibold mb-3">Overview</h3>
        <p class="text-gray-300 leading-relaxed">{{ overview }}</p>
      </div>

      <slot name="additional-info" />
    </div>
  </div>
</template>

<script setup lang="ts">
interface Genre {
  id: number;
  name: string;
}

interface Props {
  id: number;
  title: string;
  tagline?: string;
  poster?: string;
  date: string;
  runtime?: string;
  genres: Genre[];
  rating: number;
  voteCount: number;
  overview: string;
  isFavorite: boolean;
}

defineProps<Props>();
defineEmits<{
  toggleFavorite: [];
}>();
</script>
