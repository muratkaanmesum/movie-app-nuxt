export default defineEventHandler(async (event) => {
  const { type } = getRouterParams(event)
  const query = getQuery(event)
  const config = useRuntimeConfig()

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
  } catch (error) {
    console.error('Movie API Error:', error)
    throw createError({
      statusCode: 500,
      statusMessage: 'Failed to fetch movies'
    })
  }
})
