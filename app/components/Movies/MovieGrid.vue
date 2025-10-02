<script setup lang="ts">
import AppMovie from "~/components/Movies/AppMovie.vue";

interface Movie {
  id: number;
  original_title: string;
  release_date: string;
  poster_path: string;
  vote_average: number;
}

interface Props {
  movies: Movie[];
  loading: boolean;
}

defineProps<Props>();
</script>

<template>
  <div class="flex-1">
    <div v-show="!loading">
      <div
        class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-6 mb-8"
      >
        <AppMovie
          v-for="movie in movies"
          :id="movie.id"
          :key="movie.id"
          :name="movie.original_title"
          :date="movie.release_date"
          :image-url="`https://image.tmdb.org/t/p/w220_and_h330_face/${movie.poster_path}`"
          :rating="Math.round(movie.vote_average * 10)"
          class="mx-auto"
        />
      </div>
    </div>
  </div>
</template>
