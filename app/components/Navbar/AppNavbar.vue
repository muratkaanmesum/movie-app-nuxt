<script setup lang="ts">
import AppImage from "../common/AppImage.vue";

interface DropdownItem {
  label: string;
  path: string;
}

interface NavItem {
  label: string;
  path: string;
  dropdown?: DropdownItem[];
}

const navItems: NavItem[] = [
  {
    label: "Movies",
    path: "/movies",
    dropdown: [
      { label: "Popular", path: "/movies/popular" },
      { label: "Now Playing", path: "/movies/now-playing" },
      { label: "Upcoming", path: "/movies/upcoming" },
      { label: "Top Rated", path: "/movies/top-rated" },
    ],
  },
  {
    label: "TV Shows",
    path: "/tv-shows",
    dropdown: [
      { label: "Popular", path: "/tv/popular" },
      { label: "Airing Today", path: "/tv/airing-today" },
      { label: "On TV", path: "/tv/on-the-air" },
      { label: "Top Rated", path: "/tv/top-rated" },
    ],
  },
  {
    label: "People",
    path: "/people",
    dropdown: [{ label: "Popular People", path: "/people/popular" }],
  },
  {
    label: "Search",
    path: "/search",
  },
  {
    label: "Favorites",
    path: "/favorites",
  },
  {
    label: "Watchlist",
    path: "/watchlist",
  },
  {
    label: "Trending",
    path: "/trending",
  },
  {
    label: "Recently Viewed",
    path: "/recently-viewed",
  },
];
</script>

<template>
  <nav class="text-white p-4 main-background font-bold relative z-50">
    <div class="flex w-full justify-between h-8 items-center">
      <div class="flex gap-8 items-center">
        <div class="w-24 h-8">
          <AppImage src="/logo.png" class="object-cover" />
        </div>

        <!-- Navigation Items with Dropdowns -->
        <div
          v-for="item in navItems"
          :key="item.label"
          class="relative group h-full flex items-center"
        >
          <NuxtLink
            :to="item.path"
            class="hover:text-blue-300 transition-colors duration-200 py-3 px-2 block whitespace-nowrap"
          >
            {{ item.label }}
          </NuxtLink>

          <!-- Dropdown Menu -->
          <div
            v-if="item.dropdown"
            class="absolute top-full left-0 pt-2 w-48 opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all duration-300 transform translate-y-2 group-hover:translate-y-0 z-50"
          >
            <div
              class="bg-gray-900 border border-gray-700 rounded-lg shadow-xl py-2"
            >
              <NuxtLink
                v-for="dropdownItem in item.dropdown"
                :key="dropdownItem.path"
                :to="dropdownItem.path"
                class="block px-4 py-3 text-sm text-gray-200 hover:bg-gray-800 hover:text-blue-300 transition-colors duration-150 first:rounded-t-lg last:rounded-b-lg"
              >
                {{ dropdownItem.label }}
              </NuxtLink>
            </div>
          </div>
        </div>
      </div>
    </div>
  </nav>
</template>
