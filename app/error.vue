<template>
  <div
    class="main-background min-h-screen text-white flex items-center justify-center"
  >
    <div class="text-center">
      <div class="text-9xl mb-6">🎬</div>
      <h1 class="text-6xl font-bold mb-4">404</h1>
      <h2 class="text-2xl mb-6">Page Not Found</h2>
      <p class="text-gray-400 mb-8 max-w-md">
        The page you're looking for doesn't exist. It might have been moved,
        deleted, or you entered the wrong URL.
      </p>
      <div class="flex gap-4 justify-center">
        <NuxtLink
          to="/"
          class="bg-blue-600 hover:bg-blue-700 px-6 py-3 rounded-lg transition-colors"
        >
          Go Home
        </NuxtLink>
        <button
          class="bg-gray-600 hover:bg-gray-700 px-6 py-3 rounded-lg transition-colors"
          @click="$router.back()"
        >
          Go Back
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
useHead({
  title: "404 - Page Not Found | Movie Database",
  meta: [
    {
      name: "description",
      content: "The page you are looking for could not be found.",
    },
  ],
});
</script>

<style scoped>
.main-background {
  background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
}
</style>
