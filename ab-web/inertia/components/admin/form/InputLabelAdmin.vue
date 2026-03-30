<script setup lang="ts">
import { BrandsDto } from '#dto/brands_interface'
import { CategoryDto } from '#dto/category_dto'
import { CTAType, GetProductDto } from '#dto/products_interface'

defineProps<{
  label: string
  name: string
  id: string
  placeholder: string
  type: string
  cta?: string
  categories?: CategoryDto[]
  brands?: BrandsDto[]
  state?: string[]
  products?: GetProductDto[]
  required?: boolean
}>()

const categoryId = defineModel('categoryId')
const nameModel = defineModel('nameModel')
const ctaModel = defineModel('ctaModel')
</script>

<template>
  <div class="mb-3">
    <label :for="id" class="text-gray-300 font-bold mb-2 text-sm block">{{ label }}</label>
    <input
      v-if="type !== 'select'"
      v-model="nameModel"
      :id="id"
      :name="name"
      :type="type"
      class="w-full text-white bg-background-secondary mt-2 rounded-lg p-3 focus:(ring-primary ring-2 outline-none)"
      :placeholder="placeholder"
      :required="required"
    />
    <select
      v-else-if="categories"
      v-model="categoryId"
      class="w-full text-white bg-background-secondary mt-2 rounded-lg p-3 focus:(ring-primary ring-2 outline-none)"
      :required="required"
    >
      <option value="">Sélectionner</option>
      <option v-for="category in categories" :key="category.id" :value="category.id">
        {{ category.name }}
      </option>
    </select>
    <select
      v-else-if="brands"
      v-model="categoryId"
      class="w-full text-white bg-background-secondary mt-2 rounded-lg p-3 focus:(ring-primary ring-2 outline-none)"
      :required="required"
    >
      <option value="">Sélectionner</option>
      <option v-for="brand in brands" :key="brand.id" :value="brand.id">
        {{ brand.name }}
      </option>
    </select>
    <select
      v-else-if="state"
      v-model="categoryId"
      class="w-full text-white bg-background-secondary mt-2 rounded-lg p-3 focus:(ring-primary ring-2 outline-none)"
      :required="required"
    >
      <option value="">Sélectionner</option>
      <option key="neuf" value="new">Neuf</option>
      <option key="old" value="old">Occasion</option>
    </select>
    <select
      v-else-if="cta"
      v-model="ctaModel"
      class="w-full text-white bg-background-secondary mt-2 rounded-lg p-3 focus:(ring-primary ring-2 outline-none)"
      :required="required"
    >
      <option value="">Sélectionner</option>
      <option key="ask" :value="CTAType.ASK">{{ CTAType.ASK }}</option>
      <option key="book" :value="CTAType.BOOK">{{ CTAType.BOOK }}</option>
      <option key="rdv" :value="CTAType.RDV">{{ CTAType.RDV }}</option>
    </select>
    <select
      v-else-if="products"
      v-model="categoryId"
      class="w-full text-white bg-background-secondary mt-2 rounded-lg p-3 focus:(ring-primary ring-2 outline-none)"
      :required="required"
    >
      <option value="-1">Sélectionner un produit</option>
      <option v-for="product in products" :key="product.id" :value="product.id">{{ product.name }}</option>
    </select>
  </div>
</template>

<style scoped></style>
