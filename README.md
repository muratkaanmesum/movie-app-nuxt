# Movie App - Nuxt 3 with SSR

A modern movie discovery application built with Nuxt 3, featuring Server-Side Rendering (SSR) for improved performance and SEO.

## Features

- **Server-Side Rendering (SSR)** - Fast initial page loads and SEO optimization
- **Movie Discovery** - Browse popular and top-rated movies
- **Real-time Search** - Search movies with debounced API calls
- **Responsive Design** - Tailwind CSS for modern, mobile-first design
- **Movie Details** - View ratings, release dates, and movie posters
- **Infinite Pagination** - Navigate through different pages of movies

## Tech Stack

- **Nuxt 3** - Vue.js framework with SSR
- **TypeScript** - Type-safe development
- **Tailwind CSS** - Utility-first CSS framework
- **TMDB API** - The Movie Database API for movie data
- **Nitro** - Server engine for SSR and API routes

## Setup

### Prerequisites

1. Get your API key from [The Movie Database (TMDB)](https://www.themoviedb.org/settings/api)
2. Copy `.env.example` to `.env` and add your API key:

```bash
cp .env.example .env
```

### Install Dependencies

```bash
# npm
npm install

# pnpm
pnpm install

# yarn
yarn install

# bun
bun install
```

## Development Server

Start the development server on `http://localhost:3000`:

```bash
# npm
npm run dev

# pnpm
pnpm dev

# yarn
yarn dev

# bun
bun run dev
```

## Production

Build the application for production:

```bash
# npm
npm run build

# pnpm
pnpm build

# yarn
yarn build

# bun
bun run build
```

Start the production server (SSR):

```bash
# npm
npm run start

# pnpm
pnpm start

# yarn
yarn start

# bun
bun run start
```

Locally preview production build:

```bash
# npm
npm run preview

# pnpm
pnpm preview

# yarn
yarn preview

# bun
bun run preview
```

## SSR Implementation

This application leverages Nuxt 3's powerful SSR capabilities:

### Key SSR Features

1. **Server-Side Data Fetching** - Movies are fetched on the server before rendering
2. **SEO Optimization** - Meta tags and structured data for search engines
3. **Faster Initial Load** - Content is rendered on the server for instant display
4. **Hydration** - Client-side interactivity is seamlessly added after initial render

### SSR Configuration

- **Nitro Preset**: `node-server` for optimal SSR performance
- **API Routes**: Server-side API endpoints for secure API key handling
- **useFetch**: Automatic SSR data fetching with caching
- **Meta Tags**: Dynamic meta tags for better SEO

### Performance Benefits

- **First Contentful Paint (FCP)** - Improved with server-rendered content
- **Search Engine Optimization** - Better indexing with server-side rendering
- **Social Media Sharing** - Proper meta tags for social platforms
- **Caching** - Built-in request caching for repeated API calls

## API Structure

```
/api/movies/:type
├── popular - Get popular movies
└── top_rated - Get top-rated movies
```

## Environment Variables

```bash
NUXT_PUBLIC_TMDB_API_KEY=your_tmdb_api_key
# or
VITE_API_KEY=your_tmdb_api_key
```

Check out the [deployment documentation](https://nuxt.com/docs/getting-started/deployment) for more information.
