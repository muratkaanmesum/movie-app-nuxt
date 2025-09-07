<script setup lang="ts">
import { ref, watch } from "vue";
import AppMovie from "~/components/Movies/AppMovie.vue";
import AppLoader from "~/components/common/AppLoader.vue";

interface Movie {
  adult: boolean;
  backdrop_path: string;
  genre_ids: number[];
  id: number;
  original_language: string;
  original_title: string;
  overview: string;
  popularity: number;
  poster_path: string;
  release_date: string;
  title: string;
  video: boolean;
  vote_average: number;
  vote_count: number;
}

interface MovieResponse {
  results: Movie[];
  page: number;
  total_pages: number;
  total_results: number;
}

const movies = ref<Movie[]>([]);
const loading = ref(false);
const currentPage = ref(1);
const totalPages = ref(500);

const sortBy = ref("vote_average.desc");
const selectedGenres = ref<number[]>([]);
const minRating = ref(7.0);
const minYear = ref(1900);
const maxYear = ref(new Date().getFullYear());

const sortOptions = [
  { value: "vote_average.desc", label: "Rating Descending" },
  { value: "vote_average.asc", label: "Rating Ascending" },
  { value: "popularity.desc", label: "Popularity Descending" },
  { value: "popularity.asc", label: "Popularity Ascending" },
  { value: "release_date.desc", label: "Release Date Descending" },
  { value: "release_date.asc", label: "Release Date Ascending" },
  { value: "original_title.asc", label: "Title (A-Z)" },
  { value: "original_title.desc", label: "Title (Z-A)" },
];

const genres = [
  { id: 28, name: "Action" },
  { id: 12, name: "Adventure" },
  { id: 16, name: "Animation" },
  { id: 35, name: "Comedy" },
  { id: 80, name: "Crime" },
  { id: 99, name: "Documentary" },
  { id: 18, name: "Drama" },
  { id: 10751, name: "Family" },
  { id: 14, name: "Fantasy" },
  { id: 36, name: "History" },
  { id: 27, name: "Horror" },
  { id: 10402, name: "Music" },
  { id: 9648, name: "Mystery" },
  { id: 10749, name: "Romance" },
  { id: 878, name: "Science Fiction" },
  { id: 10770, name: "TV Movie" },
  { id: 53, name: "Thriller" },
  { id: 10752, name: "War" },
  { id: 37, name: "Western" },
];

const fetchMovies = async () => {
  loading.value = true;

  try {
    const response = await $fetch<MovieResponse>("/api/movies/top_rated", {
      params: {
        page: currentPage.value,
      },
    });

    let filteredMovies = response.results;

    if (selectedGenres.value.length > 0) {
      filteredMovies = filteredMovies.filter((movie) =>
        selectedGenres.value.some((genreId) =>
          movie.genre_ids.includes(genreId)
        )
      );
    }

    if (minRating.value > 0) {
      filteredMovies = filteredMovies.filter(
        (movie) => movie.vote_average >= minRating.value
      );
    }

    if (minYear.value > 1900 || maxYear.value < new Date().getFullYear()) {
      filteredMovies = filteredMovies.filter((movie) => {
        const year = new Date(movie.release_date).getFullYear();
        return year >= minYear.value && year <= maxYear.value;
      });
    }

    if (sortBy.value !== "vote_average.desc") {
      filteredMovies.sort((a, b) => {
        switch (sortBy.value) {
          case "vote_average.asc":
            return a.vote_average - b.vote_average;
          case "popularity.desc":
            return b.popularity - a.popularity;
          case "popularity.asc":
            return a.popularity - b.popularity;
          case "release_date.desc":
            return (
              new Date(b.release_date).getTime() -
              new Date(a.release_date).getTime()
            );
          case "release_date.asc":
            return (
              new Date(a.release_date).getTime() -
              new Date(b.release_date).getTime()
            );
          case "original_title.asc":
            return a.original_title.localeCompare(b.original_title);
          case "original_title.desc":
            return b.original_title.localeCompare(a.original_title);
          default:
            return 0;
        }
      });
    }

    movies.value = filteredMovies;
    totalPages.value = Math.min(response.total_pages, 500);
  } catch (error) {
    console.error("Error fetching movies:", error);
    movies.value = [];
  } finally {
    loading.value = false;
  }
};

watch(
  [sortBy, selectedGenres, minRating, minYear, maxYear],
  () => {
    currentPage.value = 1;
    fetchMovies();
  },
  { deep: true }
);

watch(currentPage, () => {
  fetchMovies();
});

onMounted(() => {
  fetchMovies();
});

const applyFilters = () => {
  currentPage.value = 1;
  fetchMovies();
};

const clearFilters = () => {
  sortBy.value = "vote_average.desc";
  selectedGenres.value = [];
  minRating.value = 7.0;
  minYear.value = 1900;
  maxYear.value = new Date().getFullYear();
  currentPage.value = 1;
};
</script>

<template>
  <div class="main-background min-h-screen text-white">
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-4xl font-bold mb-8">Top Rated Movies</h1>

      <div class="flex gap-8">
        <div class="w-72 flex-shrink-0">
          <div class="bg-gray-800 rounded-lg p-4 mb-6">
            <h3 class="text-lg font-semibold mb-4">Sort Results By</h3>
            <select
              v-model="sortBy"
              class="w-full bg-gray-700 border border-gray-600 rounded px-3 py-2 text-white focus:outline-none focus:border-blue-500"
              @change="applyFilters"
            >
              <option
                v-for="option in sortOptions"
                :key="option.value"
                :value="option.value"
              >
                {{ option.label }}
              </option>
            </select>
          </div>

          <div class="bg-gray-800 rounded-lg p-4 mb-6">
            <div class="flex items-center justify-between mb-4">
              <h3 class="text-lg font-semibold">Filters</h3>
              <button
                class="text-blue-400 hover:text-blue-300 text-sm"
                @click="clearFilters"
              >
                Clear
              </button>
            </div>

            <div class="mb-6">
              <h4 class="font-medium mb-3">Genres</h4>
              <div class="max-h-48 overflow-y-auto">
                <label
                  v-for="genre in genres"
                  :key="genre.id"
                  class="flex items-center mb-2 cursor-pointer hover:bg-gray-700 rounded px-2 py-1"
                >
                  <input
                    v-model="selectedGenres"
                    type="checkbox"
                    :value="genre.id"
                    class="mr-2 accent-blue-500"
                  />
                  <span class="text-sm">{{ genre.name }}</span>
                </label>
              </div>
            </div>

            <div class="mb-6">
              <h4 class="font-medium mb-3">User Rating</h4>
              <div class="flex items-center gap-2">
                <input
                  v-model="minRating"
                  type="range"
                  min="0"
                  max="10"
                  step="0.5"
                  class="flex-1 accent-blue-500"
                />
                <span class="text-sm">{{ minRating }}+</span>
              </div>
            </div>

            <div class="mb-6">
              <h4 class="font-medium mb-3">Release Year</h4>
              <div class="flex gap-2">
                <input
                  v-model="minYear"
                  type="number"
                  :min="1900"
                  :max="maxYear"
                  class="w-20 bg-gray-700 border border-gray-600 rounded px-2 py-1 text-sm"
                  placeholder="From"
                />
                <span class="text-gray-400 self-center">to</span>
                <input
                  v-model="maxYear"
                  type="number"
                  :min="minYear"
                  :max="new Date().getFullYear()"
                  class="w-20 bg-gray-700 border border-gray-600 rounded px-2 py-1 text-sm"
                  placeholder="To"
                />
              </div>
            </div>

            <button
              class="w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded transition-colors"
              @click="applyFilters"
            >
              Apply Filters
            </button>
          </div>

          <div class="bg-gray-800 rounded-lg p-4">
            <h3 class="text-lg font-semibold mb-4">Where To Watch</h3>
            <p class="text-gray-400 text-sm">
              Coming soon - streaming service filters
            </p>
          </div>
        </div>

        <div class="flex-1">
          <AppLoader :state="loading" :color="'white'" />

          <div v-show="!loading">
            <div
              class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-6 mb-8"
            >
              <AppMovie
                v-for="movie in movies"
                :id="movie.id"
                :key="movie.id"
                :name="movie.original_title"
                :date="movie.release_date"
                :image-url="`https://image.tmdb.org/t/p/w220_and_h330_face/${movie.poster_path}`"
                :rating="Math.ceil(movie.vote_average * 10)"
                class="mx-auto"
              />
            </div>

            <div class="flex justify-center items-center gap-4 mt-8">
              <button
                :disabled="currentPage <= 1 || loading"
                class="flex items-center gap-2 bg-gray-700 hover:bg-gray-600 disabled:opacity-50 disabled:cursor-not-allowed px-4 py-2 rounded transition-colors"
                @click="currentPage > 1 && (currentPage = currentPage - 1)"
              >
                <svg
                  class="w-4 h-4"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M15 19l-7-7 7-7"
                  />
                </svg>
                Previous
              </button>

              <span class="text-gray-300 px-4">
                Page {{ currentPage }} of {{ totalPages }}
              </span>

              <button
                :disabled="currentPage >= totalPages || loading"
                class="flex items-center gap-2 bg-gray-700 hover:bg-gray-600 disabled:opacity-50 disabled:cursor-not-allowed px-4 py-2 rounded transition-colors"
                @click="
                  currentPage < totalPages && (currentPage = currentPage + 1)
                "
              >
                Next
                <svg
                  class="w-4 h-4"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M9 5l7 7-7 7"
                  />
                </svg>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
