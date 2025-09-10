<script setup lang="ts">
interface SortOption {
  value: string;
  label: string;
}

interface Props {
  modelValue: string;
  options: SortOption[];
}

interface Emits {
  (e: "update:modelValue", value: string): void;
  (e: "change"): void;
}

defineProps<Props>();
defineEmits<Emits>();
</script>

<template>
  <div class="bg-gray-800 rounded-lg p-4 mb-6">
    <h3 class="text-lg font-semibold mb-4">Sort Results By</h3>
    <select
      :value="modelValue"
      class="w-full bg-gray-700 border border-gray-600 rounded px-3 py-2 text-white focus:outline-none focus:border-blue-500"
      @change="
        $emit('update:modelValue', ($event.target as HTMLSelectElement).value);
        $emit('change');
      "
    >
      <option
        v-for="option in options"
        :key="option.value"
        :value="option.value"
      >
        {{ option.label }}
      </option>
    </select>
  </div>
</template>
