<template>
  <section class="w-full">
    <div v-if="useStore.categories.length > 0" class="py-8">
      <!-- Section Header -->
      <div class="flex justify-between items-center mb-6 pb-4 border-b-2 border-gray-200">
        <h2 class="text-3xl font-black text-gray-900">Toutes les catégories</h2>
        <a href="/catalogue" class="text-red-600 font-semibold hover:underline">Tout voir →</a>
      </div>

      <!-- Categories Grid -->
      <div class="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 xl:grid-cols-8 gap-4">
        <div
          v-for="category in useStore.categories"
          :key="category.id"
          class="bg-white rounded-xl p-4 text-center hover:bg-red-600 hover:text-white transition-all cursor-pointer shadow-md hover:shadow-xl hover:-translate-y-1"
          @click="openBrandModal(category)"
          @mouseenter="fetchBrandByCategory(category)"
        >
          <!-- Category Icon -->
          <div class="text-3xl mb-3">
            <img
              :src="category.url"
              :alt="category.name"
              class="w-12 h-12 md:w-16 md:h-16 mx-auto object-contain transition-all duration-300"
            />
          </div>

          <!-- Category Info -->
          <div class="text-center">
            <h3 class="text-sm font-semibold line-clamp-1">
              {{ category.name.length > 15 ? category.name.substring(0, 15) + '...' : category.name }}
            </h3>
            <span class="text-xs opacity-75">{{ category.items }} produits</span>
          </div>
        </div>
      </div>

      <!-- Brand Selection Modal -->
      <TransitionRoot appear :show="isModalOpen" as="template">
        <Dialog as="div" @close="closeModal" class="relative z-50">
          <TransitionChild
            as="template"
            enter="duration-300 ease-out"
            enter-from="opacity-0"
            enter-to="opacity-100"
            leave="duration-200 ease-in"
            leave-from="opacity-100"
            leave-to="opacity-0"
          >
            <div class="fixed inset-0 bg-black/30 backdrop-blur-sm" />
          </TransitionChild>

          <div class="fixed inset-0 overflow-y-auto">
            <div class="flex min-h-full items-center justify-center p-4">
              <TransitionChild
                as="template"
                enter="duration-300 ease-out"
                enter-from="opacity-0 scale-95"
                enter-to="opacity-100 scale-100"
                leave="duration-200 ease-in"
                leave-from="opacity-100 scale-100"
                leave-to="opacity-0 scale-95"
              >
                <DialogPanel class="w-full max-w-4xl bg-white rounded-2xl overflow-hidden shadow-xl transform transition-all">
                  <div class="relative">
                    <!-- Header -->
                    <div class="px-6 py-4 border-b border-gray-200 bg-red-600 text-white">
                      <DialogTitle class="text-xl font-semibold">
                        Sélectionnez votre marque - {{ selectedCategory?.name }}
                      </DialogTitle>
                      <button
                        @click="closeModal"
                        class="absolute top-4 right-4 text-white/80 hover:text-white transition-colors"
                      >
                        <XIcon class="w-6 h-6" />
                      </button>
                    </div>

                    <!-- Content -->
                    <div class="px-6 py-6">
                      <!-- Search Bar -->
                      <div class="relative mb-6">
                        <input
                          type="text"
                          v-model="searchQuery"
                          placeholder="Rechercher une marque..."
                          class="w-full px-4 py-3 pl-12 bg-gray-100 rounded-lg focus:outline-none focus:ring-2 focus:ring-red-600 text-gray-900 placeholder-gray-500"
                        />
                        <SearchIcon class="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
                      </div>

                      <!-- Brands Grid -->
                      <div class="grid grid-cols-3 sm:grid-cols-4 md:grid-cols-6 gap-4">
                        <button
                          v-for="brand in filteredBrands"
                          :key="brand.id"
                          @click="selectBrand(brand)"
                          @mouseenter="hoverBrand(brand)"
                          class="flex flex-col items-center p-4 rounded-lg hover:bg-red-50 transition-colors group"
                        >
                          <div class="w-16 h-16 flex items-center justify-center mb-2 bg-white rounded-lg p-2 group-hover:shadow-md transition-shadow">
                            <img :src="brand.url" :alt="brand.name" class="w-full h-full object-contain" />
                          </div>
                          <span class="text-sm text-center font-medium text-gray-700 group-hover:text-red-600 transition-colors">{{ brand.name }}</span>
                        </button>
                      </div>
                    </div>

                    <!-- Footer -->
                    <div class="px-6 py-4 bg-gray-50 border-t border-gray-200">
                      <p class="text-sm text-gray-600">
                        Catégorie: <span class="font-semibold text-red-600">{{ selectedCategory?.name }}</span>
                      </p>
                    </div>
                  </div>
                </DialogPanel>
              </TransitionChild>
            </div>
          </div>
        </Dialog>
      </TransitionRoot>
    </div>
  </section>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { Dialog, DialogPanel, DialogTitle, TransitionRoot, TransitionChild } from '@headlessui/vue'
import { XIcon, SearchIcon } from 'lucide-vue-next'
import pinia from '~/stores/pinia'
import { CategoryDto } from '#dto/category_dto'
import { useProductStore } from '~/stores/product_store'
import { router } from '@inertiajs/vue3'
import { BrandsDto } from '#dto/brands_interface'

const useStore = useProductStore(pinia())
onMounted(() => {
  useStore.fetchCategories()
})

const isModalOpen = ref(false)
const selectedCategory = ref<CategoryDto>()
const searchQuery = ref('')

const filteredBrands = computed(() => {
  if (!searchQuery.value) return useStore.currentBrands
  const query = searchQuery.value.toLowerCase()
  return useStore.currentBrands.filter(brand => brand.name.toLowerCase().includes(query))
})

/**
 * Fetching data on hover
 * @param category
 */
const fetchBrandByCategory = async (category: CategoryDto) => {
  selectedCategory.value = category
  await useStore.fetchBrandByCategory(category.id)
}

const openBrandModal = async (category: CategoryDto) => {
  selectedCategory.value = category
 await fetchBrandByCategory(category)
  isModalOpen.value = true
}

const closeModal = () => {
  isModalOpen.value = false
  searchQuery.value = ''
}

const hoverBrand = async (_brand: BrandsDto) => {
  if (useStore.products.length === 0) {
    await useStore.fetchProducts()
  }
}

const selectBrand = async (brand: BrandsDto) => {
  await useStore.fetchProducts()
  router.get('/catalogue', {
    category: selectedCategory.value!.name,
    brand: brand.name,
  })
  closeModal()
}
</script>

<style scoped>

</style>
