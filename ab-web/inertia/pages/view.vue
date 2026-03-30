<script setup lang="ts">
import ProductDetail from '~/components/product/ProductDetail.vue'
import ProductComments from '~/components/product/ProductComments.vue'
import { GetProductDto } from '#dto/products_interface'
import { Head } from '@inertiajs/vue3'

interface Comment {
  id: number
  user: string
  comment: string
  isActive: boolean
  createdAt: string
  replies?: Comment[]
}

defineProps<{
  product: GetProductDto,
  similarProducts: GetProductDto[],
  comments: Comment[]
}>()

</script>

<template>
  <Head>
    <title>{{ product.name }}</title>
  </Head>
  <ProductDetail :product="product" :similarProducts="similarProducts" />
  <div class="container mx-auto px-4">
    <ProductComments :product-id="product.id" :comments="comments" />
  </div>
</template>

<style scoped>

</style>
