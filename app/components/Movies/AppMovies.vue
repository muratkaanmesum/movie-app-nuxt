<script setup lang="ts">
import { useMovieStore } from "~/composables/movie";
import AppMovie from "./AppMovie.vue";
import { watch, onMounted, onUnmounted } from "vue";
import AppLoader from "../common/AppLoader.vue";

const movieStore = useMovieStore();

// Initialize movies on both server and client
await movieStore.fetchMovies();

watch([() => movieStore.page.value, () => movieStore.type.value], () => {
  movieStore.fetchMovies();
});

// Keyboard navigation
const handleKeydown = (event: KeyboardEvent) => {
  if (movieStore.loading.value) return;

  if (event.key === "ArrowLeft") {
    event.preventDefault();
    movieStore.decrementPage();
  } else if (event.key === "ArrowRight") {
    event.preventDefault();
    movieStore.incrementPage();
  }
};

onMounted(() => {
  if (import.meta.client) {
    window.addEventListener("keydown", handleKeydown);
  }
});

onUnmounted(() => {
  if (import.meta.client) {
    window.removeEventListener("keydown", handleKeydown);
  }
});
</script>

<template>
  <div class="relative">
    <!-- Movie Grid Container -->
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
            :rating="Math.round(movie.vote_average * 10)"
          />
        </div>
      </div>
    </div>

    <!-- Navigation Controls -->
    <div class="flex justify-between items-center mt-6">
      <!-- Left Arrow -->
      <button
        type="button"
        :disabled="movieStore.loading.value"
        aria-label="Previous page"
        title="Previous page (Left arrow key)"
        class="flex items-center justify-center w-14 h-14 bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 text-white rounded-full transition-all duration-300 shadow-lg hover:shadow-xl transform hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none"
        @click="movieStore.decrementPage"
      >
        <svg
          class="w-6 h-6"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
          aria-hidden="true"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2.5"
            d="M15 19l-7-7 7-7"
          />
        </svg>
      </button>

      <!-- Page indicator with total pages info -->
      <div class="flex items-center gap-3">
        <span
          class="text-white text-sm bg-gray-800 px-4 py-2 rounded-full border border-gray-600"
        >
          Page {{ movieStore.page.value }} of 20
        </span>
        <div class="text-gray-400 text-xs hidden sm:block">
          Use ← → arrow keys to navigate
        </div>
      </div>

      <!-- Right Arrow -->
      <button
        type="button"
        :disabled="movieStore.loading.value"
        aria-label="Next page"
        title="Next page (Right arrow key)"
        class="flex items-center justify-center w-14 h-14 bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 text-white rounded-full transition-all duration-300 shadow-lg hover:shadow-xl transform hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none"
        @click="movieStore.incrementPage"
      >
        <svg
          class="w-6 h-6"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
          aria-hidden="true"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2.5"
            d="M9 5l7 7-7 7"
          />
        </svg>
      </button>
    </div>
  </div>
</template>
