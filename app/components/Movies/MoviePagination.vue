<script setup lang="ts">
interface Props {
  currentPage: number;
  totalPages: number;
  loading: boolean;
}

interface Emits {
  (e: "update:current-page", value: number): void;
}

defineProps<Props>();
defineEmits<Emits>();
</script>

<template>
  <div class="flex justify-center items-center gap-4 mt-8">
    <button
      :disabled="currentPage <= 1 || loading"
      class="flex items-center gap-2 bg-gray-700 hover:bg-gray-600 disabled:opacity-50 disabled:cursor-not-allowed px-4 py-2 rounded transition-colors"
      @click="currentPage > 1 && $emit('update:current-page', currentPage - 1)"
    >
      <svg
        class="w-4 h-4"
        fill="none"
        stroke="currentColor"
        viewBox="0 0 24 24"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M15 19l-7-7 7-7"
        />
      </svg>
      Previous
    </button>

    <span class="text-gray-300 px-4">
      Page {{ currentPage }} of {{ totalPages }}
    </span>

    <button
      :disabled="currentPage >= totalPages || loading"
      class="flex items-center gap-2 bg-gray-700 hover:bg-gray-600 disabled:opacity-50 disabled:cursor-not-allowed px-4 py-2 rounded transition-colors"
      @click="
        currentPage < totalPages &&
        $emit('update:current-page', currentPage + 1)
      "
    >
      Next
      <svg
        class="w-4 h-4"
        fill="none"
        stroke="currentColor"
        viewBox="0 0 24 24"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M9 5l7 7-7 7"
        />
      </svg>
    </button>
  </div>
</template>
