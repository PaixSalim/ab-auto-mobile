<template>
  <div class="p-8">
    <h1 class="text-3xl font-bold mb-4">Dashboard Vendeur - Nouveau</h1>
    <div class="bg-white p-6 rounded-lg shadow">
      <h2 class="text-xl mb-4">Statistiques</h2>
      <div class="grid grid-cols-3 gap-4">
        <div class="bg-blue-100 p-4 rounded">
          <h3 class="font-bold">Produits</h3>
          <p class="text-2xl">{{ stats?.products || 0 }}</p>
        </div>
        <div class="bg-green-100 p-4 rounded">
          <h3 class="font-bold">Commandes</h3>
          <p class="text-2xl">{{ stats?.orders || 0 }}</p>
        </div>
        <div class="bg-purple-100 p-4 rounded">
          <h3 class="font-bold">Commentaires</h3>
          <p class="text-2xl">{{ stats?.comments || 0 }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
interface Stats {
  products: number
  orders: number
  comments: number
}

const props = defineProps<{
  stats?: Stats
  recentProducts?: any[]
}>()

// Logs pour déboguer
</script>
