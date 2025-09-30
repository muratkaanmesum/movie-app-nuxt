<template>
  <div class="main-background min-h-screen text-white">
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-4xl font-bold mb-8">TV Shows</h1>
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <NuxtLink
          to="/tv/popular"
          class="bg-gray-800 p-6 rounded-lg hover:bg-gray-700 transition-colors"
        >
          <h3 class="text-xl font-semibold mb-2">Popular</h3>
          <p class="text-gray-400">Discover trending TV shows</p>
        </NuxtLink>
        <NuxtLink
          to="/tv/top_rated"
          class="bg-gray-800 p-6 rounded-lg hover:bg-gray-700 transition-colors"
        >
          <h3 class="text-xl font-semibold mb-2">Top Rated</h3>
          <p class="text-gray-400">Highest rated TV shows</p>
        </NuxtLink>
        <NuxtLink
          to="/tv/on_the_air"
          class="bg-gray-800 p-6 rounded-lg hover:bg-gray-700 transition-colors"
        >
          <h3 class="text-xl font-semibold mb-2">On The Air</h3>
          <p class="text-gray-400">Currently airing shows</p>
        </NuxtLink>
        <NuxtLink
          to="/tv/airing_today"
          class="bg-gray-800 p-6 rounded-lg hover:bg-gray-700 transition-colors"
        >
          <h3 class="text-xl font-semibold mb-2">Airing Today</h3>
          <p class="text-gray-400">Shows airing today</p>
        </NuxtLink>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
useHead({
  title: 'TV Shows - Movie Database',
  meta: [
    {
      name: 'description',
      content: 'Discover popular, top-rated, and currently airing TV shows'
    }
  ]
})
</script>

<style scoped>
.main-background {
  background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
}
</style>
