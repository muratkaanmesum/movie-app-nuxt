<template>
  <div class="main-background min-h-screen text-white">
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-4xl font-bold mb-8">Search</h1>

      <!-- Search Form -->
      <div class="mb-8">
        <form class="flex gap-4" @submit.prevent="performSearch">
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Search for movies and TV shows..."
            class="flex-1 px-4 py-3 bg-gray-800 border border-gray-700 rounded-lg text-white placeholder-gray-400 focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
            :disabled="pending"
          />
          <button
            type="submit"
            class="px-6 py-3 bg-blue-600 hover:bg-blue-700 rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            :disabled="pending || !searchQuery.trim()"
          >
            <Icon
              v-if="pending"
              name="mdi:loading"
              class="w-5 h-5 animate-spin"
            />
            <Icon v-else name="mdi:magnify" class="w-5 h-5" />
          </button>
        </form>
      </div>

      <!-- Loading State -->
      <div v-if="pending" class="flex justify-center items-center py-16">
        <AppLoader :state="true" />
      </div>

      <!-- Error State -->
      <div v-else-if="error" class="text-center py-16">
        <div class="text-6xl mb-4">⚠️</div>
        <h2 class="text-2xl font-bold mb-4">Search Error</h2>
        <p class="text-gray-400 mb-8">{{ error }}</p>
        <button
          class="bg-blue-600 hover:bg-blue-700 px-6 py-3 rounded-lg transition-colors"
          @click="performSearch"
        >
          Try Again
        </button>
      </div>

      <!-- No Results -->
      <div v-else-if="hasSearched && !hasResults" class="text-center py-16">
        <div class="text-6xl mb-4">🔍</div>
        <h2 class="text-2xl font-bold mb-4">No Results Found</h2>
        <p class="text-gray-400 mb-8">
          No movies or TV shows found for "{{ currentSearchQuery }}". Try
          different keywords.
        </p>
      </div>

      <!-- Search Results -->
      <div v-else-if="searchResults">
        <div class="mb-8">
          <h2 class="text-2xl font-bold mb-4">
            Search Results for "{{ currentSearchQuery }}"
          </h2>
          <p class="text-gray-400">
            Found {{ searchResults.totalMovies }} movies and
            {{ searchResults.totalTVShows }} TV shows
          </p>
        </div>

        <!-- Movies Section -->
        <div v-if="searchResults.movies.length > 0" class="mb-12">
          <h3 class="text-xl font-semibold mb-6 flex items-center gap-2">
            <Icon name="mdi:movie" class="w-6 h-6" />
            Movies ({{ searchResults.totalMovies }})
          </h3>
          <div
            class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-6"
          >
            <AppMovie
              v-for="movie in searchResults.movies.slice(0, 12)"
              :id="movie.id"
              :key="movie.id"
              :name="movie.title"
              :date="movie.release_date"
              :image-url="
                movie.poster_path
                  ? `https://image.tmdb.org/t/p/w220_and_h330_face/${movie.poster_path}`
                  : '/moviePoster.jpg'
              "
              :rating="Math.round(movie.vote_average * 10)"
            />
          </div>
          <div v-if="searchResults.movies.length > 12" class="text-center mt-6">
            <p class="text-gray-400">Showing first 12 results</p>
          </div>
        </div>

        <!-- TV Shows Section -->
        <div v-if="searchResults.tvShows.length > 0" class="mb-12">
          <h3 class="text-xl font-semibold mb-6 flex items-center gap-2">
            <Icon name="mdi:television" class="w-6 h-6" />
            TV Shows ({{ searchResults.totalTVShows }})
          </h3>
          <div
            class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-6"
          >
            <AppTVShow
              v-for="show in searchResults.tvShows.slice(0, 12)"
              :id="show.id"
              :key="show.id"
              :name="show.name"
              :date="show.first_air_date"
              :image-url="
                show.poster_path
                  ? `https://image.tmdb.org/t/p/w220_and_h330_face/${show.poster_path}`
                  : '/moviePoster.jpg'
              "
              :rating="Math.round(show.vote_average * 10)"
            />
          </div>
          <div
            v-if="searchResults.tvShows.length > 12"
            class="text-center mt-6"
          >
            <p class="text-gray-400">Showing first 12 results</p>
          </div>
        </div>
      </div>

      <!-- Initial State -->
      <div v-else class="text-center py-16">
        <div class="text-6xl mb-6">🎬</div>
        <h2 class="text-2xl font-bold mb-4">Discover Movies & TV Shows</h2>
        <p class="text-gray-400 mb-8">
          Search for your favorite movies and TV shows using the search box
          above.
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
    </div>
  </div>
</template>

<script setup lang="ts">
import AppMovie from "~/components/Movies/AppMovie.vue";
import AppTVShow from "~/components/TV/AppTVShow.vue";

interface SearchResults {
  query: string;
  movies: Array<{
    id: number;
    title: string;
    original_title: string;
    overview: string;
    poster_path: string | null;
    backdrop_path: string | null;
    release_date: string;
    vote_average: number;
    vote_count: number;
    genre_ids: number[];
    adult: boolean;
    original_language: string;
    popularity: number;
    video: boolean;
  }>;
  tvShows: Array<{
    id: number;
    name: string;
    original_name: string;
    overview: string;
    poster_path: string | null;
    backdrop_path: string | null;
    first_air_date: string;
    vote_average: number;
    vote_count: number;
    genre_ids: number[];
    adult: boolean;
    original_language: string;
    popularity: number;
    origin_country: string[];
  }>;
  totalMovies: number;
  totalTVShows: number;
}

const route = useRoute();
const router = useRouter();

// Reactive search state
const searchQuery = ref((route.query.q as string) || "");
const currentSearchQuery = ref("");
const hasSearched = ref(false);

// Search functionality
const {
  data: searchResults,
  pending,
  error,
  execute,
} = await useLazyFetch<SearchResults>("/api/search", {
  query: computed(() => ({ q: currentSearchQuery.value })),
  immediate: false,
  server: false,
});

const hasResults = computed(() => {
  return (
    searchResults.value &&
    (searchResults.value.movies.length > 0 ||
      searchResults.value.tvShows.length > 0)
  );
});

const performSearch = async () => {
  if (!searchQuery.value.trim()) return;

  currentSearchQuery.value = searchQuery.value.trim();
  hasSearched.value = true;

  // Update URL
  await router.push({
    path: "/search",
    query: { q: currentSearchQuery.value },
  });

  // Execute search
  await execute();
};

// Perform search on mount if query exists
onMounted(() => {
  if (searchQuery.value) {
    performSearch();
  }
});

// SEO
useHead({
  title: computed(() => {
    if (currentSearchQuery.value) {
      return `Search results for "${currentSearchQuery.value}" - Movie Database`;
    }
    return "Search - Movie Database";
  }),
  meta: [
    {
      name: "description",
      content: computed(() => {
        if (currentSearchQuery.value) {
          return `Search results for "${currentSearchQuery.value}" on Movie Database`;
        }
        return "Search for movies and TV shows on Movie Database";
      }),
    },
  ],
});
</script>

<style scoped>
.main-background {
  background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
}
</style>
