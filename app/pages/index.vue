<script setup lang="ts">
import { debounce } from "~/utils/utils";

useHead({
  title: "Movie App - Discover Movies and TV Shows",
  meta: [
    {
      name: "description",
      content:
        "Discover millions of movies and TV shows. Explore trending, popular, and top-rated content.",
    },
    {
      property: "og:title",
      content: "Movie App - Discover Movies and TV Shows",
    },
    {
      property: "og:description",
      content:
        "Discover millions of movies and TV shows. Explore trending, popular, and top-rated content.",
    },
    {
      property: "og:type",
      content: "website",
    },
    {
      name: "twitter:card",
      content: "summary_large_image",
    },
  ],
  link: [
    {
      rel: "canonical",
      href: "https://your-domain.com",
    },
  ],
});

const searchStore = useSearchStore();

const handleSearch = debounce((query: string) => {
  searchStore.searchMovies(query);
}, 500);
</script>

<template>
  <div>
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
              input-class="rounded-[24px]"
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
