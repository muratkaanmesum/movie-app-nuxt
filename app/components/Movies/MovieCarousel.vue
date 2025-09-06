<script setup lang="ts">
import AppMovies from "./AppMovies.vue";
import { useMovieStore } from "~/composables/movie";
const movieStore = useMovieStore();
</script>
<template>
  <div class="flex gap-4 items-center !mb-4">
    <h3 class="text-2xl">Trending</h3>
    <div class="rounded-4xl border border-white relative rounded-3xl">
      <div
        :class="
          'bg-white absolute w-1/2 h-full top-0 left-0 rounded-4xl z-0 transition-all rounded-2xl ' +
          (movieStore.getType.value === 'popular' ? '' : '!left-1/2')
        "
      />
      <button
        class="px-4 py-1 rounded-full cursor-pointer -z-20"
        @click="movieStore.setType('popular')"
      >
        <span class="z-10 text-green-300 font-semibold relative">Popular</span>
      </button>
      <button
        class="px-4 py-1 rounded-full cursor-pointer -z-20"
        @click="movieStore.setType('top_rated')"
      >
        <span class="z-10 text-green-300 font-semibold relative"
          >Top Rated</span
        >
      </button>
    </div>
  </div>
  <AppMovies />
</template>
