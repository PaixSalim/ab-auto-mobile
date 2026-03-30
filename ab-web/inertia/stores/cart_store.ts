import { defineStore } from 'pinia'
import { ProductDto } from '#dto/products_interface'
import { ref } from 'vue'

export const useCartStore = defineStore('cart', () => {
  const items = ref<ProductDto[]>([])
  const initialize = () => {
    if (typeof window !== 'undefined' && window.localStorage) {
      const storedItemsValue = localStorage.getItem('cart')
      items.value = storedItemsValue ? JSON.parse(storedItemsValue) : []
    }
  }
  const addToCart = (product: ProductDto) => {
    items.value?.push(product)
    if (typeof window !== 'undefined' && window.localStorage) {
      localStorage.setItem('cart', JSON.stringify(items.value))
    }
  }
  const removeFromCart = (productId: number) => {
    if (typeof window !== 'undefined' && window.localStorage) {
      items.value = items.value.filter((item) => item.id !== productId)
      localStorage.setItem('cart', JSON.stringify(items.value))
    }
  }
  return {
    items,
    initialize,
    addToCart,
    removeFromCart,
  }
})
