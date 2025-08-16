// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: "2025-07-15",
  devtools: { enabled: true },

  modules: [
    "@nuxt/content",
    "@nuxt/eslint",
    "@nuxt/fonts",
    "@nuxt/icon",
    "@nuxt/image",
    "@nuxtjs/tailwindcss",
  ],

  css: ["~/assets/css/custom.css"],

  components: [
    {
      path: "~/components",
      pathPrefix: false,
    },
  ],

  vue: {
    compilerOptions: {
      isCustomElement: (tag) => {
        // Add any custom elements you want to exclude from Vue component resolution
        // For example, if you're using web components or custom HTML elements
        return (
          tag.startsWith("my-") ||
          tag.startsWith("custom-") ||
          tag.includes("-")
        );
      },
    },
  },

  runtimeConfig: {
    public: {
      tmdbApiKey:
        process.env.VITE_API_KEY || process.env.NUXT_PUBLIC_TMDB_API_KEY,
    },
  },
});
