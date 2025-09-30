<template>
  <div class="main-background min-h-screen text-white">
    <div v-if="pending" class="flex justify-center items-center min-h-screen">
      <AppLoader :state="true" />
    </div>
    
    <div v-else-if="error" class="container mx-auto px-4 py-8">
      <div class="text-center">
        <h1 class="text-2xl font-bold mb-4">Movie Not Found</h1>
        <p class="text-gray-400 mb-4">The movie you're looking for doesn't exist.</p>
        <NuxtLink to="/movies" class="bg-blue-600 hover:bg-blue-700 px-6 py-2 rounded-lg transition-colors">
          Back to Movies
        </NuxtLink>
      </div>
    </div>

    <div v-else-if="movie" class="relative">
      <!-- Backdrop -->
      <div 
        v-if="movie.backdrop_path"
        class="absolute inset-0 w-full h-[60vh] bg-cover bg-center bg-no-repeat opacity-20"
        :style="`background-image: url(https://image.tmdb.org/t/p/original${movie.backdrop_path})`"
      />
      
      <!-- Content -->
      <div class="relative z-10 container mx-auto px-4 py-8">
        <div class="flex flex-col lg:flex-row gap-8 mb-8">
          <!-- Poster -->
          <div class="flex-shrink-0">
            <AppImage
              v-if="movie.poster_path"
              :src="`https://image.tmdb.org/t/p/w500${movie.poster_path}`"
              :alt="movie.title"
              class="w-80 h-auto rounded-lg shadow-lg"
            />
            <div v-else class="w-80 h-[450px] bg-gray-800 rounded-lg flex items-center justify-center">
              <span class="text-gray-400">No Poster Available</span>
            </div>
          </div>

          <!-- Movie Info -->
          <div class="flex-1">
            <div class="flex items-start justify-between mb-4">
              <div>
                <h1 class="text-4xl font-bold mb-2">{{ movie.title }}</h1>
                <p v-if="movie.tagline" class="text-xl text-gray-300 italic mb-4">{{ movie.tagline }}</p>
                <div class="flex items-center gap-4 mb-4">
                  <span class="text-sm text-gray-400">{{ formatDate(movie.release_date) }}</span>
                  <span class="text-sm text-gray-400">{{ formatRuntime(movie.runtime) }}</span>
                  <div class="flex gap-2">
                    <span 
                      v-for="genre in movie.genres" 
                      :key="genre.id"
                      class="bg-gray-700 px-2 py-1 rounded text-xs"
                    >
                      {{ genre.name }}
                    </span>
                  </div>
                </div>
              </div>
              
              <!-- Favorite Button -->
              <button
                @click="toggleFavorite"
                class="flex items-center gap-2 bg-gray-800 hover:bg-gray-700 px-4 py-2 rounded-lg transition-colors"
                :class="{ 'bg-red-600 hover:bg-red-700': isFavorite(movie.id) }"
              >
                <Icon 
                  :name="isFavorite(movie.id) ? 'mdi:heart' : 'mdi:heart-outline'" 
                  class="w-5 h-5" 
                />
                {{ isFavorite(movie.id) ? 'Remove from Favorites' : 'Add to Favorites' }}
              </button>
            </div>

            <!-- User Score -->
            <div class="flex items-center gap-4 mb-6">
              <div class="flex items-center">
                <AppRating :rating="movie.vote_average" size="large" />
                <span class="ml-2 text-lg font-semibold">{{ Math.round(movie.vote_average * 10) }}%</span>
                <span class="ml-1 text-sm text-gray-400">User Score</span>
              </div>
              <span class="text-sm text-gray-400">({{ movie.vote_count.toLocaleString() }} votes)</span>
            </div>

            <!-- Overview -->
            <div class="mb-6">
              <h3 class="text-xl font-semibold mb-3">Overview</h3>
              <p class="text-gray-300 leading-relaxed">{{ movie.overview }}</p>
            </div>

            <!-- Additional Info -->
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
              <div>
                <h4 class="font-semibold mb-2">Status</h4>
                <p class="text-gray-300">{{ movie.status }}</p>
              </div>
              <div>
                <h4 class="font-semibold mb-2">Original Language</h4>
                <p class="text-gray-300">{{ movie.original_language.toUpperCase() }}</p>
              </div>
              <div v-if="movie.budget > 0">
                <h4 class="font-semibold mb-2">Budget</h4>
                <p class="text-gray-300">${{ movie.budget.toLocaleString() }}</p>
              </div>
              <div v-if="movie.revenue > 0">
                <h4 class="font-semibold mb-2">Revenue</h4>
                <p class="text-gray-300">${{ movie.revenue.toLocaleString() }}</p>
              </div>
            </div>
          </div>
        </div>

        <!-- Cast -->
        <div v-if="movie.credits?.cast?.length > 0" class="mb-16">
          <h3 class="text-2xl font-semibold mb-6">Cast</h3>
          <div class="relative">
            <div class="flex overflow-x-auto scrollbar-hide gap-4 pb-4" style="scroll-behavior: smooth;">
              <div 
                v-for="actor in movie.credits.cast.slice(0, 20)" 
                :key="actor.id"
                class="flex-shrink-0 text-center w-32"
              >
                <AppImage
                  v-if="actor.profile_path"
                  :src="`https://image.tmdb.org/t/p/w185${actor.profile_path}`"
                  :alt="actor.name"
                  class="w-32 h-40 object-cover rounded-lg mb-3 shadow-lg"
                />
                <div v-else class="w-32 h-40 bg-gray-800 rounded-lg mb-3 flex items-center justify-center shadow-lg">
                  <Icon name="mdi:account" class="w-8 h-8 text-gray-400" />
                </div>
                <h4 class="font-semibold text-sm mb-1 text-white line-clamp-2">{{ actor.name }}</h4>
                <p class="text-xs text-gray-400 line-clamp-2">{{ actor.character }}</p>
              </div>
            </div>
            <!-- Scroll indicators -->
            <div class="absolute right-0 top-0 bottom-0 w-12 bg-gradient-to-l from-slate-900 to-transparent pointer-events-none" />
            <div class="absolute left-0 top-0 bottom-0 w-4 bg-gradient-to-r from-slate-900 to-transparent pointer-events-none" />
          </div>
        </div>

        <!-- Videos/Trailers -->
        <div v-if="movie.videos?.length > 0" class="mb-8">
          <h3 class="text-2xl font-semibold mb-4">Videos</h3>
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            <div 
              v-for="video in movie.videos.filter(v => v.site === 'YouTube').slice(0, 6)" 
              :key="video.id"
              class="bg-gray-800 rounded-lg overflow-hidden"
            >
              <div class="aspect-video bg-gray-700 flex items-center justify-center">
                <a 
                  :href="`https://www.youtube.com/watch?v=${video.key}`"
                  target="_blank"
                  rel="noopener noreferrer"
                  class="flex items-center justify-center w-full h-full hover:bg-gray-600 transition-colors"
                >
                  <Icon name="mdi:play-circle" class="w-12 h-12 text-white" />
                </a>
              </div>
              <div class="p-3">
                <h4 class="font-semibold text-sm mb-1">{{ video.name }}</h4>
                <p class="text-xs text-gray-400">{{ video.type }}</p>
              </div>
            </div>
          </div>
        </div>

        <!-- Production Companies -->
        <div v-if="movie.production_companies?.length > 0" class="mb-8">
          <h3 class="text-2xl font-semibold mb-4">Production Companies</h3>
          <div class="flex flex-wrap gap-4">
            <div 
              v-for="company in movie.production_companies" 
              :key="company.id"
              class="flex items-center gap-2 bg-gray-800 px-4 py-2 rounded-lg"
            >
              <AppImage
                v-if="company.logo_path"
                :src="`https://image.tmdb.org/t/p/w92${company.logo_path}`"
                :alt="company.name"
                class="w-8 h-8 object-contain"
              />
              <span class="text-sm">{{ company.name }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useFavoritesStore } from '~/composables/favorites'
import { useMovieDetails } from '~/composables/movieDetails'

const route = useRoute()
const movieId = route.params.id as string

// Fetch movie data using composable
const { 
  movie, 
  pending, 
  error, 
  formatDate, 
  formatRuntime
} = useMovieDetails(movieId)

// Set up SEO
useHead({
  title: computed(() => movie.value ? `${movie.value.title} - Movie Database` : 'Movie Database'),
  meta: [
    {
      name: 'description',
      content: computed(() => movie.value?.overview || 'Movie details and information')
    },
    {
      property: 'og:title',
      content: computed(() => movie.value?.title || 'Movie Database')
    },
    {
      property: 'og:description',
      content: computed(() => movie.value?.overview || 'Movie details and information')
    },
    {
      property: 'og:image',
      content: computed(() => movie.value?.poster_path 
        ? `https://image.tmdb.org/t/p/w500${movie.value.poster_path}` 
        : ''
      )
    }
  ]
})

// Favorites functionality
const { isFavorite, toggleFavorite: toggleFav } = useFavoritesStore()

const toggleFavorite = () => {
  if (movie.value) {
    toggleFav(movie.value.id)
  }
}

// Utility functions are now provided by the composable
</script>

<style scoped>
.main-background {
  background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
}

/* Hide scrollbar for webkit browsers */
.scrollbar-hide {
  -ms-overflow-style: none;  /* IE and Edge */
  scrollbar-width: none;  /* Firefox */
}

.scrollbar-hide::-webkit-scrollbar {
  display: none;
}

/* Line clamp utilities */
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;  
  overflow: hidden;
}
</style>
