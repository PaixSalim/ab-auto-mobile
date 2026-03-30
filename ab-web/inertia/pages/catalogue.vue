<script setup lang="ts">

import ProductCatalogue from '~/components/product/ProductCatalogue.vue'
defineProps<{
  categoryName?: string
  brandName?: string
}>()
</script>

<template>
<ProductCatalogue :categoryName="categoryName" :brandName="brandName" />
</template>

<style scoped>

</style>
