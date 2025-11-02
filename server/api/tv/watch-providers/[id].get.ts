export default defineEventHandler(async (event) => {
  const { id } = getRouterParams(event);
  const config = useRuntimeConfig();

  // Check if API key is configured
  if (!config.public.tmdbApiKey || config.public.tmdbApiKey === 'your_tmdb_api_key_here') {
    throw createError({
      statusCode: 500,
      statusMessage: 'TMDB API key is not configured',
    });
  }

  try {
    const response = await $fetch(`https://api.themoviedb.org/3/tv/${id}/watch/providers`, {
      params: {
        api_key: config.public.tmdbApiKey,
      },
      headers: {
        accept: 'application/json',
      },
    });

    return response;
  } catch (error: any) {
    console.error('Watch Providers API Error:', error);
    throw createError({
      statusCode: error?.statusCode || 500,
      statusMessage: `Failed to fetch watch providers: ${error?.message || 'Unknown error'}`,
    });
  }
});

