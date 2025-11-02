export default defineEventHandler(async (event) => {
  const { type } = getRouterParams(event)
  const query = getQuery(event)
  const config = useRuntimeConfig()

  // Check if API key is configured
  if (!config.public.tmdbApiKey || config.public.tmdbApiKey === 'your_tmdb_api_key_here') {
    console.error('TMDB API Key is not configured')
    throw createError({
      statusCode: 500,
      statusMessage: 'TMDB API key is not configured. Please set NUXT_PUBLIC_TMDB_API_KEY environment variable.'
    })
  }

  try {
    const response = await $fetch(`https://api.themoviedb.org/3/movie/${type}`, {
      params: {
        include_adult: false,
        include_video: false,
        language: "en-US",
        page: query.page || 1,
        sort_by: "popularity.desc",
        api_key: config.public.tmdbApiKey,
      },
      headers: {
        accept: "application/json",
      },
    })

    return response
  } catch (error: any) {
    console.error('Movie API Error:', error)
    
    // Provide more specific error messages
    if (error?.statusCode === 401 || error?.status === 401) {
      throw createError({
        statusCode: 401,
        statusMessage: 'Invalid TMDB API key. Please check your NUXT_PUBLIC_TMDB_API_KEY.'
      })
    }
    
    if (error?.statusCode === 404 || error?.status === 404) {
      throw createError({
        statusCode: 404,
        statusMessage: 'Movie endpoint not found'
      })
    }

    throw createError({
      statusCode: 500,
      statusMessage: `Failed to fetch movies: ${error?.message || 'Unknown error'}`
    })
  }
})
