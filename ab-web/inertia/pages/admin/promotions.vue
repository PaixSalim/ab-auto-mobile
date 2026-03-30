<template>
  <Layout>
    <PromotionManager :promos="promos" />
  </Layout>
</template>

<script setup lang="ts">
import Layout from '~/components/admin/Layout.vue'
import PromotionManager from '~/components/admin/promotions/PromotionManager.vue'
defineProps<{
  promos: any[]
}>()
</script>
