interface TVShowDetails {
  id: number
  name: string
  overview: string
  poster_path: string | null
  backdrop_path: string | null
  first_air_date: string
  last_air_date: string
  vote_average: number
  vote_count: number
  number_of_episodes: number
  number_of_seasons: number
  genres: { id: number; name: string }[]
  production_companies: { id: number; name: string; logo_path: string | null }[]
  created_by: { id: number; name: string; profile_path: string | null }[]
  networks: { id: number; name: string; logo_path: string | null }[]
  tagline: string
  status: string
  original_language: string
  original_name: string
  popularity: number
  adult: boolean
  type: string
}

interface TVCredits {
  cast: {
    id: number
    name: string
    character: string
    profile_path: string | null
    order: number
  }[]
  crew: {
    id: number
    name: string
    job: string
    department: string
    profile_path: string | null
  }[]
}

interface VideoResponse {
  results: {
    id: string
    key: string
    name: string
    site: string
    type: string
    official: boolean
  }[]
}

export default defineEventHandler(async (event) => {
  const { id } = getRouterParams(event)
  const config = useRuntimeConfig()

  try {
    // Fetch TV show details with credits and videos
    const [tvDetails, credits, videos] = await Promise.all([
      $fetch<TVShowDetails>(`https://api.themoviedb.org/3/tv/${id}`, {
        params: {
          api_key: config.public.tmdbApiKey,
          language: "en-US",
        },
        headers: {
          accept: "application/json",
        },
      }),
      $fetch<TVCredits>(`https://api.themoviedb.org/3/tv/${id}/credits`, {
        params: {
          api_key: config.public.tmdbApiKey,
          language: "en-US",
        },
        headers: {
          accept: "application/json",
        },
      }),
      $fetch<VideoResponse>(`https://api.themoviedb.org/3/tv/${id}/videos`, {
        params: {
          api_key: config.public.tmdbApiKey,
          language: "en-US",
        },
        headers: {
          accept: "application/json",
        },
      }),
    ])

    return {
      ...tvDetails,
      credits,
      videos: videos.results || [],
    }
  } catch (error) {
    console.error('TV Show Details API Error:', error)
    throw createError({
      statusCode: 404,
      statusMessage: 'TV show not found'
    })
  }
})
