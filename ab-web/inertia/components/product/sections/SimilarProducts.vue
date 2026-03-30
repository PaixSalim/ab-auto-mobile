<script setup lang="ts">
import { GetProductDto } from '#dto/products_interface'
import { getRealPrice } from '~/composables/use_price'
import { router } from '@inertiajs/vue3'
import { formatPrice } from '../../../composables/format_price'
defineProps<{
  similarProducts: GetProductDto[]}>()
</script>

<template>
  <div v-if="similarProducts.length > 0" class="mt-10 mx-4">
    <h2 class="text-xl font-bold mb-6">Produits similaires</h2>
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
      <div
        v-for="p in similarProducts"
        :key="p.id"
        class="bg-white rounded-lg shadow-sm overflow-hidden hover:shadow-md transition-shadow"
      >
        <div class="relative">
          <img :src="p.medias?.[0]?.url || '/placeholder.jpg'" @click="router.get(`/catalogue/product/${p.slug}`)" :alt="p.name" class="w-full h-48 object-cover cursor-pointer hover:(border-primary border border-rounded-lg)" />
          <span v-if="p.discount > 0" class="absolute top-2 left-2 bg-state-error text-white bg-primary rounded-full font-semibold px-1 text-xs px-2 py-1 rounded">-{{ p.discount }} %</span>
        </div>
        <div class="p-4">
          <h3 class="font-medium text-text-title mb-1">{{ p.name }}</h3>
          <p class="text-sm text-text-secondary mb-2">{{ p.brand.name }}</p>

          <div class="flex justify-between items-center">
            <div v-if="p.cta === ''">
              <span class="font-bold">{{ formatPrice(getRealPrice(p.price, p.discount)) }} Fcfa</span>
              <span v-if="p.discount > 0" class="line-through px-3 text-gray-500"> {{ formatPrice(p.price) }} Fcfa</span>
            </div>
            <div v-else class="font-bold"> {{ p.cta }}</div>
            <button @click="router.get(`/catalogue/product/${p.slug}`)" class="p-2 rounded-full bg-primary-light text-primary hover:bg-primary hover:text-white transition-colors">
              <div class="i-mdi-cart-variant w-5 h-5" />
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>

</style>
