<template>
  <div v-if="videos?.length > 0" class="mb-8">
    <h3 class="text-2xl font-semibold mb-4">Videos</h3>
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      <div
        v-for="video in youtubeVideos"
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
</template>

<script setup lang="ts">
interface Video {
  id: string;
  key: string;
  name: string;
  site: string;
  type: string;
  official: boolean;
}

interface Props {
  videos: Video[];
}

const props = defineProps<Props>();

const youtubeVideos = computed(() =>
  props.videos.filter((v) => v.site === "YouTube").slice(0, 6)
);
</script>
