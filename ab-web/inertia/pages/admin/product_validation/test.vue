<script setup lang="ts">
import Layout from '~/components/admin/Layout.vue'

const props = defineProps<{
  products: any[]
  error?: string
}>()
</script>

<template>
  <Layout>
    <div class="p-6">
      <h1 class="text-2xl font-bold text-white mb-6">Test Validation</h1>
      
      <div v-if="error" class="bg-red-500 text-white p-4 rounded mb-4">
        Erreur: {{ error }}
      </div>
      
      <div class="bg-gray-800 p-4 rounded">
        <p class="text-white mb-2">Nombre de produits: {{ products.length }}</p>
        <p class="text-gray-400">Si vous voyez cette page, la route fonctionne!</p>
      </div>
      
      <div v-if="products.length > 0" class="mt-4">
        <h3 class="text-white mb-2">Produits trouvés:</h3>
        <div v-for="product in products" :key="product.id" class="bg-gray-700 p-2 mb-2 rounded">
          <p class="text-white">{{ product.name }} (ID: {{ product.id }})</p>
        </div>
      </div>
    </div>
  </Layout>
</template>
