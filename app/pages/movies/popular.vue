<script setup lang="ts">
import { useMovies } from "~/composables/useMovies";
import { popularSortOptions } from "~/utils/sortOptions";
import AppLoader from "~/components/common/AppLoader.vue";
import MovieSort from "~/components/Movies/MovieSort.vue";
import MovieFilters from "~/components/Movies/MovieFilters.vue";
import MovieGrid from "~/components/Movies/MovieGrid.vue";
import MoviePagination from "~/components/Movies/MoviePagination.vue";

const {
  movies,
  loading,
  currentPage,
  totalPages,
  sortBy,
  selectedGenres,
  minRating,
  minYear,
  maxYear,
  genres,
  fetchMovies,
  applyFilters,
  clearFilters,
} = useMovies("/api/movies/popular", "popularity.desc", 0);

onMounted(() => {
  fetchMovies();
});
</script>

<template>
  <div class="main-background min-h-screen text-white">
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-4xl font-bold mb-8">Popular Movies</h1>

      <div class="flex gap-8">
        <div class="w-72 flex-shrink-0">
          <MovieSort
            v-model="sortBy"
            :options="popularSortOptions"
            @change="applyFilters"
          />

          <MovieFilters
            v-model:selected-genres="selectedGenres"
            v-model:min-rating="minRating"
            v-model:min-year="minYear"
            v-model:max-year="maxYear"
            :genres="genres"
            @clear="clearFilters"
            @apply="applyFilters"
          />
        </div>

        <div class="flex-1">
          <AppLoader :state="loading" :color="'white'" />

          <MovieGrid :movies="movies" :loading="loading" />

          <MoviePagination
            v-show="!loading"
            v-model:current-page="currentPage"
            :total-pages="totalPages"
            :loading="loading"
          />
        </div>
      </div>
    </div>
  </div>
</template>
