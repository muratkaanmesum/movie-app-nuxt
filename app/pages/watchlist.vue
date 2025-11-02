<template>
  <div class="main-background min-h-screen text-white">
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-4xl font-bold mb-8">My Watchlist</h1>

      <div v-if="watchlistIds.length === 0" class="text-center py-16">
        <div class="text-6xl mb-4">📝</div>
        <h2 class="text-2xl font-bold mb-4">Your Watchlist is Empty</h2>
        <p class="text-gray-400 mb-8">
          Start adding movies and TV shows to your watchlist to save them for later!
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
        <div class="mb-8 flex items-center justify-between">
          <p class="text-gray-400">
            You have {{ watchlistIds.length }} item{{
              watchlistIds.length > 1 ? "s" : ""
            }} in your watchlist
          </p>
          <button
            class="bg-red-600 hover:bg-red-700 px-4 py-2 rounded-lg transition-colors text-sm"
            @click="clearWatchlist"
          >
            Clear All
          </button>
        </div>

        <div
          class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-6"
        >
          <div
            v-for="itemId in watchlistIds"
            :key="itemId"
            class="bg-gray-800 rounded-lg overflow-hidden hover:bg-gray-700 transition-colors group"
          >
            <NuxtLink :to="`/movies/${itemId}`" class="block">
              <div class="aspect-[2/3] bg-gray-900 relative">
                <img
                  v-if="watchlistItems[itemId]?.poster_path"
                  :src="`https://image.tmdb.org/t/p/w500${watchlistItems[itemId].poster_path}`"
                  :alt="watchlistItems[itemId]?.title || watchlistItems[itemId]?.name"
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
                  class="absolute top-2 right-2 bg-black/70 hover:bg-blue-600 p-2 rounded-full transition-colors z-10"
                  @click.stop="removeFromWatchlist(itemId)"
                  title="Remove from watchlist"
                >
                  <Icon name="mdi:bookmark-check" class="w-5 h-5 text-blue-400" />
                </button>
              </div>
            </NuxtLink>
            <div class="p-4">
              <h3 class="font-semibold text-sm line-clamp-2 mb-2">
                {{ watchlistItems[itemId]?.title || watchlistItems[itemId]?.name || `Item ID: ${itemId}` }}
              </h3>
              <p v-if="watchlistItems[itemId]?.release_date || watchlistItems[itemId]?.first_air_date" class="text-xs text-gray-400">
                {{ formatDate(watchlistItems[itemId]?.release_date || watchlistItems[itemId]?.first_air_date) }}
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useWatchlistStore } from "~/composables/watchlist";

const { watchlistIds, removeFromWatchlist, clearWatchlist: clear } = useWatchlistStore();

// Fetch movie details for watchlist items
const watchlistItems = ref<Record<number, any>>({});

const fetchItemDetails = async (id: number) => {
  if (watchlistItems.value[id]) return; // Already fetched
  
  try {
    // Try as movie first
    const movieData = await $fetch(`/api/movies/details/${id}`);
    if (movieData) {
      watchlistItems.value[id] = movieData;
      return;
    }
  } catch (e) {
    // Try as TV show
    try {
      const tvData = await $fetch(`/api/tv/details/${id}`);
      if (tvData) {
        watchlistItems.value[id] = tvData;
      }
    } catch (e2) {
      console.error(`Failed to fetch details for ID ${id}:`, e2);
    }
  }
};

// Fetch all watchlist item details
watch(watchlistIds, async (newIds) => {
  for (const id of newIds) {
    await fetchItemDetails(id);
  }
}, { immediate: true });

const formatDate = (date: string) => {
  if (!date) return '';
  return new Date(date).getFullYear().toString();
};

const clearWatchlist = () => {
  if (
    confirm(
      "Are you sure you want to clear your watchlist? This action cannot be undone."
    )
  ) {
    clear();
    watchlistItems.value = {};
  }
};

useHead({
  title: "My Watchlist - Movie Database",
  meta: [
    {
      name: "description",
      content: "View and manage your watchlist of movies and TV shows",
    },
  ],
});
</script>

<style scoped>
.main-background {
  background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
}
</style>

