import { defineStore } from 'pinia'
import { ref } from 'vue'
import { CTAType, GetProductDto, ProductState } from '#dto/products_interface'
import { GetCategoryDto } from '#dto/category_dto'
import { BrandsDto, GetBrandsDto } from '#dto/brands_interface'
import { GetPromotedProductsDto } from '#dto/promoted_products_dto'

export const useProductStore = defineStore('product_store', () => {
  const isLoading = ref(true)
  const products = ref<GetProductDto[]>([])
  const categories = ref<GetCategoryDto[]>([])
  const catID = ref<number>(0)
  const brands = ref<BrandsDto[]>([])
  const currentBrands = ref<GetBrandsDto[]>([])
  const promotedProducts = ref<GetPromotedProductsDto[]>([])
  const currentProduct = ref<GetProductDto>({
    id: 0,
    cta: CTAType.NONE,
    name: '',
    warranty: '',
    features: [''],
    slug: '',
    promo_price: 0,
    brand: {
      id: 0,
      name: '',
      url: '',
    },
    category: {
      id: 0,
      name: '',
      url: '',
    },
    state: ProductState.NEW,
    price: 0,
    discount: 0,
    description: '',
    medias: [],
  })
  const fetchOneProduct = async (productId: number) => {
    isLoading.value = true
    try {
      const response = await fetch(`/api/v1/product/${productId}`, {
        method: 'GET',
      })
      currentProduct.value = await response.json()
    } catch (e) {
    } finally {
      isLoading.value = false
    }
  }
  /**
   * Fetches the list of products from the API and ensures that the loading
   * spinner (or shimmer animation) is displayed for at least 1 second.
   *
   * @async
   * @function fetchProducts
   * @returns {Promise<void>} Resolves when products are loaded and the loading animation completes.
   */
  const fetchProducts = async (): Promise<void> => {
    isLoading.value = true
    const startTime = Date.now()

    try {
      const response = await fetch('/api/v1/products-web')

      if (!response.ok) {
      } else {
        products.value = await response.json()
        //console.log(products.value)
      }
    } catch (err) {
    }

    const elapsedTime = Date.now() - startTime
    const remainingTime = Math.max(1000 - elapsedTime, 0)

    await new Promise((resolve) => setTimeout(resolve, remainingTime))

    isLoading.value = false
  }

  const fetchCategories = async () => {
    isLoading.value = true
    try {
      const response = await fetch('/api/v1/categories', {
        method: 'GET',
      })
      if (!response.ok) {
      }
      categories.value = await response.json()
    } catch (e) {
    } finally {
      isLoading.value = false
    }
  }
  const fetchBrands = async () => {
    isLoading.value = true
    try {
      const response = await fetch('/api/v1/brands')
      if (!response.ok) {
      } else {
        brands.value = await response.json()
      }
    } catch (e) {
    }
    isLoading.value = false
  }

  const fetchBrandByCategory = async (categoryId: number) => {
    if (categoryId !== catID.value) {
      isLoading.value = true
      try {
        const response = await fetch(`/api/v1/brand/spec?categoryId=${categoryId}`, {
          method: 'GET',
        })
        if (!response.ok) {
        } else {
          currentBrands.value = await response.json()
          catID.value = categoryId
        }
      } catch (e) {
      } finally {
        isLoading.value = false
      }
    }
  }

  const fetchPromotedProducts = async () => {
    isLoading.value = true
    try {
      const response = await fetch('/api/v1/promotions', {
        method: 'GET',
      })
      if (!response.ok) {
      } else {
        promotedProducts.value = await response.json()
      }
    } catch (e) {
    } finally {
      isLoading.value = false
    }
  }
  const addCurrentProduct = (data: GetProductDto) => {
    currentProduct.value = data
  }

  const getSimilarProducts = (product: GetProductDto) => {
    return products.value.filter(
      (p) => p.category.name === product.category.name && p.brand.name === product.brand.name
    )
  }
  return {
    isLoading,
    products,
    categories,
    brands,
    currentBrands,
    currentProduct,
    promotedProducts,
    getSimilarProducts,
    fetchOneProduct,
    fetchCategories,
    fetchBrands,
    fetchBrandByCategory,
    fetchProducts,
    fetchPromotedProducts,
    addCurrentProduct,
  }
})
