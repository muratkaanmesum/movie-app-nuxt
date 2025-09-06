<script setup lang="ts">
import { debounce } from "~/utils/utils";
import { ref } from "vue";

defineProps({
  placeholder: {
    type: String,
    default: "Search for a movie, tv show, person",
  },
  showButton: {
    type: Boolean,
    default: true,
  },
  buttonText: {
    type: String,
    default: "Search",
  },
  inputClass: {
    type: String,
    default: "",
  },
});

const emit = defineEmits(["search", "blur"]);
const inputValue = ref("");

const handleInput = debounce((event: Event) => {
  const input = event.target as HTMLInputElement;
  inputValue.value = input.value;
  emit("search", input.value);
}, 500);

const handleSubmit = (event: Event) => {
  event.preventDefault();
  emit("search", inputValue.value);
};

const handleBlur = () => {
  emit("blur");
};

const clearSearch = () => {
  inputValue.value = "";
  emit("search", "");
};
</script>

<template>
  <form class="relative" @submit="handleSubmit">
    <input
      v-model="inputValue"
      type="text"
      class="w-full bg-white rounded-4xl placeholder:text-gray-700 h-12 pl-5 text-black outline-none"
      :class="inputClass"
      :placeholder="placeholder"
      @input="handleInput"
      @blur="handleBlur"
    />
    <div v-if="inputValue" class="absolute right-0 h-full flex items-center border">
      <button
        type="button"
        class="text-gray-400 hover:text-gray-600 mx-2"
        @click="clearSearch"
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          width="20"
          height="20"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
        >
          <circle cx="12" cy="12" r="10" />
          <line x1="15" y1="9" x2="9" y2="15" />
          <line x1="9" y1="9" x2="15" y2="15" />
        </svg>
      </button>
    </div>
    <button
      v-if="showButton && !inputValue"
      class="absolute right-0 bg-gradient-to-r h-full from-green-400 to-blue-400 text-white font-medium px-6 py-2 rounded-full shadow-md"
    >
      {{ buttonText }}
    </button>
  </form>
</template>
