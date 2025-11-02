export const useWatchlistStore = () => {
  const watchlistIds = ref<number[]>([]);

  // Load from localStorage on client side
  if (import.meta.client) {
    const saved = localStorage.getItem("watchlist");
    if (saved) {
      watchlistIds.value = JSON.parse(saved);
    }
  }

  // Watch for changes and save to localStorage
  watch(
    watchlistIds,
    (newWatchlist) => {
      if (import.meta.client) {
        localStorage.setItem("watchlist", JSON.stringify(newWatchlist));
      }
    },
    { deep: true }
  );

  const getWatchlist = computed(() => watchlistIds.value);

  const isInWatchlist = (itemId: number): boolean => {
    return watchlistIds.value.includes(itemId);
  };

  const toggleWatchlist = (itemId: number) => {
    const index = watchlistIds.value.indexOf(itemId);
    if (index === -1) {
      watchlistIds.value.push(itemId);
    } else {
      watchlistIds.value.splice(index, 1);
    }
  };

  const addToWatchlist = (itemId: number) => {
    if (!watchlistIds.value.includes(itemId)) {
      watchlistIds.value.push(itemId);
    }
  };

  const removeFromWatchlist = (itemId: number) => {
    const index = watchlistIds.value.indexOf(itemId);
    if (index !== -1) {
      watchlistIds.value.splice(index, 1);
    }
  };

  const clearWatchlist = () => {
    watchlistIds.value = [];
  };

  return {
    watchlistIds,
    getWatchlist,
    isInWatchlist,
    toggleWatchlist,
    addToWatchlist,
    removeFromWatchlist,
    clearWatchlist,
  };
};

