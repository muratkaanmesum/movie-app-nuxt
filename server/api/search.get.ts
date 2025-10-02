interface SearchMovieResult {
  results: Array<{
    id: number;
    title: string;
    original_title: string;
    overview: string;
    poster_path: string | null;
    backdrop_path: string | null;
    release_date: string;
    vote_average: number;
    vote_count: number;
    genre_ids: number[];
    adult: boolean;
    original_language: string;
    popularity: number;
    video: boolean;
  }>;
  total_results: number;
  total_pages: number;
  page: number;
}

interface SearchTVResult {
  results: Array<{
    id: number;
    name: string;
    original_name: string;
    overview: string;
    poster_path: string | null;
    backdrop_path: string | null;
    first_air_date: string;
    vote_average: number;
    vote_count: number;
    genre_ids: number[];
    adult: boolean;
    original_language: string;
    popularity: number;
    origin_country: string[];
  }>;
  total_results: number;
  total_pages: number;
  page: number;
}

export default defineEventHandler(async (event) => {
  const query = getQuery(event);
  const config = useRuntimeConfig();

  if (!query.q) {
    throw createError({
      statusCode: 400,
      statusMessage: "Search query is required",
    });
  }

  try {
    const [movieResults, tvResults] = await Promise.all([
      // Search movies
      $fetch<SearchMovieResult>(`https://api.themoviedb.org/3/search/movie`, {
        params: {
          api_key: config.public.tmdbApiKey,
          language: "en-US",
          query: query.q,
          page: query.page || 1,
          include_adult: false,
        },
        headers: {
          accept: "application/json",
        },
      }),
      // Search TV shows
      $fetch<SearchTVResult>(`https://api.themoviedb.org/3/search/tv`, {
        params: {
          api_key: config.public.tmdbApiKey,
          language: "en-US",
          query: query.q,
          page: query.page || 1,
          include_adult: false,
        },
        headers: {
          accept: "application/json",
        },
      }),
    ]);

    return {
      query: query.q,
      movies: movieResults.results || [],
      tvShows: tvResults.results || [],
      totalMovies: movieResults.total_results || 0,
      totalTVShows: tvResults.total_results || 0,
    };
  } catch (error) {
    console.error("Search API Error:", error);
    throw createError({
      statusCode: 500,
      statusMessage: "Failed to search",
    });
  }
});
