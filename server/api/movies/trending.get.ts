export default defineEventHandler(async (event) => {
  const query = getQuery(event);
  const config = useRuntimeConfig();

  // Check if API key is configured
  if (!config.public.tmdbApiKey || config.public.tmdbApiKey === 'your_tmdb_api_key_here') {
    throw createError({
      statusCode: 500,
      statusMessage: 'TMDB API key is not configured',
    });
  }

  const timeWindow = (query.time_window as string) || 'day'; // 'day' or 'week'

  try {
    const response = await $fetch(`https://api.themoviedb.org/3/trending/movie/${timeWindow}`, {
      params: {
        api_key: config.public.tmdbApiKey,
        language: 'en-US',
        page: query.page || 1,
      },
      headers: {
        accept: 'application/json',
      },
    });

    return response;
  } catch (error: any) {
    console.error('Trending Movies API Error:', error);
    throw createError({
      statusCode: error?.statusCode || 500,
      statusMessage: `Failed to fetch trending movies: ${error?.message || 'Unknown error'}`,
    });
  }
});

