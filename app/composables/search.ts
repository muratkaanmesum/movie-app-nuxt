export interface SearchResult {
  id: number;
  title: string;
  type: "movie" | "tv" | "person";
  poster_path?: string | null;
  release_date?: string;
}

interface Movie {
  id: number;
  title: string;
  poster_path: string | null;
  release_date: string;
}

interface SearchResponse {
  page: number;
  results: Movie[];
  total_pages: number;
  total_results: number;
}

export const useSearchStore = () => {
  const searchQuery = ref("");
  const searchResults = ref<SearchResult[]>([]);
  const isLoading = ref(false);
  const showResults = ref(false);

  const searchMovies = async (query: string): Promise<void> => {
    if (!query.trim()) {
      searchResults.value = [];
      showResults.value = false;
      return;
    }

    isLoading.value = true;

    try {
      const config = useRuntimeConfig();

      const response = await $fetch<SearchResponse>(
        "https://api.themoviedb.org/3/search/movie",
        {
          params: {
            query: query,
            include_adult: false,
            language: "en-US",
            page: 1,
            api_key: config.public.tmdbApiKey,
          },
          headers: {
            accept: "application/json",
          },
        }
      );

      searchResults.value = response.results
        .map((movie: Movie) => ({
          id: movie.id,
          title: movie.title,
          type: "movie" as const,
          poster_path: movie.poster_path,
          release_date: movie.release_date,
        }))
        .slice(0, 8);

      showResults.value = searchResults.value.length > 0;
    } catch (error) {
      console.error("Error searching movies:", error);
      searchResults.value = [];
    } finally {
      isLoading.value = false;
    }
  };

  const selectResult = (result: SearchResult) => {
    searchQuery.value = result.title;
    showResults.value = false;
    console.log("Selected result:", result);
  };

  const closeResults = () => {
    setTimeout(() => {
      showResults.value = false;
    }, 150);
  };

  return {
    searchQuery,
    searchResults,
    isLoading,
    showResults,
    searchMovies,
    selectResult,
    closeResults,
  };
};
