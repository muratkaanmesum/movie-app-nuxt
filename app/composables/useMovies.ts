import { ref, watch } from "vue";

export interface Movie {
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

export interface MovieResponse {
  results: Movie[];
  page: number;
  total_pages: number;
  total_results: number;
}

export interface Genre {
  id: number;
  name: string;
}

export interface SortOption {
  value: string;
  label: string;
}

export const useMovies = (
  apiEndpoint: string,
  defaultSort: string = "popularity.desc",
  defaultMinRating: number = 0
) => {
  const movies = ref<Movie[]>([]);
  const loading = ref(false);
  const currentPage = ref(1);
  const totalPages = ref(500);

  const sortBy = ref(defaultSort);
  const selectedGenres = ref<number[]>([]);
  const minRating = ref(defaultMinRating);
  const minYear = ref(1900);
  const maxYear = ref(new Date().getFullYear());

  const genres: Genre[] = [
    { id: 28, name: "Action" },
    { id: 12, name: "Adventure" },
    { id: 16, name: "Animation" },
    { id: 35, name: "Comedy" },
    { id: 80, name: "Crime" },
    { id: 99, name: "Documentary" },
    { id: 18, name: "Drama" },
    { id: 10751, name: "Family" },
    { id: 14, name: "Fantasy" },
    { id: 36, name: "History" },
    { id: 27, name: "Horror" },
    { id: 10402, name: "Music" },
    { id: 9648, name: "Mystery" },
    { id: 10749, name: "Romance" },
    { id: 878, name: "Science Fiction" },
    { id: 10770, name: "TV Movie" },
    { id: 53, name: "Thriller" },
    { id: 10752, name: "War" },
    { id: 37, name: "Western" },
  ];

  const sortMovies = (movies: Movie[], sortValue: string): Movie[] => {
    const sorted = [...movies];
    sorted.sort((a, b) => {
      switch (sortValue) {
        case "popularity.desc":
          return b.popularity - a.popularity;
        case "popularity.asc":
          return a.popularity - b.popularity;
        case "vote_average.desc":
          return b.vote_average - a.vote_average;
        case "vote_average.asc":
          return a.vote_average - b.vote_average;
        case "release_date.desc":
          return new Date(b.release_date).getTime() - new Date(a.release_date).getTime();
        case "release_date.asc":
          return new Date(a.release_date).getTime() - new Date(b.release_date).getTime();
        case "original_title.asc":
          return a.original_title.localeCompare(b.original_title);
        case "original_title.desc":
          return b.original_title.localeCompare(a.original_title);
        default:
          return 0;
      }
    });
    return sorted;
  };

  const filterMovies = (movies: Movie[]): Movie[] => {
    let filtered = [...movies];

    if (selectedGenres.value.length > 0) {
      filtered = filtered.filter((movie) =>
        selectedGenres.value.some((genreId) =>
          movie.genre_ids.includes(genreId)
        )
      );
    }

    if (minRating.value > 0) {
      filtered = filtered.filter(
        (movie) => movie.vote_average >= minRating.value
      );
    }

    if (minYear.value > 1900 || maxYear.value < new Date().getFullYear()) {
      filtered = filtered.filter((movie) => {
        const year = new Date(movie.release_date).getFullYear();
        return year >= minYear.value && year <= maxYear.value;
      });
    }

    return filtered;
  };

  const fetchMovies = async () => {
    loading.value = true;

    try {
      const response = await $fetch<MovieResponse>(apiEndpoint, {
        params: {
          page: currentPage.value,
        },
      });

      const filtered = filterMovies(response.results);
      const sorted = sortMovies(filtered, sortBy.value);

      movies.value = sorted;
      totalPages.value = Math.min(response.total_pages, 500);
    } catch (error) {
      console.error("Error fetching movies:", error);
      movies.value = [];
    } finally {
      loading.value = false;
    }
  };

  const applyFilters = () => {
    currentPage.value = 1;
    fetchMovies();
  };

  const clearFilters = () => {
    sortBy.value = defaultSort;
    selectedGenres.value = [];
    minRating.value = defaultMinRating;
    minYear.value = 1900;
    maxYear.value = new Date().getFullYear();
    currentPage.value = 1;
  };

  watch(
    [sortBy, selectedGenres, minRating, minYear, maxYear],
    () => {
      currentPage.value = 1;
      fetchMovies();
    },
    { deep: true }
  );

  watch(currentPage, () => {
    fetchMovies();
  });

  return {
    movies,
    loading,
    currentPage,
    totalPages,
    sortBy,
    selectedGenres,
    minRating,
    minYear,
    maxYear,
    genres,
    fetchMovies,
    applyFilters,
    clearFilters,
  };
};
