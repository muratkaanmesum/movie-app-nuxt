// Shared state - singleton pattern
const favoriteIds = ref<number[]>([]);

// Load from localStorage on client side (only once)
if (import.meta.client) {
  const saved = localStorage.getItem("favorites");
  if (saved) {
    try {
      favoriteIds.value = JSON.parse(saved);
    } catch (e) {
      console.error('Failed to parse favorites from localStorage:', e);
      favoriteIds.value = [];
    }
  }
}

// Watch for changes and save to localStorage
watch(
  favoriteIds,
  (newFavorites) => {
    if (import.meta.client) {
      localStorage.setItem("favorites", JSON.stringify(newFavorites));
    }
  },
  { deep: true }
);

export const useFavoritesStore = () => {
  const getFavorites = computed(() => favoriteIds.value);

  const isFavorite = (movieId: number): boolean => {
    return favoriteIds.value.includes(movieId);
  };

  const toggleFavorite = (movieId: number) => {
    const index = favoriteIds.value.indexOf(movieId);
    if (index === -1) {
      favoriteIds.value.push(movieId);
    } else {
      favoriteIds.value.splice(index, 1);
    }
  };

  const addFavorite = (movieId: number) => {
    if (!favoriteIds.value.includes(movieId)) {
      favoriteIds.value.push(movieId);
    }
  };

  const removeFavorite = (movieId: number) => {
    const index = favoriteIds.value.indexOf(movieId);
    if (index !== -1) {
      favoriteIds.value.splice(index, 1);
    }
  };

  return {
    favoriteIds,
    getFavorites,
    isFavorite,
    toggleFavorite,
    addFavorite,
    removeFavorite,
  };
};
