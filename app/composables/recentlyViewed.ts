interface RecentlyViewedItem {
  id: number;
  title: string;
  poster_path: string | null;
  type: 'movie' | 'tv';
  viewedAt: number; // timestamp
}

// Shared state - singleton pattern
const recentlyViewed = ref<RecentlyViewedItem[]>([]);
const maxItems = 50; // Keep last 50 viewed items

// Load from localStorage on client side (only once)
if (import.meta.client) {
  const saved = localStorage.getItem("recentlyViewed");
  if (saved) {
    try {
      recentlyViewed.value = JSON.parse(saved);
    } catch (e) {
      console.error('Failed to parse recentlyViewed from localStorage:', e);
      recentlyViewed.value = [];
    }
  }
}

// Watch for changes and save to localStorage
watch(
  recentlyViewed,
  (newViewed) => {
    if (import.meta.client) {
      localStorage.setItem("recentlyViewed", JSON.stringify(newViewed));
    }
  },
  { deep: true }
);

export const useRecentlyViewedStore = () => {
  const addToRecentlyViewed = (item: Omit<RecentlyViewedItem, 'viewedAt'>) => {
    // Remove if already exists
    const existingIndex = recentlyViewed.value.findIndex(
      (v) => v.id === item.id && v.type === item.type
    );
    
    if (existingIndex !== -1) {
      recentlyViewed.value.splice(existingIndex, 1);
    }

    // Add to beginning
    recentlyViewed.value.unshift({
      ...item,
      viewedAt: Date.now(),
    });

    // Keep only last maxItems
    if (recentlyViewed.value.length > maxItems) {
      recentlyViewed.value = recentlyViewed.value.slice(0, maxItems);
    }
  };

  const getRecentlyViewed = computed(() => recentlyViewed.value);

  const clearRecentlyViewed = () => {
    recentlyViewed.value = [];
  };

  const removeFromRecentlyViewed = (id: number, type: 'movie' | 'tv') => {
    const index = recentlyViewed.value.findIndex(
      (v) => v.id === id && v.type === type
    );
    if (index !== -1) {
      recentlyViewed.value.splice(index, 1);
    }
  };

  return {
    recentlyViewed,
    getRecentlyViewed,
    addToRecentlyViewed,
    clearRecentlyViewed,
    removeFromRecentlyViewed,
  };
};

