<template>
  <div class="main-background min-h-screen text-white">
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-4xl font-bold mb-8">My Favorites</h1>

      <div v-if="favoriteIds.length === 0" class="text-center py-16">
        <div class="text-6xl mb-4">💔</div>
        <h2 class="text-2xl font-bold mb-4">No Favorites Yet</h2>
        <p class="text-gray-400 mb-8">
          Start adding movies and TV shows to your favorites!
        </p>
        <div class="flex gap-4 justify-center">
          <NuxtLink
            to="/movies"
            class="bg-blue-600 hover:bg-blue-700 px-6 py-3 rounded-lg transition-colors"
          >
            Browse Movies
          </NuxtLink>
          <NuxtLink
            to="/tv"
            class="bg-green-600 hover:bg-green-700 px-6 py-3 rounded-lg transition-colors"
          >
            Browse TV Shows
          </NuxtLink>
        </div>
      </div>

      <div v-else>
        <div class="mb-8">
          <p class="text-gray-400">
            You have {{ favoriteIds.length }} favorite{{
              favoriteIds.length > 1 ? "s" : ""
            }}
          </p>
        </div>

        <div
          class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-6"
        >
          <div
            v-for="favoriteId in favoriteIds"
            :key="favoriteId"
            class="bg-gray-800 rounded-lg overflow-hidden hover:bg-gray-700 transition-colors group"
          >
            <NuxtLink :to="`/movies/${favoriteId}`" class="block">
              <div class="aspect-[2/3] bg-gray-900 relative">
                <img
                  v-if="favoriteMovies[favoriteId]?.poster_path"
                  :src="`https://image.tmdb.org/t/p/w500${favoriteMovies[favoriteId].poster_path}`"
                  :alt="favoriteMovies[favoriteId]?.title || favoriteMovies[favoriteId]?.name"
                  class="w-full h-full object-cover group-hover:opacity-75 transition-opacity"
                  loading="lazy"
                />
                <div
                  v-else
                  class="w-full h-full flex items-center justify-center"
                >
                  <Icon name="mdi:image-off" class="w-12 h-12 text-gray-500" />
                </div>
                <button
                  class="absolute top-2 right-2 bg-black/70 hover:bg-red-600 p-2 rounded-full transition-colors z-10"
                  @click.stop="removeFavorite(favoriteId)"
                  title="Remove from favorites"
                >
                  <Icon name="mdi:heart" class="w-5 h-5 text-red-400" />
                </button>
              </div>
            </NuxtLink>
            <div class="p-4">
              <h3 class="font-semibold text-sm line-clamp-2 mb-2">
                {{ favoriteMovies[favoriteId]?.title || favoriteMovies[favoriteId]?.name || `Movie ID: ${favoriteId}` }}
              </h3>
              <p v-if="favoriteMovies[favoriteId]?.release_date || favoriteMovies[favoriteId]?.first_air_date" class="text-xs text-gray-400">
                {{ formatDate(favoriteMovies[favoriteId]?.release_date || favoriteMovies[favoriteId]?.first_air_date) }}
              </p>
            </div>
          </div>
        </div>

        <div class="mt-8 text-center">
          <button
            class="bg-red-600 hover:bg-red-700 px-6 py-3 rounded-lg transition-colors"
            @click="clearAllFavorites"
          >
            Clear All Favorites
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useFavoritesStore } from "~/composables/favorites";

const { favoriteIds, removeFavorite } = useFavoritesStore();

// Fetch movie details for favorites
const favoriteMovies = ref<Record<number, any>>({});

const fetchMovieDetails = async (id: number) => {
  if (favoriteMovies.value[id]) return; // Already fetched
  
  try {
    // Try as movie first
    const movieData = await $fetch(`/api/movies/details/${id}`);
    if (movieData) {
      favoriteMovies.value[id] = movieData;
      return;
    }
  } catch (e) {
    // Try as TV show
    try {
      const tvData = await $fetch(`/api/tv/details/${id}`);
      if (tvData) {
        favoriteMovies.value[id] = tvData;
      }
    } catch (e2) {
      console.error(`Failed to fetch details for ID ${id}:`, e2);
    }
  }
};

// Fetch all favorite movie details
watch(favoriteIds, async (newIds) => {
  for (const id of newIds) {
    await fetchMovieDetails(id);
  }
}, { immediate: true });

const formatDate = (date: string) => {
  if (!date) return '';
  return new Date(date).getFullYear().toString();
};

const clearAllFavorites = () => {
  if (
    confirm(
      "Are you sure you want to remove all favorites? This action cannot be undone."
    )
  ) {
    favoriteIds.value = [];
    favoriteMovies.value = {};
  }
};

// SEO
useHead({
  title: "My Favorites - Movie Database",
  meta: [
    {
      name: "description",
      content: "View and manage your favorite movies and TV shows",
    },
  ],
});
</script>

<style scoped>
.main-background {
  background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
}
</style>
