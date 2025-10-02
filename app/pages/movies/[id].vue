<template>
  <div class="main-background min-h-screen text-white">
    <div v-if="pending" class="flex justify-center items-center min-h-screen">
      <AppLoader :state="true" />
    </div>

    <div v-else-if="error" class="container mx-auto px-4 py-8">
      <div class="text-center">
        <h1 class="text-2xl font-bold mb-4">Movie Not Found</h1>
        <p class="text-gray-400 mb-4">
          The movie you're looking for doesn't exist.
        </p>
        <NuxtLink
          to="/movies"
          class="bg-blue-600 hover:bg-blue-700 px-6 py-2 rounded-lg transition-colors"
        >
          Back to Movies
        </NuxtLink>
      </div>
    </div>

    <div v-else-if="movie" class="relative">
      <BackdropImage :backdrop="movie.backdrop_path" />

      <div class="relative z-10 container mx-auto px-4 py-8">
        <DetailHeader
          :id="movie.id"
          :title="movie.title"
          :tagline="movie.tagline"
          :poster="
            movie.poster_path
              ? `https://image.tmdb.org/t/p/w500${movie.poster_path}`
              : undefined
          "
          :date="formatDate(movie.release_date)"
          :runtime="formatRuntime(movie.runtime)"
          :genres="movie.genres"
          :rating="calculateRating(movie.vote_average)"
          :vote-count="movie.vote_count"
          :overview="movie.overview"
          :is-favorite="isFavorite(movie.id)"
          @toggle-favorite="toggleFavorite"
        >
          <template #additional-info>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
              <div>
                <h4 class="font-semibold mb-2">Status</h4>
                <p class="text-gray-300">{{ movie.status }}</p>
              </div>
              <div>
                <h4 class="font-semibold mb-2">Original Language</h4>
                <p class="text-gray-300">
                  {{ movie.original_language.toUpperCase() }}
                </p>
              </div>
              <div v-if="movie.budget > 0">
                <h4 class="font-semibold mb-2">Budget</h4>
                <p class="text-gray-300">
                  ${{ movie.budget.toLocaleString() }}
                </p>
              </div>
              <div v-if="movie.revenue > 0">
                <h4 class="font-semibold mb-2">Revenue</h4>
                <p class="text-gray-300">
                  ${{ movie.revenue.toLocaleString() }}
                </p>
              </div>
            </div>
          </template>
        </DetailHeader>

        <CastCarousel :cast="movie.credits?.cast || []" />
        <VideoSection :videos="movie.videos || []" />
        <CompanySection
          :companies="movie.production_companies || []"
          title="Production Companies"
        />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useFavoritesStore } from "~/composables/favorites";
import { useMovieDetails } from "~/composables/movieDetails";
import { useDetailPage } from "~/composables/useDetailPage";

const route = useRoute();
const movieId = computed(() => route.params.id as string);

const { movie, pending, error } = useMovieDetails(movieId.value);
const { formatDate, formatRuntime, calculateRating } = useDetailPage();
const { isFavorite, toggleFavorite: toggleFav } = useFavoritesStore();

const toggleFavorite = () => {
  if (movie.value) {
    toggleFav(movie.value.id);
  }
};

useHead({
  title: computed(() =>
    movie.value ? `${movie.value.title} - Movie Database` : "Movie Database"
  ),
  meta: [
    {
      name: "description",
      content: computed(
        () => movie.value?.overview || "Movie details and information"
      ),
    },
    {
      property: "og:title",
      content: computed(() => movie.value?.title || "Movie Database"),
    },
    {
      property: "og:description",
      content: computed(
        () => movie.value?.overview || "Movie details and information"
      ),
    },
    {
      property: "og:image",
      content: computed(() =>
        movie.value?.poster_path
          ? `https://image.tmdb.org/t/p/w500${movie.value.poster_path}`
          : ""
      ),
    },
  ],
});
</script>

<style scoped>
.main-background {
  background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
}
</style>
