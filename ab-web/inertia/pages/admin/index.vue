<template>
  <Layout>
    <Dashboard 
      :products="products || 0" 
      :orders="orders || 0" 
      :promotions="promotions || 0" 
      :sellers="sellers || 0" 
      :customers="customers || 0" 
      :pendingValidations="pendingValidations || 0" 
    />
  </Layout>
</template>

<script setup lang="ts">
import Dashboard from '~/components/admin/dashboard/Dashboard.vue'
import Layout from '~/components/admin/Layout.vue'

defineProps<{
  products?: number
  orders?: number
  promotions?: number
  sellers?: number
  customers?: number
  pendingValidations?: number
}>()
</script>
