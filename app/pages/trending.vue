<template>
  <div class="main-background min-h-screen text-white">
    <div class="container mx-auto px-4 py-8">
      <div class="flex items-center justify-between mb-8">
        <h1 class="text-4xl font-bold">Trending</h1>
        <div class="flex gap-4">
          <button
            :class="[
              'px-4 py-2 rounded-lg transition-colors',
              timeWindow === 'day'
                ? 'bg-blue-600 text-white'
                : 'bg-gray-700 hover:bg-gray-600 text-gray-300'
            ]"
            @click="timeWindow = 'day'"
          >
            Today
          </button>
          <button
            :class="[
              'px-4 py-2 rounded-lg transition-colors',
              timeWindow === 'week'
                ? 'bg-blue-600 text-white'
                : 'bg-gray-700 hover:bg-gray-600 text-gray-300'
            ]"
            @click="timeWindow = 'week'"
          >
            This Week
          </button>
        </div>
      </div>

      <div class="flex gap-4 mb-6">
        <button
          :class="[
            'px-4 py-2 rounded-lg transition-colors',
            contentType === 'movie'
              ? 'bg-blue-600 text-white'
              : 'bg-gray-700 hover:bg-gray-600 text-gray-300'
          ]"
          @click="contentType = 'movie'"
        >
          Movies
        </button>
        <button
          :class="[
            'px-4 py-2 rounded-lg transition-colors',
            contentType === 'tv'
              ? 'bg-green-600 text-white'
              : 'bg-gray-700 hover:bg-gray-600 text-gray-300'
          ]"
          @click="contentType = 'tv'"
        >
          TV Shows
        </button>
      </div>

      <div v-if="pending" class="flex justify-center items-center py-20">
        <AppLoader :state="true" />
      </div>

      <div v-else-if="error" class="text-center py-20">
        <p class="text-red-400 mb-4">{{ error.message }}</p>
        <button
          class="bg-blue-600 hover:bg-blue-700 px-6 py-3 rounded-lg transition-colors"
          @click="refresh"
        >
          Retry
        </button>
      </div>

      <div v-else-if="trending && trending.results">
        <div class="mb-6">
          <p class="text-gray-400">
            Showing {{ trending.results.length }} of {{ trending.total_results }} trending {{
              contentType === 'movie' ? 'movies' : 'TV shows'
            }}
          </p>
        </div>

        <MovieGrid v-if="contentType === 'movie'" :movies="trending.results" :loading="pending" />
        <div
          v-else
          class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-6"
        >
          <AppTVShow
            v-for="show in trending.results"
            :key="show.id"
            :id="show.id"
            :name="show.name || show.original_name"
            :date="show.first_air_date || ''"
            :image-url="show.poster_path ? `https://image.tmdb.org/t/p/w500${show.poster_path}` : ''"
            :rating="show.vote_average ? Math.round(show.vote_average * 10) : 0"
          />
        </div>

        <MoviePagination
          v-if="trending.total_pages > 1"
          v-model:current-page="currentPage"
          :total-pages="trending.total_pages"
          :loading="pending"
        />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import MovieGrid from "~/components/Movies/MovieGrid.vue";
import MoviePagination from "~/components/Movies/MoviePagination.vue";
import AppTVShow from "~/components/TV/AppTVShow.vue";
import AppLoader from "~/components/common/AppLoader.vue";

const contentType = ref<'movie' | 'tv'>('movie');
const timeWindow = ref<'day' | 'week'>('day');
const currentPage = ref(1);

const {
  data: trending,
  pending,
  error,
  refresh,
} = await useFetch(
  () => `/api/${contentType.value === 'movie' ? 'movies' : 'tv'}/trending`,
  {
    query: {
      time_window: timeWindow,
      page: currentPage,
    },
    watch: [contentType, timeWindow, currentPage],
    default: () => ({ results: [], total_results: 0, total_pages: 0 }),
  }
);

useHead({
  title: "Trending - Movie Database",
  meta: [
    {
      name: "description",
      content: "Discover trending movies and TV shows today and this week",
    },
  ],
});
</script>

<style scoped>
.main-background {
  background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
}
</style>

