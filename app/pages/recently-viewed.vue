<template>
  <div class="main-background min-h-screen text-white">
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-4xl font-bold mb-8">Recently Viewed</h1>

      <div v-if="recentlyViewed.length === 0" class="text-center py-16">
        <div class="text-6xl mb-4">👀</div>
        <h2 class="text-2xl font-bold mb-4">No Recently Viewed Items</h2>
        <p class="text-gray-400 mb-8">
          Start browsing movies and TV shows to see them here!
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
            You've viewed {{ recentlyViewed.length }} item{{
              recentlyViewed.length > 1 ? "s" : ""
            }}
          </p>
          <button
            class="bg-red-600 hover:bg-red-700 px-4 py-2 rounded-lg transition-colors text-sm"
            @click="clearRecentlyViewed"
          >
            Clear History
          </button>
        </div>

        <div
          class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-6"
        >
          <NuxtLink
            v-for="item in recentlyViewed"
            :key="`${item.type}-${item.id}`"
            :to="`/${item.type === 'movie' ? 'movies' : 'tv'}/${item.id}`"
            class="bg-gray-800 rounded-lg overflow-hidden hover:bg-gray-700 transition-colors group"
          >
            <div class="aspect-[2/3] bg-gray-900 relative">
              <img
                v-if="item.poster_path"
                :src="`https://image.tmdb.org/t/p/w500${item.poster_path}`"
                :alt="item.title"
                class="w-full h-full object-cover group-hover:opacity-75 transition-opacity"
                loading="lazy"
              />
              <div
                v-else
                class="w-full h-full flex items-center justify-center"
              >
                <Icon name="mdi:image-off" class="w-12 h-12 text-gray-500" />
              </div>
              <div
                class="absolute top-2 right-2 bg-black/70 px-2 py-1 rounded text-xs"
              >
                {{ item.type === 'movie' ? 'Movie' : 'TV' }}
              </div>
            </div>
            <div class="p-4">
              <h3 class="font-semibold text-sm line-clamp-2 mb-2">
                {{ item.title }}
              </h3>
              <p class="text-xs text-gray-400">
                {{ formatDate(item.viewedAt) }}
              </p>
            </div>
          </NuxtLink>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useRecentlyViewedStore } from "~/composables/recentlyViewed";

const { getRecentlyViewed, clearRecentlyViewed: clear } = useRecentlyViewedStore();

const recentlyViewed = computed(() => getRecentlyViewed.value);

const formatDate = (timestamp: number) => {
  const date = new Date(timestamp);
  const now = new Date();
  const diff = now.getTime() - date.getTime();
  const hours = Math.floor(diff / (1000 * 60 * 60));
  const days = Math.floor(diff / (1000 * 60 * 60 * 24));

  if (hours < 1) return "Just now";
  if (hours < 24) return `${hours} hour${hours > 1 ? "s" : ""} ago`;
  if (days < 7) return `${days} day${days > 1 ? "s" : ""} ago`;
  
  return date.toLocaleDateString();
};

const clearRecentlyViewed = () => {
  if (
    confirm(
      "Are you sure you want to clear your viewing history? This action cannot be undone."
    )
  ) {
    clear();
  }
};

useHead({
  title: "Recently Viewed - Movie Database",
  meta: [
    {
      name: "description",
      content: "View your recently browsed movies and TV shows",
    },
  ],
});
</script>

<style scoped>
.main-background {
  background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
}
</style>

