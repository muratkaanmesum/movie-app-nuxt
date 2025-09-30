<template>
  <div class="main-background min-h-screen text-white">
    <div class="container mx-auto px-4 py-8">
      <div class="flex items-center justify-between mb-8">
        <h1 class="text-4xl font-bold">Popular TV Shows</h1>
        <NuxtLink 
          to="/tv" 
          class="bg-gray-800 hover:bg-gray-700 px-4 py-2 rounded-lg transition-colors"
        >
          Back to TV Shows
        </NuxtLink>
      </div>

      <div v-if="loading" class="flex justify-center items-center min-h-[400px]">
        <AppLoader :state="true" />
      </div>

      <div v-else-if="error" class="text-center py-8">
        <h2 class="text-2xl font-bold mb-4">Error Loading TV Shows</h2>
        <p class="text-gray-400 mb-4">{{ error }}</p>
        <button 
          class="bg-blue-600 hover:bg-blue-700 px-6 py-2 rounded-lg transition-colors"
          @click="refresh()" 
        >
          Try Again
        </button>
      </div>

      <div v-else>
        <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-6 mb-8">
          <AppTVShow
            v-for="show in tvShows"
            :id="show.id"
            :key="show.id"
            :name="show.name"
            :date="show.first_air_date"
            :image-url="`https://image.tmdb.org/t/p/w220_and_h330_face/${show.poster_path}`"
            :rating="Math.ceil(show.vote_average * 10)"
          />
        </div>

        <!-- Pagination -->
        <div v-if="totalPages > 1" class="flex justify-center items-center gap-4">
          <button
            :disabled="currentPage <= 1"
            class="px-4 py-2 bg-gray-800 rounded-lg disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-700 transition-colors"
            @click="goToPage(currentPage - 1)"
          >
            Previous
          </button>
          
          <span class="px-4 py-2">
            Page {{ currentPage }} of {{ Math.min(totalPages, 500) }}
          </span>
          
          <button
            :disabled="currentPage >= Math.min(totalPages, 500)"
            class="px-4 py-2 bg-gray-800 rounded-lg disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-700 transition-colors"
            @click="goToPage(currentPage + 1)"
          >
            Next
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import AppTVShow from '~/components/TV/AppTVShow.vue'

interface TVShow {
  id: number
  name: string
  first_air_date: string
  poster_path: string
  vote_average: number
}

interface TVResponse {
  results: TVShow[]
  page: number
  total_pages: number
  total_results: number
}

const currentPage = ref(1)

const { data, pending: loading, error, refresh } = await useFetch<TVResponse>('/api/tv/popular', {
  key: 'popular-tv-shows',
  query: {
    page: currentPage
  },
  transform: (data: TVResponse) => data
})

const tvShows = computed(() => data.value?.results || [])
const totalPages = computed(() => data.value?.total_pages || 0)

const goToPage = (page: number) => {
  currentPage.value = page
  refresh()
  // Scroll to top when page changes
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

// SEO
useHead({
  title: 'Popular TV Shows - Movie Database',
  meta: [
    {
      name: 'description',
      content: 'Discover the most popular TV shows currently trending'
    }
  ]
})
</script>

<style scoped>
.main-background {
  background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
}
</style>
