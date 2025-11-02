// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: "2025-07-15",
  devtools: { enabled: true },

  // SSR is enabled by default in Nuxt 3, but we can explicitly set it
  ssr: true,

  // Nitro configuration for server-side rendering
  nitro: {
    preset: "node-server", // Use node-server for better SSR support
    minify: true, // Minify output for production
    compressPublicAssets: true, // Compress public assets
    // Optimize build time (optional)
    // parallel: true, // Enable parallel builds if available
  },

  modules: [
    "@nuxt/eslint",
    "@nuxt/fonts",
    "@nuxt/icon",
    "@nuxt/image",
    "@nuxtjs/tailwindcss",
  ],

  css: ["~/assets/css/tailwind.css"],

  components: [
    {
      path: "~/components",
      pathPrefix: false,
    },
  ],

  vue: {
    compilerOptions: {
      isCustomElement: (tag) => {
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
