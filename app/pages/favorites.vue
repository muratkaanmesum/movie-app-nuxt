<template>
  <div class="main-background min-h-screen text-white">
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-4xl font-bold mb-8">My Favorites</h1>
      
      <div v-if="favoriteIds.length === 0" class="text-center py-16">
        <div class="text-6xl mb-4">💔</div>
        <h2 class="text-2xl font-bold mb-4">No Favorites Yet</h2>
        <p class="text-gray-400 mb-8">Start adding movies and TV shows to your favorites!</p>
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
            You have {{ favoriteIds.length }} favorite{{ favoriteIds.length > 1 ? 's' : '' }}
          </p>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-6">
          <div 
            v-for="favoriteId in favoriteIds" 
            :key="favoriteId"
            class="bg-gray-800 rounded-lg p-4 hover:bg-gray-700 transition-colors"
          >
            <div class="flex items-center justify-between mb-4">
              <h3 class="text-lg font-semibold">ID: {{ favoriteId }}</h3>
              <button
                class="text-red-400 hover:text-red-300 transition-colors"
                title="Remove from favorites"
                @click="removeFavorite(favoriteId)"
              >
                <Icon name="mdi:heart-remove" class="w-5 h-5" />
              </button>
            </div>
            
            <div class="flex gap-2">
              <NuxtLink 
                :to="`/movies/${favoriteId}`"
                class="flex-1 bg-blue-600 hover:bg-blue-700 px-3 py-2 rounded text-sm text-center transition-colors"
              >
                View as Movie
              </NuxtLink>
              <NuxtLink 
                :to="`/tv/${favoriteId}`"
                class="flex-1 bg-green-600 hover:bg-green-700 px-3 py-2 rounded text-sm text-center transition-colors"
              >
                View as TV Show
              </NuxtLink>
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
import { useFavoritesStore } from '~/composables/favorites'

const { favoriteIds, removeFavorite } = useFavoritesStore()

const clearAllFavorites = () => {
  if (confirm('Are you sure you want to remove all favorites? This action cannot be undone.')) {
    favoriteIds.value = []
  }
}

// SEO
useHead({
  title: 'My Favorites - Movie Database',
  meta: [
    {
      name: 'description',
      content: 'View and manage your favorite movies and TV shows'
    }
  ]
})
</script>

<style scoped>
.main-background {
  background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
}
</style>
