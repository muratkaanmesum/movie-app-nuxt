<template>
  <div class="main-background min-h-screen text-white">
    <div v-if="pending" class="flex justify-center items-center min-h-screen">
      <AppLoader :state="true" />
    </div>
    <div v-else-if="tvShow" class="container mx-auto px-4 py-8">
      <DetailHeader
        :id="tvShow.id"
        :title="tvShow.name"
        :tagline="tvShow.tagline"
        :poster="
          tvShow.poster_path
            ? `https://image.tmdb.org/t/p/w500${tvShow.poster_path}`
            : undefined
        "
        :date="formatDate(tvShow.first_air_date)"
        :runtime="formatTVRuntime(tvShow)"
        :genres="tvShow.genres"
        :rating="calculateRating(tvShow.vote_average)"
        :vote-count="tvShow.vote_count"
        :overview="tvShow.overview"
        :is-favorite="isFavorite(tvShow.id)"
        @toggle-favorite="toggleFavorite"
      >
        <template #watchlist-button>
          <WatchlistButton
            :item-id="tvShow.id"
            @click="toggleWatchlistItem"
          />
        </template>
        <template #additional-info>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
            <div>
              <h4 class="font-semibold mb-2">Status</h4>
              <p class="text-gray-300">{{ tvShow.status }}</p>
            </div>
            <div>
              <h4 class="font-semibold mb-2">Original Language</h4>
              <p class="text-gray-300">
                {{ tvShow.original_language.toUpperCase() }}
              </p>
            </div>
            <div v-if="tvShow.type">
              <h4 class="font-semibold mb-2">Type</h4>
              <p class="text-gray-300">{{ tvShow.type }}</p>
            </div>
            <div v-if="tvShow.last_air_date">
              <h4 class="font-semibold mb-2">Last Air Date</h4>
              <p class="text-gray-300">
                {{ formatDate(tvShow.last_air_date) }}
              </p>
            </div>
          </div>
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
        </template>
      </DetailHeader>
      <!-- Cast Section -->
      <CastCarousel
        v-if="tvShow.credits?.cast?.length > 0"
        :cast="tvShow.credits.cast"
      />
      <!-- Videos Section -->
      <VideoSection v-if="tvShow.videos?.length > 0" :videos="tvShow.videos" />
      <!-- Watch Providers -->
      <WatchProviders 
        v-if="watchProviders?.results?.US"
        :providers="watchProviders.results.US"
        region="US"
      />
      
      <!-- Similar TV Shows -->
      <SimilarContent
        v-if="similarShows?.results && similarShows.results.length > 0"
        :items="similarShows.results"
        type="tv"
        title="Similar TV Shows"
      />
      
      <!-- Networks Section -->
      <CompanySection
        v-if="tvShow.networks?.length > 0"
        :companies="tvShow.networks"
        title="Networks"
      />
      <!-- Production Companies Section -->
      <CompanySection
        v-if="tvShow.production_companies?.length > 0"
        :companies="tvShow.production_companies"
        title="Production Companies"
      />
      <!-- Backdrop Image -->
      <BackdropImage
        v-if="tvShow.backdrop_path"
        :backdrop="tvShow.backdrop_path"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { useFavoritesStore } from "~/composables/favorites";
import { useWatchlistStore } from "~/composables/watchlist";
import { useRecentlyViewedStore } from "~/composables/recentlyViewed";
import { useDetailPage } from "~/composables/useDetailPage";
import SimilarContent from "~/components/detail/SimilarContent.vue";
import WatchProviders from "~/components/detail/WatchProviders.vue";
import WatchlistButton from "~/components/common/WatchlistButton.vue";

const route = useRoute();
const tvShowId = route.params.id as string;

const { formatDate, calculateRating } = useDetailPage();
const { isFavorite, toggleFavorite: toggleFav } = useFavoritesStore();
const { isInWatchlist, toggleWatchlist } = useWatchlistStore();
const { addToRecentlyViewed } = useRecentlyViewedStore();

const { data: tvShow, pending } = await useFetch(
  `/api/tv/details/${tvShowId}`,
  {
    key: `tv-show-${tvShowId}`,
  }
);

// Fetch similar TV shows
const { data: similarShows, pending: similarPending } = await useFetch(
  `/api/tv/similar/${tvShowId}`,
  {
    query: { page: 1 },
    default: () => ({ results: [] }),
  }
);

// Fetch watch providers
const { data: watchProviders, pending: providersPending } = await useFetch(
  `/api/tv/watch-providers/${tvShowId}`,
  {
    default: () => ({ results: {} }),
  }
);

// Track recently viewed
watch(tvShow, (newShow) => {
  if (newShow) {
    addToRecentlyViewed({
      id: newShow.id,
      title: newShow.name,
      poster_path: newShow.poster_path,
      type: 'tv',
    });
  }
}, { immediate: true });

// Also track on mount if tvShow is already loaded
onMounted(() => {
  if (tvShow.value) {
    addToRecentlyViewed({
      id: tvShow.value.id,
      title: tvShow.value.name,
      poster_path: tvShow.value.poster_path,
      type: 'tv',
    });
  }
});

const toggleFavorite = () => {
  if (tvShow.value) {
    toggleFav(tvShow.value.id);
  }
};

const toggleWatchlistItem = () => {
  if (tvShow.value) {
    toggleWatchlist(tvShow.value.id);
  }
};

interface TVShow {
  number_of_seasons?: number;
  number_of_episodes?: number;
}
const formatTVRuntime = (show: TVShow) => {
  if (!show.number_of_seasons && !show.number_of_episodes) return "";
  let result = "";
  if (show.number_of_seasons) {
    result += `${show.number_of_seasons} Season${show.number_of_seasons > 1 ? "s" : ""}`;
  }
  if (show.number_of_episodes) {
    result += (result ? ", " : "") + `${show.number_of_episodes} Episodes`;
  }
  return result;
};

useHead({
  title: computed(() =>
    tvShow.value ? `${tvShow.value.name} - TV Database` : "TV Database"
  ),
  meta: [
    {
      name: "description",
      content: computed(
        () => tvShow.value?.overview || "TV show details and information"
      ),
    },
    {
      property: "og:title",
      content: computed(() => tvShow.value?.name || "TV Database"),
    },
    {
      property: "og:description",
      content: computed(
        () => tvShow.value?.overview || "TV show details and information"
      ),
    },
    {
      property: "og:image",
      content: computed(() =>
        tvShow.value?.poster_path
          ? `https://image.tmdb.org/t/p/w500${tvShow.value.poster_path}`
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

/* Hide scrollbar for webkit browsers */
.scrollbar-hide {
  -ms-overflow-style: none; /* IE and Edge */
  scrollbar-width: none; /* Firefox */
}

.scrollbar-hide::-webkit-scrollbar {
  display: none;
}

/* Line clamp utilities */
.line-clamp-1 {
  display: -webkit-box;
  -webkit-line-clamp: 1;
  line-clamp: 1;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
