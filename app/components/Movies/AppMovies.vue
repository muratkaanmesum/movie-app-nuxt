<script setup lang="ts">
import { useMovieStore } from "~/composables/movie";
import AppMovie from "./AppMovie.vue";
import { watch } from "vue";
import AppLoader from "../common/AppLoader.vue";

const movieStore = useMovieStore();

// Initialize movies on both server and client
await movieStore.fetchMovies();

watch([() => movieStore.page.value, () => movieStore.type.value], () => {
  movieStore.fetchMovies();
});
</script>

<template>
  <div
    class="flex flex-col justify-center w-full items-center overflow-hidden overflow-x-auto scrollbar-thin scrollbar-thumb-white min-h-[270px]"
  >
    <AppLoader :state="movieStore.loading.value" :color="'black'" />
    <div v-show="!movieStore.loading.value" class="w-full">
      <div class="flex gap-10">
        <AppMovie
          v-for="movie in movieStore.movies.value"
          :id="movie.id"
          :key="movie.id"
          :name="movie.original_title"
          :date="movie.release_date"
          :image-url="`https://image.tmdb.org/t/p/w220_and_h330_face/${movie.poster_path}`"
          :rating="Math.ceil(movie.vote_average * 10)"
        />
      </div>
    </div>
  </div>
  <div class="flex gap-4">
    <button
      type="button"
      class="bg-gray-700 p-2"
      @click="movieStore.decrementPage"
    >
      LeftArrow
    </button>
    <button
      type="button"
      class="bg-gray-700 p-2"
      @click="movieStore.incrementPage"
    >
      RightArrow
    </button>
    <span class="text-white">{{ movieStore.page.value }}</span>
  </div>
</template>
