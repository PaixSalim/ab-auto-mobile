<template>
  <Layout>
    <ProductDashboard :products="products" :categories="categories" :brands="brands" />
  </Layout>
</template>

<script setup lang="ts">
import Layout from '~/components/admin/Layout.vue'
import ProductDashboard from '~/components/admin/product/ProductDashboard.vue'
import { GetProductDto } from '#dto/products_interface'
import { BrandsDto } from '#dto/brands_interface'
import { CategoryDto } from '#dto/category_dto'
defineProps<{
  products: GetProductDto[],
  categories: CategoryDto[],
  brands: BrandsDto[]
}>()
</script>
