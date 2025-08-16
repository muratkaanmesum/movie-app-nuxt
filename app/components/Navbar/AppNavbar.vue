<script setup lang="ts">
import AppImage from "../common/AppImage.vue";
</script>

<template>
  <nav class="text-white p-4 main-background font-bold">
    <div class="flex w-full justify-between h-8 items-center">
      <div class="flex gap-8 items-center">
        <div class="w-24 h-8">
          <AppImage src="/logo.png" class="object-cover" />
        </div>
        <RouterLink to="/">Movies</RouterLink>
        <RouterLink to="/tv-shows">TV Shows</RouterLink>
        <RouterLink to="/people">People</RouterLink>
        <RouterLink to="/more">More</RouterLink>
      </div>
    </div>
  </nav>
</template>
