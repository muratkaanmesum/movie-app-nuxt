export interface MovieDetails {
  id: number
  title: string
  overview: string
  poster_path: string | null
  backdrop_path: string | null
  release_date: string
  vote_average: number
  vote_count: number
  runtime: number
  genres: { id: number; name: string }[]
  production_companies: { id: number; name: string; logo_path: string | null }[]
  budget: number
  revenue: number
  tagline: string
  status: string
  original_language: string
  original_title: string
  popularity: number
  adult: boolean
  video: boolean
  credits: {
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
  videos: {
    id: string
    key: string
    name: string
    site: string
    type: string
    official: boolean
  }[]
}

export const useMovieDetails = (movieId: string | number) => {
  const { data: movie, pending, error, refresh } = useFetch<MovieDetails>(
    `/api/movies/details/${movieId}`,
    {
      key: `movie-details-${movieId}`,
      server: true
    }
  )

  const formatDate = (dateString: string) => {
    if (!dateString) return 'Unknown'
    return new Date(dateString).toLocaleDateString('en-US', { 
      year: 'numeric', 
      month: 'long', 
      day: 'numeric' 
    })
  }

  const formatRuntime = (minutes: number) => {
    if (!minutes) return 'Unknown'
    const hours = Math.floor(minutes / 60)
    const mins = minutes % 60
    return hours > 0 ? `${hours}h ${mins}m` : `${mins}m`
  }

  const getDirector = computed(() => {
    if (!movie.value?.credits?.crew) return null
    return movie.value.credits.crew.find(person => person.job === 'Director')
  })

  const getWriters = computed(() => {
    if (!movie.value?.credits?.crew) return []
    return movie.value.credits.crew.filter(person => 
      person.job === 'Writer' || person.job === 'Screenplay' || person.job === 'Story'
    )
  })

  const getTrailer = computed(() => {
    if (!movie.value?.videos) return null
    return movie.value.videos.find(video => 
      video.site === 'YouTube' && 
      video.type === 'Trailer' && 
      video.official
    ) || movie.value.videos.find(video => 
      video.site === 'YouTube' && 
      video.type === 'Trailer'
    )
  })

  return {
    movie,
    pending,
    error,
    refresh,
    formatDate,
    formatRuntime,
    getDirector,
    getWriters,
    getTrailer
  }
}
