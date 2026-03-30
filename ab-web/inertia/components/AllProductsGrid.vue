<template>
  <div class="w-full">
    <!-- Section Header -->
    <div class="flex justify-between items-center mb-6 pb-4 border-b-2 border-gray-200">
      <h2 class="text-3xl font-black text-gray-900">Tous nos produits</h2>
      <a href="/catalogue" class="text-red-600 font-semibold hover:underline flex items-center gap-2">
        Voir plus →
      </a>
    </div>

    <!-- Category Filters -->
    <div class="flex gap-2 mb-6 overflow-x-auto pb-2 scrollbar-hide">
      <button
        @click="selectedCategory = null"
        :class="[
          'px-4 py-2 rounded-lg text-sm font-medium whitespace-nowrap transition-colors',
          selectedCategory === null
            ? 'bg-red-600 text-white'
            : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
        ]"
      >
        Tous
      </button>
      <button
        v-for="category in categories"
        :key="category.id"
        @click="selectedCategory = category.id"
        :class="[
          'px-4 py-2 rounded-lg text-sm font-medium whitespace-nowrap transition-colors',
          selectedCategory === category.id
            ? 'bg-red-600 text-white'
            : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
        ]"
      >
        {{ category.name }}
      </button>
    </div>

    <!-- Products Grid -->
    <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-4">
      <div
        v-for="product in filteredProducts.slice(0, 10)"
        :key="product.id"
        class="bg-white rounded-lg overflow-hidden shadow-md hover:shadow-xl transition-all duration-300 hover:-translate-y-1 cursor-pointer"
      >
        <div class="relative aspect-square">
          <img
            @click="navigateToProduct(product)"
            :src="product.medias && product.medias.length > 0 ? product.medias[0].url : 'https://via.placeholder.com/300'"
            :alt="product.name"
            class="w-full h-full object-cover hover:scale-105 transition-transform duration-300"
          />
          
          <!-- State Badge -->
          <span
            v-if="product.state === 'new'"
            class="absolute top-2 left-2 bg-green-600 text-white text-xs font-bold px-2 py-1 rounded"
          >
            Neuf
          </span>
          <span
            v-else
            class="absolute top-2 left-2 bg-blue-600 text-white text-xs font-bold px-2 py-1 rounded"
          >
            Occasion
          </span>
          
          <!-- Wishlist Button -->
          <button class="absolute top-2 right-2 bg-white/90 backdrop-blur-sm rounded-full w-8 h-8 flex items-center justify-center opacity-0 hover:opacity-100 transition-opacity duration-200">
            <span class="text-red-500">♡</span>
          </button>
        </div>

        <div class="p-3">
          <h3 @click="navigateToProduct(product)" class="font-semibold text-sm text-gray-900 line-clamp-2 mb-2 hover:text-red-600 transition-colors cursor-pointer">
            {{ product.name }}
          </h3>
          
          <p class="text-xs text-gray-600 line-clamp-2 mb-2">{{ product.description }}</p>
          
          <div class="flex items-center gap-1 text-xs text-gray-500 mb-2">
            <span class="i-mdi-tag"></span>
            <span>{{ product.category?.name }}</span>
          </div>

          <div class="flex items-center gap-2 mb-3">
            <span class="text-lg font-black text-red-600">
              {{ formatPrice(product.price) }} FCFA
            </span>
          </div>

          <div class="flex items-center gap-1 text-xs text-gray-500 mb-3">
            <span class="text-orange-500">★★★★☆</span>
            <span>{{ Math.floor(Math.random() * 500) + 50 }} vendus</span>
          </div>

          <button
            class="w-full bg-red-600 hover:bg-red-700 text-white font-bold py-2 px-3 rounded-lg transition-colors text-sm"
            @click="navigateToProduct(product)"
          >
            Voir détails
          </button>
        </div>
      </div>
    </div>

    <div v-if="filteredProducts.length === 0" class="text-center py-12">
      <p class="text-gray-500">Aucun produit disponible dans cette catégorie</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { router } from '@inertiajs/vue3'

interface Product {
  id: number
  name: string
  description: string
  price: number
  slug: string
  state: string
  category?: { id: number; name: string }
  medias?: { url: string }[]
}

interface Category {
  id: number
  name: string
}

const props = defineProps<{
  products: Product[]
  categories: Category[]
}>()

const selectedCategory = ref<number | null>(null)

const filteredProducts = computed(() => {
  if (selectedCategory.value === null) {
    return props.products
  }
  return props.products.filter(p => p.category?.id === selectedCategory.value)
})

function navigateToProduct(product: Product) {
  router.get(`/catalogue/product/${product.slug}`)
}

function formatPrice(price: number) {
  return new Intl.NumberFormat('fr-FR').format(price)
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
</style>
