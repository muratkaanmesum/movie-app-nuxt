<template>
  <div v-if="companies?.length > 0" class="mb-8">
    <h3 class="text-2xl font-semibold mb-4">{{ title }}</h3>
    <div class="flex flex-wrap gap-4">
      <div
        v-for="company in companies"
        :key="company.id"
        class="flex items-center gap-2 bg-gray-800 px-4 py-2 rounded-lg w-full max-w-72"
      >
        <AppImage
          v-if="company.logo_path"
          :src="`https://image.tmdb.org/t/p/w92${company.logo_path}`"
          :alt="company.name"
          class="w-8 h-8 object-contain"
        />
        <span class="text-sm">{{ company.name }}</span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
interface Company {
  id: number;
  name: string;
  logo_path: string | null;
}

interface Props {
  companies: Company[];
  title: string;
}

defineProps<Props>();
</script>
