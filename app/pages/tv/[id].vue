<template>
  <div class="main-background min-h-screen text-white">
    <div v-if="pending" class="flex justify-center items-center min-h-screen">
      <AppLoader :state="true" />
    </div>
    
    <div v-else-if="error" class="container mx-auto px-4 py-8">
      <div class="text-center">
        <h1 class="text-2xl font-bold mb-4">TV Show Not Found</h1>
        <p class="text-gray-400 mb-4">The TV show you're looking for doesn't exist.</p>
        <NuxtLink to="/tv" class="bg-blue-600 hover:bg-blue-700 px-6 py-2 rounded-lg transition-colors">
          Back to TV Shows
        </NuxtLink>
      </div>
    </div>

    <div v-else-if="tvShow" class="relative">
      <!-- Backdrop -->
      <div 
        v-if="tvShow.backdrop_path"
        class="absolute inset-0 w-full h-[60vh] bg-cover bg-center bg-no-repeat opacity-20"
        :style="`background-image: url(https://image.tmdb.org/t/p/original${tvShow.backdrop_path})`"
      />
      
      <!-- Content -->
      <div class="relative z-10 container mx-auto px-4 py-8">
        <div class="flex flex-col lg:flex-row gap-8 mb-8">
          <!-- Poster -->
          <div class="flex-shrink-0">
            <AppImage
              v-if="tvShow.poster_path"
              :src="`https://image.tmdb.org/t/p/w500${tvShow.poster_path}`"
              :alt="tvShow.name"
              class="w-80 h-auto rounded-lg shadow-lg"
            />
            <div v-else class="w-80 h-[450px] bg-gray-800 rounded-lg flex items-center justify-center">
              <span class="text-gray-400">No Poster Available</span>
            </div>
          </div>

          <!-- TV Show Info -->
          <div class="flex-1">
            <div class="flex items-start justify-between mb-4">
              <div>
                <h1 class="text-4xl font-bold mb-2">{{ tvShow.name }}</h1>
                <p v-if="tvShow.tagline" class="text-xl text-gray-300 italic mb-4">{{ tvShow.tagline }}</p>
                <div class="flex items-center gap-4 mb-4">
                  <span class="text-sm text-gray-400">{{ formatDate(tvShow.first_air_date) }}</span>
                  <span v-if="tvShow.number_of_seasons" class="text-sm text-gray-400">
                    {{ tvShow.number_of_seasons }} Season{{ tvShow.number_of_seasons > 1 ? 's' : '' }}
                  </span>
                  <span v-if="tvShow.number_of_episodes" class="text-sm text-gray-400">
                    {{ tvShow.number_of_episodes }} Episodes
                  </span>
                  <div class="flex gap-2">
                    <span 
                      v-for="genre in tvShow.genres" 
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
                class="flex items-center gap-2 bg-gray-800 hover:bg-gray-700 px-4 py-2 rounded-lg transition-colors"
                :class="{ 'bg-red-600 hover:bg-red-700': isFavorite(tvShow.id) }"
                @click="toggleFavorite"
              >
                <Icon 
                  :name="isFavorite(tvShow.id) ? 'mdi:heart' : 'mdi:heart-outline'" 
                  class="w-5 h-5" 
                />
                {{ isFavorite(tvShow.id) ? 'Remove from Favorites' : 'Add to Favorites' }}
              </button>
            </div>

            <!-- User Score -->
            <div class="flex items-center gap-4 mb-6">
              <div class="flex items-center">
                <AppRating :rating="tvShow.vote_average" size="large" />
                <span class="ml-2 text-lg font-semibold">{{ Math.round(tvShow.vote_average * 10) }}%</span>
                <span class="ml-1 text-sm text-gray-400">User Score</span>
              </div>
              <span class="text-sm text-gray-400">({{ tvShow.vote_count.toLocaleString() }} votes)</span>
            </div>

            <!-- Overview -->
            <div class="mb-6">
              <h3 class="text-xl font-semibold mb-3">Overview</h3>
              <p class="text-gray-300 leading-relaxed">{{ tvShow.overview }}</p>
            </div>

            <!-- Additional Info -->
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
              <div>
                <h4 class="font-semibold mb-2">Status</h4>
                <p class="text-gray-300">{{ tvShow.status }}</p>
              </div>
              <div>
                <h4 class="font-semibold mb-2">Original Language</h4>
                <p class="text-gray-300">{{ tvShow.original_language.toUpperCase() }}</p>
              </div>
              <div v-if="tvShow.type">
                <h4 class="font-semibold mb-2">Type</h4>
                <p class="text-gray-300">{{ tvShow.type }}</p>
              </div>
              <div v-if="tvShow.last_air_date">
                <h4 class="font-semibold mb-2">Last Air Date</h4>
                <p class="text-gray-300">{{ formatDate(tvShow.last_air_date) }}</p>
              </div>
            </div>

            <!-- Created By -->
            <div v-if="tvShow.created_by?.length > 0" class="mb-6">
              <h4 class="font-semibold mb-2">Created By</h4>
              <div class="flex flex-wrap gap-2">
                <span 
                  v-for="creator in tvShow.created_by" 
                  :key="creator.id"
                  class="bg-gray-700 px-3 py-1 rounded text-sm"
                >
                  {{ creator.name }}
                </span>
              </div>
            </div>
          </div>
        </div>

        <!-- Cast -->
        <div v-if="tvShow.credits?.cast?.length > 0" class="mb-16">
          <h3 class="text-2xl font-semibold mb-6">Cast</h3>
          <div class="relative">
            <div class="flex overflow-x-auto scrollbar-hide gap-4 pb-4" style="scroll-behavior: smooth;">
              <div 
                v-for="actor in tvShow.credits.cast.slice(0, 20)" 
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
        <div v-if="tvShow.videos?.length > 0" class="mb-8">
          <h3 class="text-2xl font-semibold mb-4">Videos</h3>
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            <div 
              v-for="video in tvShow.videos.filter(v => v.site === 'YouTube').slice(0, 6)" 
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

        <!-- Networks -->
        <div v-if="tvShow.networks?.length > 0" class="mb-8">
          <h3 class="text-2xl font-semibold mb-4">Networks</h3>
          <div class="flex flex-wrap gap-4">
            <div 
              v-for="network in tvShow.networks" 
              :key="network.id"
              class="flex items-center gap-2 bg-gray-800 px-4 py-2 rounded-lg"
            >
              <AppImage
                v-if="network.logo_path"
                :src="`https://image.tmdb.org/t/p/w92${network.logo_path}`"
                :alt="network.name"
                class="w-8 h-8 object-contain"
              />
              <span class="text-sm">{{ network.name }}</span>
            </div>
          </div>
        </div>

        <!-- Production Companies -->
        <div v-if="tvShow.production_companies?.length > 0" class="mb-8">
          <h3 class="text-2xl font-semibold mb-4">Production Companies</h3>
          <div class="flex flex-wrap gap-4">
            <div 
              v-for="company in tvShow.production_companies" 
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

interface TVShowDetails {
  id: number
  name: string
  overview: string
  poster_path: string | null
  backdrop_path: string | null
  first_air_date: string
  last_air_date: string
  vote_average: number
  vote_count: number
  number_of_episodes: number
  number_of_seasons: number
  genres: { id: number; name: string }[]
  production_companies: { id: number; name: string; logo_path: string | null }[]
  created_by: { id: number; name: string; profile_path: string | null }[]
  networks: { id: number; name: string; logo_path: string | null }[]
  tagline: string
  status: string
  original_language: string
  original_name: string
  popularity: number
  adult: boolean
  type: string
  credits: {
    cast: {
      id: number
      name: string
      character: string
      profile_path: string | null
      order: number
    }[]
    crew: {
      id: number
      name: string
      job: string
      department: string
      profile_path: string | null
    }[]
  }
  videos: {
    id: string
    key: string
    name: string
    site: string
    type: string
    official: boolean
  }[]
}

const route = useRoute()
const tvShowId = route.params.id as string

// Fetch TV show data
const { data: tvShow, pending, error } = await useFetch<TVShowDetails>(`/api/tv/details/${tvShowId}`, {
  key: `tv-show-${tvShowId}`
})

// Set up SEO
useHead({
  title: computed(() => tvShow.value ? `${tvShow.value.name} - TV Database` : 'TV Database'),
  meta: [
    {
      name: 'description',
      content: computed(() => tvShow.value?.overview || 'TV show details and information')
    },
    {
      property: 'og:title',
      content: computed(() => tvShow.value?.name || 'TV Database')
    },
    {
      property: 'og:description',
      content: computed(() => tvShow.value?.overview || 'TV show details and information')
    },
    {
      property: 'og:image',
      content: computed(() => tvShow.value?.poster_path 
        ? `https://image.tmdb.org/t/p/w500${tvShow.value.poster_path}` 
        : ''
      )
    }
  ]
})

// Favorites functionality
const { isFavorite, toggleFavorite: toggleFav } = useFavoritesStore()

const toggleFavorite = () => {
  if (tvShow.value) {
    toggleFav(tvShow.value.id)
  }
}

// Utility functions
const formatDate = (dateString: string) => {
  if (!dateString) return 'Unknown'
  return new Date(dateString).toLocaleDateString('en-US', { 
    year: 'numeric', 
    month: 'long', 
    day: 'numeric' 
  })
}
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
