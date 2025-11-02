<script setup lang="ts">
interface Movie {
  id: number;
  title: string;
  poster_path: string | null;
  release_date: string;
  vote_average: number;
}

interface TVShow {
  id: number;
  name: string;
  poster_path: string | null;
  first_air_date: string;
  vote_average: number;
}

interface Props {
  items: (Movie | TVShow)[];
  type: 'movie' | 'tv';
  title?: string;
}

const props = withDefaults(defineProps<Props>(), {
  title: 'Similar Content',
});

const formatDate = (date: string) => {
  if (!date) return '';
  return new Date(date).getFullYear().toString();
};

const getRoute = (item: Movie | TVShow) => {
  return props.type === 'movie'
    ? `/movies/${item.id}`
    : `/tv/${item.id}`;
};

const getTitle = (item: Movie | TVShow) => {
  return 'title' in item ? item.title : item.name;
};
</script>

<template>
  <div v-if="items.length > 0" class="my-8">
    <h2 class="text-2xl font-bold mb-6">{{ title }}</h2>
    <div
      class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-4"
    >
      <NuxtLink
        v-for="item in items.slice(0, 12)"
        :key="item.id"
        :to="getRoute(item)"
        class="group hover:scale-105 transition-transform duration-200"
      >
        <div class="relative aspect-[2/3] rounded-lg overflow-hidden bg-gray-800">
          <img
            v-if="item.poster_path"
            :src="`https://image.tmdb.org/t/p/w500${item.poster_path}`"
            :alt="getTitle(item)"
            class="w-full h-full object-cover group-hover:opacity-75 transition-opacity"
            loading="lazy"
          />
          <div
            v-else
            class="w-full h-full flex items-center justify-center text-gray-500"
          >
            <Icon name="mdi:image-off" class="w-12 h-12" />
          </div>
          
          <div
            class="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/80 to-transparent p-3 opacity-0 group-hover:opacity-100 transition-opacity"
          >
            <p class="text-white font-semibold text-sm line-clamp-2">
              {{ getTitle(item) }}
            </p>
            <p class="text-gray-300 text-xs mt-1">
              {{ formatDate('release_date' in item ? item.release_date : item.first_air_date) }}
            </p>
          </div>
        </div>
      </NuxtLink>
    </div>
  </div>
</template>

