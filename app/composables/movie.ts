interface Movie {
  adult: boolean;
  backdrop_path: string;
  genre_ids: number[];
  id: number;
  original_language: string;
  original_title: string;
  overview: string;
  popularity: number;
  poster_path: string;
  release_date: string;
  title: string;
  video: boolean;
  vote_average: number;
  vote_count: number;
}

interface MovieResponse {
  results: Movie[];
  page: number;
  total_pages: number;
  total_results: number;
}

export const useMovieStore = () => {
  const movies = ref<Movie[]>([]);
  const page = ref(1);
  const loading = ref(true);
  const type = ref<"popular" | "top_rated">("popular");

  const getMovies = computed(() => movies.value);
  const getPage = computed(() => page.value);
  const getLoading = computed(() => loading.value);
  const getType = computed(() => type.value);

  const setMovies = (data: Movie[]) => {
    movies.value = data;
  };

  const fetchMovies = async () => {
    loading.value = true;
    try {
      // Use our server API route for better SSR support
      const { data } = await useFetch<MovieResponse>(
        `/api/movies/${type.value}`,
        {
          params: {
            page: page.value,
          },
          // Add key for proper caching and SSR
          key: `movies-${type.value}-${page.value}`,
          // Server-side caching
          server: true,
        }
      );

      if (data.value) {
        setMovies(data.value.results);
      }
    } catch (error) {
      console.error(error);
    }
    loading.value = false;
  };

  const incrementPage = () => {
    if (page.value >= 20) {
      page.value = 1;
    } else {
      page.value++;
    }
  };

  const decrementPage = () => {
    if (page.value <= 1) {
      page.value = 20;
    } else {
      page.value--;
    }
  };

  const setType = (newType: "popular" | "top_rated") => {
    if (type.value === newType) {
      return;
    }
    type.value = newType;
  };

  return {
    movies,
    page,
    loading,
    type,
    getMovies,
    getPage,
    getLoading,
    getType,
    setMovies,
    fetchMovies,
    incrementPage,
    decrementPage,
    setType,
  };
};
