interface MovieDetails {
  id: number;
  title: string;
  overview: string;
  poster_path: string;
  backdrop_path: string;
  release_date: string;
  vote_average: number;
  vote_count: number;
  runtime: number;
  genres: { id: number; name: string }[];
  production_companies: { id: number; name: string; logo_path: string }[];
  budget: number;
  revenue: number;
  tagline: string;
  status: string;
  original_language: string;
  original_title: string;
  popularity: number;
  adult: boolean;
  video: boolean;
}

interface CastMember {
  id: number;
  name: string;
  character: string;
  profile_path: string;
  order: number;
}

interface CrewMember {
  id: number;
  name: string;
  job: string;
  department: string;
  profile_path: string;
}

interface Credits {
  cast: CastMember[];
  crew: CrewMember[];
}

interface Video {
  id: string;
  key: string;
  name: string;
  site: string;
  type: string;
  official: boolean;
}

interface VideoResponse {
  results: Video[];
}

export default defineEventHandler(async (event) => {
  const { id } = getRouterParams(event);
  const config = useRuntimeConfig();

  try {
    // Fetch movie details with credits (cast & crew) in one request
    const [movieDetails, credits, videos] = await Promise.all([
      $fetch<MovieDetails>(`https://api.themoviedb.org/3/movie/${id}`, {
        params: {
          api_key: config.public.tmdbApiKey,
          language: "en-US",
        },
        headers: {
          accept: "application/json",
        },
      }),
      $fetch<Credits>(`https://api.themoviedb.org/3/movie/${id}/credits`, {
        params: {
          api_key: config.public.tmdbApiKey,
          language: "en-US",
        },
        headers: {
          accept: "application/json",
        },
      }),
      $fetch<VideoResponse>(`https://api.themoviedb.org/3/movie/${id}/videos`, {
        params: {
          api_key: config.public.tmdbApiKey,
          language: "en-US",
        },
        headers: {
          accept: "application/json",
        },
      }),
    ]);

    return {
      ...movieDetails,
      credits,
      videos: videos.results || [],
    };
  } catch (error) {
    console.error("Movie Details API Error:", error);
    throw createError({
      statusCode: 404,
      statusMessage: "Movie not found",
    });
  }
});
