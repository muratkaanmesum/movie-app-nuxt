<script setup lang="ts">
import { debounce } from "~/utils/utils";

const searchStore = useSearchStore();

const handleSearch = debounce((query: string) => {
  searchStore.searchMovies(query);
}, 500);
</script>

<template>
  <div>
    <NuxtRouteAnnouncer />

    <header>
      <AppNavbar />
    </header>

    <section>
      <div
        class="w-full h-96 bg-cover bg-center bg-no-repeat flex items-center justify-center"
        style="background-image: url(&quot;/moviePoster.jpg&quot;)"
      >
        <div class="text-white flex gap-20 flex-col">
          <div class="">
            <h1 class="font-bold text-5xl">Welcome</h1>
            <h3 class="text-4xl">
              Millions of movies, TV shows and people to discover. Explore now
            </h3>
          </div>
          <div class="relative">
            <SearchForm
              @search="handleSearch"
              @blur="searchStore.closeResults"
            />
            <SearchResults
              :results="searchStore.searchResults.value"
              :is-loading="searchStore.isLoading.value"
              :search-query="searchStore.searchQuery.value"
              :show-results="searchStore.showResults.value"
              @select-result="searchStore.selectResult"
            />
          </div>
        </div>
      </div>
    </section>

    <main class="main-background pt-10 w-[90%] !m-auto">
      <MovieCarousel />
    </main>
  </div>
</template>
