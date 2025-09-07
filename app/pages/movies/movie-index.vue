<template>
  <div class="main-background min-h-screen text-white">
    <AppNavbar />
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-4xl font-bold mb-8">Movies</h1>
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <NuxtLink
          to="/movies/popular"
          class="bg-gray-800 p-6 rounded-lg hover:bg-gray-700 transition-colors"
        >
          <h3 class="text-xl font-semibold mb-2">Popular</h3>
          <p class="text-gray-400">Discover trending movies</p>
        </NuxtLink>
        <NuxtLink
          to="/movies/now-playing"
          class="bg-gray-800 p-6 rounded-lg hover:bg-gray-700 transition-colors"
        >
          <h3 class="text-xl font-semibold mb-2">Now Playing</h3>
          <p class="text-gray-400">Currently in theaters</p>
        </NuxtLink>
        <NuxtLink
          to="/movies/upcoming"
          class="bg-gray-800 p-6 rounded-lg hover:bg-gray-700 transition-colors"
        >
          <h3 class="text-xl font-semibold mb-2">Upcoming</h3>
          <p class="text-gray-400">Coming soon to theaters</p>
        </NuxtLink>
        <NuxtLink
          to="/movies/top-rated"
          class="bg-gray-800 p-6 rounded-lg hover:bg-gray-700 transition-colors"
        >
          <h3 class="text-xl font-semibold mb-2">Top Rated</h3>
          <p class="text-gray-400">Highest rated movies</p>
        </NuxtLink>
      </div>
    </div>
  </div>
</template>
