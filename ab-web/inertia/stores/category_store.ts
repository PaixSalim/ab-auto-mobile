import { defineStore } from 'pinia'
import { ref } from 'vue'
import { GetCategoryDto } from '#dto/category_dto'
import { GetBrandsDto } from '#dto/brands_interface'
import { GetProductDto } from '#dto/products_interface'

export const useCategoryStore = defineStore('categories', () => {
  const categories = ref<GetCategoryDto[]>([])
  const products = ref<GetProductDto[]>([])
  const brands = ref<GetBrandsDto[]>([])
  const currentBrands = ref<GetBrandsDto[]>([])
  const initialize = async () => {
    await fetchCategories()
    //brands.value = await fetchBrands()
    //products.value = await fetchAllProducts()
  }
  const fetchCategories = async () => {
    try {
      const response = await fetch('/api/v1/categories', {
        method: 'GET',
      })
      categories.value = await response.json()
    } catch (e) {}
  }
  const fetchBrandByCategory = async (categoryId: number) => {
    try {
      const response = await fetch(`/api/v1/brand/spec?categoryId=${categoryId}`, {
        method: 'GET',
      })
      const data: GetBrandsDto[] = await response.json()
      if (data.length > 0) {
        currentBrands.value = data
      }
    } catch (e) {}
  }
  const fetchBrands = async () => {
    try {
      const response = await fetch(`/api/v1/brand`, {
        method: 'GET',
      })
      const data: GetBrandsDto[] = await response.json()
      if (data.length > 0) {
        brands.value = data
      }
    } catch (e) {}
  }
  const fetchAllProducts = async () => {
    try {
      const response = await fetch('/api/v1/products', {
        method: 'GET',
      })
      const data: GetProductDto[] = await response.json()
      if (data.length > 0) {
        products.value = data
      }
    } catch (e) {}
  }
  return {
    categories,
    brands,
    currentBrands,
    products,
    initialize,
    fetchBrandByCategory,
    fetchAllProducts,
    fetchCategories,
    fetchBrands,
  }
})
