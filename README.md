# 🎬 Movie & TV Database - Nuxt 3 Application

A comprehensive movie and TV series tracking web application built with Nuxt 3, similar to The Movie Database (TMDB). This application allows users to discover, search, and track their favorite movies and TV shows with detailed information, ratings, and cast details.

## ✨ Features

### 🎥 Dynamic Movie Pages

- **Individual Movie Pages**: Each movie has its own dynamic route (`/movies/{id}`)
- **Comprehensive Details**: Movie poster, user score, overview, cast, crew, videos, and production info
- **User Ratings**: Visual rating display with percentage scores
- **Cast & Crew**: Detailed cast information with profile pictures and character names
- **Videos & Trailers**: Embedded YouTube trailers and promotional videos
- **Production Companies**: Display of production companies with logos

### 📺 TV Show Support

- **Dynamic TV Show Pages**: Individual pages for TV shows (`/tv/{id}`)
- **Season & Episode Info**: Number of seasons, episodes, and air dates
- **Network Information**: Broadcasting networks with logos
- **Created By**: Show creators and executive producers

### ⭐ Favorites System

- **Add/Remove Favorites**: Heart button on movie and TV show cards
- **Persistent Storage**: Favorites saved to localStorage
- **Favorites Page**: Dedicated page to view all favorited content
- **Visual Indicators**: Clear favorite status indicators

### 🔍 Search Functionality

- **Multi-Category Search**: Search both movies and TV shows simultaneously
- **Real-time Results**: Fast search with TMDB API integration
- **Result Categories**: Separated movie and TV show results
- **Search Persistence**: URL-based search queries

### 🎯 Category Browsing

- **Movie Categories**:
  - Popular Movies
  - Now Playing
  - Upcoming
  - Top Rated
- **TV Show Categories**:
  - Popular TV Shows
  - On The Air
  - Airing Today
  - Top Rated

### 🎨 User Experience

- **Responsive Design**: Works on desktop, tablet, and mobile
- **Modern UI**: Dark theme with gradient backgrounds
- **Loading States**: Smooth loading indicators
- **Error Handling**: Custom 404 and error pages
- **SEO Optimized**: Meta tags and structured data
- **Navigation**: Intuitive navbar with dropdowns

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

## 🐳 Docker Deployment

This application is fully containerized with Docker for easy deployment and development. A comprehensive Makefile is provided for streamlined Docker operations.

### Prerequisites

1. [Docker](https://docs.docker.com/get-docker/) installed on your system
2. [Docker Compose](https://docs.docker.com/compose/install/) (usually included with Docker Desktop)
3. [Make](https://www.gnu.org/software/make/) (usually pre-installed on macOS/Linux)
4. TMDB API key from [The Movie Database](https://www.themoviedb.org/settings/api)

### Environment Setup

1. Copy the environment file and add your TMDB API key:

```bash
cp .env.example .env
```

2. Edit `.env` and replace `your_tmdb_api_key_here` with your actual TMDB API key:

```bash
TMDB_API_KEY=your_actual_api_key_here
```

### Production Deployment

Build and run the production version:

```bash
# Using Makefile (recommended)
make setup        # Setup environment file
make prod-start   # Build and start production container

# View logs
make prod-logs

# Stop the container
make prod-stop

# Or using Docker Compose directly
docker-compose up -d
docker-compose logs -f
docker-compose down
```

The application will be available at `http://localhost:3000`

### Development with Docker

For development with hot reloading:

```bash
# Using Makefile (recommended)
make setup        # Setup environment file (if not done already)
make dev-start    # Start development environment

# View logs
make dev-logs

# Stop development environment
make dev-stop

# Or using Docker Compose directly
docker-compose -f docker-compose.dev.yml up -d
docker-compose -f docker-compose.dev.yml logs -f
docker-compose -f docker-compose.dev.yml down
```

Development server runs at `http://localhost:3000` with hot reloading enabled.

### Using Makefile Commands

The project includes a comprehensive Makefile for easy Docker operations:

```bash
# Show all available commands
make help

# Setup environment file
make setup

# Production commands
make prod-build      # Build production container
make prod-start      # Start production environment
make prod-stop       # Stop production environment
make prod-logs       # View production logs
make prod-restart    # Restart production environment

# Development commands
make dev-start       # Start development environment
make dev-stop        # Stop development environment
make dev-logs        # View development logs
make dev-restart     # Restart development environment

# Utility commands
make status          # Show container status
make shell           # Open shell in production container
make dev-shell       # Open shell in development container
make cleanup         # Clean up all Docker resources
make build-all       # Build both environments
make stop-all        # Stop all environments
make health          # Check application health
make logs-all        # Show logs for all containers
```

### Direct Docker Commands

You can also use Docker Compose directly:

```bash
# Build only
docker-compose build

# Rebuild without cache
docker-compose build --no-cache

# Run in foreground (see logs directly)
docker-compose up

# Scale the application (multiple instances)
docker-compose up -d --scale movie-app=3

# View container status
docker-compose ps

# Execute commands in running container
docker-compose exec movie-app sh

# Remove containers and volumes
docker-compose down -v
```

### Docker Files Structure

- `Makefile` - Docker command automation and shortcuts
- `Dockerfile` - Production container configuration
- `Dockerfile.dev` - Development container with dev dependencies
- `docker-compose.yml` - Production orchestration
- `docker-compose.dev.yml` - Development orchestration
- `.dockerignore` - Files to exclude from Docker context

### Troubleshooting

**Port already in use:**

```bash
# Check what's using port 3000
lsof -i :3000

# Use different port
docker-compose up -d -p 3001:3000
```

**Container won't start:**

```bash
# Check logs
docker-compose logs movie-app

# Rebuild container
docker-compose build --no-cache
docker-compose up -d
```

**API key issues:**

- Ensure your `.env` file has the correct TMDB API key
- Restart containers after changing environment variables

Check out the [deployment documentation](https://nuxt.com/docs/getting-started/deployment) for more information.
