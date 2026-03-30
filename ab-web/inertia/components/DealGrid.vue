<template>
  <div v-if="useStore.promotedProducts.length > 0" class="w-full">
    <!-- Section Header -->
    <div class="flex items-center gap-4 mb-6 pb-4 border-b-2 border-gray-200">
      <h2 class="text-3xl font-black text-gray-900">Promotions en cours</h2>
      <span class="bg-red-600 text-white text-xs font-bold px-3 py-1 rounded animate-pulse">LIVE</span>
      <div class="ml-auto flex items-center gap-2 text-sm text-gray-600">
        <span>Se termine dans:</span>
        <div class="bg-red-600 text-white font-bold px-3 py-1 rounded min-w-[40px] text-center" id="countdown-h">04</div>
        <span>:</span>
        <div class="bg-red-600 text-white font-bold px-3 py-1 rounded min-w-[40px] text-center" id="countdown-m">23</div>
        <span>:</span>
        <div class="bg-red-600 text-white font-bold px-3 py-1 rounded min-w-[40px] text-center" id="countdown-s">17</div>
      </div>
      <a href="/catalogue" class="text-red-600 font-semibold hover:underline">Tout voir →</a>
    </div>

    <!-- Navigation Tabs -->
    <div class="flex gap-2 mb-6 overflow-x-auto pb-2 scrollbar-hide">
      <button
        v-for="tab in dynamicTabs"
        :key="tab.id"
        @click="activeTab = tab.id"
        :class="[
          'px-4 py-2 rounded-lg text-sm font-medium whitespace-nowrap transition-colors',
          activeTab === tab.id
            ? 'bg-red-600 text-white'
            : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
        ]"
      >
        {{ tab.name }}
      </button>
    </div>

    <!-- Promotion Grid -->
    <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-4">
      <div
        v-for="promotion in filteredPromotions"
        :key="promotion.id"
        class="bg-white rounded-lg overflow-hidden shadow-md hover:shadow-xl transition-all duration-300 hover:-translate-y-1 cursor-pointer"
      >
        <div class="relative aspect-square">
          <img @click="navigateToPromotion(promotion)"
                :src="getImageUrl(promotion)"
                :alt="promotion.promoLabel"
                class="w-full h-full object-cover hover:scale-105 transition-transform duration-300"
                @error="handleImageError"
          />
          
          <!-- Sale Tag -->
          <div class="absolute top-2 left-2 bg-red-600 text-white text-xs font-bold px-2 py-1 rounded">
            -{{ promotion.discountPercent }}%
          </div>
          
          <!-- Wishlist Button -->
          <button class="absolute top-2 right-2 bg-white/90 backdrop-blur-sm rounded-full w-8 h-8 flex items-center justify-center opacity-0 hover:opacity-100 transition-opacity duration-200">
            <span class="text-red-500">♡</span>
          </button>
        </div>

        <div class="p-3">
          <h3 @click="navigateToPromotion(promotion)" class="font-semibold text-sm text-gray-900 line-clamp-2 mb-2 hover:text-red-600 transition-colors cursor-pointer">
            {{ promotion.promoLabel }}
          </h3>

          <div class="flex items-center gap-2 mb-2">
            <span class="text-lg font-black text-red-600">
              {{ getPromoPrice(promotion) }} F
            </span>
            <span v-if="promotion.discountPercent" class="text-sm text-gray-400 line-through">
              {{ getOriginalPrice(promotion) }} F
            </span>
          </div>

          <div class="flex items-center gap-1 text-xs text-gray-500 mb-3">
            <span class="text-orange-500">★★★★☆</span>
            <span>{{ Math.floor(Math.random() * 1000) + 100 }} vendus</span>
          </div>

          <div class="text-xs text-green-600 font-medium mb-3">
            ✓ Promotion valide
          </div>

          <button
            class="w-full bg-red-600 hover:bg-red-700 text-white font-bold py-2 px-3 rounded-lg transition-colors text-sm"
            @click="navigateToPromotion(promotion)"
          >
            En profiter
          </button>
        </div>
      </div>
    </div>
  </div>
  <br />
</template>

<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useProductStore } from '~/stores/product_store.js'
import pinia from '~/stores/pinia.js'
import { router } from '@inertiajs/vue3'

const useStore = useProductStore(pinia())

onMounted(async () => {
  // Forcer le rafraîchissement des données
  await useStore.fetchPromotedProducts()
})

const activeTab = ref('tout')

const dynamicTabs = computed(() => {
  const categories = new Set(useStore.promotedProducts.map((promotion) => promotion.product?.category?.name || 'Sans catégorie'))
  return [{ id: 'tout', name: 'Tout' }, ...Array.from(categories).map((category) => ({ id: category, name: category }))]
})

const filteredPromotions = computed(() => {
  if (activeTab.value === 'tout') {
    return useStore.promotedProducts
  }
  return useStore.promotedProducts.filter((promotion) => promotion.product?.category?.name === activeTab.value)
})

const navigateToPromotion = (promotion: any) => {
  // Naviguer vers le produit associé à la promotion
  if (promotion.product?.slug) {
    router.get(`/catalogue/product/${promotion.product.slug}`)
  }
}

const getImageUrl = (promotion: any) => {
  // Si l'URL de la promotion existe, l'utiliser
  if (promotion.url) {
    // Si c'est une image de promotion uploadée, vérifier si elle existe
    if (promotion.url.includes('promotions/')) {
      return promotion.url
    }
    
    return promotion.url
  }
  
  // Sinon, utiliser une image par défaut
  return '/uploads/promotions/default-promotion.jpg'
}

const getPromoPrice = (promotion: any) => {
  if (!promotion.product) return '0'
  
  const originalPrice = promotion.product.price || 0
  const discountPercent = promotion.discountPercent || 0
  const promoPrice = originalPrice * (1 - discountPercent / 100)
  
  return Math.round(promoPrice).toLocaleString()
}

const getOriginalPrice = (promotion: any) => {
  if (!promotion.product) return '0'
  
  return (promotion.product.price || 0).toLocaleString()
}

const handleImageError = (event: Event) => {
  const img = event.target as HTMLImageElement
  
  // Fallback vers une image par défaut en cas d'erreur
  img.src = '/uploads/promotions/default-promotion.jpg'
}
</script>

<style scoped>
.scrollbar-hide {
  -ms-overflow-style: none;
  scrollbar-width: none;
}
.scrollbar-hide::-webkit-scrollbar {
  display: none;
}

.transition-transform {
  transition: transform 0.2s ease-in-out;
}
</style>
