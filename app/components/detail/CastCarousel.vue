<template>
  <div v-if="cast?.length > 0" class="mb-16">
    <h3 class="text-2xl font-semibold mb-6">Cast</h3>
    <div class="relative">
      <div
        ref="scrollContainer"
        class="flex overflow-x-auto scrollbar-hide gap-4 pb-16"
        style="scroll-behavior: smooth"
      >
        <div
          v-for="actor in cast.slice(0, 20)"
          :key="actor.id"
          class="flex-shrink-0 text-center w-32"
        >
          <AppImage
            v-if="actor.profile_path"
            :src="`https://image.tmdb.org/t/p/w185${actor.profile_path}`"
            :alt="actor.name"
            class="w-32 h-40 object-cover rounded-lg mb-3 shadow-lg hover:shadow-xl transition-shadow duration-300"
          />
          <div
            v-else
            class="w-32 h-40 bg-gray-800 rounded-lg mb-3 flex items-center justify-center shadow-lg hover:shadow-xl transition-shadow duration-300"
          >
            <Icon name="mdi:account" class="w-8 h-8 text-gray-400" />
          </div>
          <div class="h-12 flex flex-col justify-start">
            <h4
              class="font-semibold text-sm mb-1 text-white line-clamp-1"
              :title="actor.name"
            >
              {{ actor.name }}
            </h4>
            <p
              class="text-xs text-gray-400 line-clamp-1"
              :title="actor.character"
            >
              {{ actor.character }}
            </p>
          </div>
        </div>
      </div>

      <button
        v-show="canScrollLeft"
        class="absolute left-2 top-20 -translate-y-1/2 bg-black/70 hover:bg-black/90 text-white p-2 rounded-full shadow-lg transition-all duration-200 z-10"
        @click="scrollLeft"
      >
        <Icon name="mdi:chevron-left" class="w-6 h-6" />
      </button>

      <button
        v-show="canScrollRight"
        class="absolute right-2 top-20 -translate-y-1/2 bg-black/70 hover:bg-black/90 text-white p-2 rounded-full shadow-lg transition-all duration-200 z-10"
        @click="scrollRight"
      >
        <Icon name="mdi:chevron-right" class="w-6 h-6" />
      </button>

      <div
        class="absolute right-0 top-0 bottom-16 w-12 bg-gradient-to-l from-slate-900 to-transparent pointer-events-none"
      />
      <div
        class="absolute left-0 top-0 bottom-16 w-4 bg-gradient-to-r from-slate-900 to-transparent pointer-events-none"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
interface CastMember {
  id: number;
  name: string;
  character: string;
  profile_path: string | null;
}

interface Props {
  cast: CastMember[];
}

defineProps<Props>();

const scrollContainer = ref<HTMLElement | null>(null);
const canScrollLeft = ref(false);
const canScrollRight = ref(false);

const updateScrollButtons = () => {
  if (scrollContainer.value) {
    const container = scrollContainer.value;
    canScrollLeft.value = container.scrollLeft > 0;
    canScrollRight.value =
      container.scrollLeft < container.scrollWidth - container.clientWidth;
  }
};

const scrollLeft = () => {
  if (scrollContainer.value) {
    scrollContainer.value.scrollBy({ left: -144, behavior: "smooth" });
    setTimeout(updateScrollButtons, 300);
  }
};

const scrollRight = () => {
  if (scrollContainer.value) {
    scrollContainer.value.scrollBy({ left: 144, behavior: "smooth" });
    setTimeout(updateScrollButtons, 300);
  }
};

onMounted(() => {
  nextTick(() => {
    updateScrollButtons();
    if (scrollContainer.value) {
      scrollContainer.value.addEventListener("scroll", updateScrollButtons);
    }
  });
});

onUnmounted(() => {
  if (scrollContainer.value) {
    scrollContainer.value.removeEventListener("scroll", updateScrollButtons);
  }
});
</script>

<style scoped>
.scrollbar-hide {
  -ms-overflow-style: none;
  scrollbar-width: none;
}

.scrollbar-hide::-webkit-scrollbar {
  display: none;
}

.line-clamp-1 {
  display: -webkit-box;
  -webkit-line-clamp: 1;
  line-clamp: 1;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
