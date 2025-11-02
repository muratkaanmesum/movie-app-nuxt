<script setup lang="ts">
import { useWatchlistStore } from '~/composables/watchlist';

interface Props {
  itemId: number;
  size?: 'sm' | 'md' | 'lg';
}

const props = withDefaults(defineProps<Props>(), {
  size: 'md',
});

const { isInWatchlist, toggleWatchlist } = useWatchlistStore();

const sizeClasses = {
  sm: 'w-5 h-5',
  md: 'w-6 h-6',
  lg: 'w-8 h-8',
};

const handleClick = () => {
  toggleWatchlist(props.itemId);
};
</script>

<template>
  <button
    :class="[
      'transition-all duration-200 hover:scale-110',
      sizeClasses[size]
    ]"
    :title="isInWatchlist(itemId) ? 'Remove from watchlist' : 'Add to watchlist'"
    @click="handleClick"
  >
    <Icon
      :name="isInWatchlist(itemId) ? 'mdi:bookmark-check' : 'mdi:bookmark-outline'"
      :class="[
        'w-full h-full',
        isInWatchlist(itemId) ? 'text-blue-500' : 'text-gray-400 hover:text-blue-400'
      ]"
    />
  </button>
</template>

