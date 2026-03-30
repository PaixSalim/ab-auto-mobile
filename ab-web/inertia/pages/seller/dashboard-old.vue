<template>
  <Layout>
    <Dashboard :products="stats.products" :orders="stats.orders" :comments="stats.comments" />
  </Layout>
</template>

<script setup lang="ts">
import Layout from '~/components/seller/Layout.vue'
import Dashboard from '~/components/seller/dashboard/Dashboard.vue'

interface Stats {
  products: number
  orders: number
  comments: number
}

defineProps<{
  stats: Stats
}>()
</script>
