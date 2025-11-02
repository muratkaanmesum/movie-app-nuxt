<script setup lang="ts">
interface Provider {
  logo_path: string;
  provider_name: string;
  display_priority: number;
}

interface WatchProviders {
  flatrate?: Provider[];
  rent?: Provider[];
  buy?: Provider[];
}

interface Props {
  providers: WatchProviders | null;
  region?: string;
}

const props = withDefaults(defineProps<Props>(), {
  region: 'US',
});

const providerLogos: Record<string, string> = {
  'Netflix': 'https://image.tmdb.org/t/p/original/9A1JSVmSxsyaBK4SUFsYVqbAYfW.jpg',
  'Disney Plus': 'https://image.tmdb.org/t/p/original/dgPueyEdOwpQ10fjuhL2WYFQwQs.jpg',
  'Amazon Prime Video': 'https://image.tmdb.org/t/p/original/emthp39XA2YScoYL1p0sdbAH2WA.jpg',
  'HBO Max': 'https://image.tmdb.org/t/p/original/4KAy34EHvRM25Ih8wb82AuGU7zJ.jpg',
  'Hulu': 'https://image.tmdb.org/t/p/original/aRGDrZ0y9bjbHjfe8UeCmYTj3Dj.jpg',
  'Apple TV Plus': 'https://image.tmdb.org/t/p/original/4KAy34EHvRM25Ih8wb82AuGU7zJ.jpg',
};

const getProviderLogo = (logoPath: string, providerName: string) => {
  if (logoPath) {
    return `https://image.tmdb.org/t/p/w200${logoPath}`;
  }
  return providerLogos[providerName] || null;
};
</script>

<template>
  <div v-if="providers && (providers.flatrate || providers.rent || providers.buy)" class="my-8">
    <h2 class="text-2xl font-bold mb-6">Where to Watch</h2>
    
    <div v-if="providers.flatrate && providers.flatrate.length > 0" class="mb-6">
      <h3 class="text-lg font-semibold mb-3 text-blue-400">Stream</h3>
      <div class="flex flex-wrap gap-4">
        <div
          v-for="provider in providers.flatrate.slice(0, 8)"
          :key="provider.provider_name"
          class="flex flex-col items-center"
        >
          <img
            v-if="getProviderLogo(provider.logo_path, provider.provider_name)"
            :src="getProviderLogo(provider.logo_path, provider.provider_name)"
            :alt="provider.provider_name"
            class="w-16 h-16 object-contain rounded-lg bg-white p-2"
            loading="lazy"
          />
          <p class="text-xs text-gray-400 mt-2 text-center max-w-[80px]">
            {{ provider.provider_name }}
          </p>
        </div>
      </div>
    </div>

    <div v-if="providers.rent && providers.rent.length > 0" class="mb-6">
      <h3 class="text-lg font-semibold mb-3 text-yellow-400">Rent</h3>
      <div class="flex flex-wrap gap-4">
        <div
          v-for="provider in providers.rent.slice(0, 8)"
          :key="provider.provider_name"
          class="flex flex-col items-center"
        >
          <img
            v-if="getProviderLogo(provider.logo_path, provider.provider_name)"
            :src="getProviderLogo(provider.logo_path, provider.provider_name)"
            :alt="provider.provider_name"
            class="w-16 h-16 object-contain rounded-lg bg-white p-2"
            loading="lazy"
          />
          <p class="text-xs text-gray-400 mt-2 text-center max-w-[80px]">
            {{ provider.provider_name }}
          </p>
        </div>
      </div>
    </div>

    <div v-if="providers.buy && providers.buy.length > 0" class="mb-6">
      <h3 class="text-lg font-semibold mb-3 text-green-400">Buy</h3>
      <div class="flex flex-wrap gap-4">
        <div
          v-for="provider in providers.buy.slice(0, 8)"
          :key="provider.provider_name"
          class="flex flex-col items-center"
        >
          <img
            v-if="getProviderLogo(provider.logo_path, provider.provider_name)"
            :src="getProviderLogo(provider.logo_path, provider.provider_name)"
            :alt="provider.provider_name"
            class="w-16 h-16 object-contain rounded-lg bg-white p-2"
            loading="lazy"
          />
          <p class="text-xs text-gray-400 mt-2 text-center max-w-[80px]">
            {{ provider.provider_name }}
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

