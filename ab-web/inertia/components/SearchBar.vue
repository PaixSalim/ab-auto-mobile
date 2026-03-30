<template>
  <div class="w-full max-w-2xl mx-auto">
    <div class="relative flex flex-col justify-start items-center">
      <!-- Arrière-plan flou et plein écran -->
      <div
        v-if="isExpanded"
        class="fixed inset-0 bg-black/40 backdrop-blur-sm z-40"
        @click="closeSearch"
      ></div>

      <div
        class="w-full max-w-2xl sticky top-0 z-50 pt-4 pb-1"
        :class="isExpanded ? 'fixed inset-0 flex items-center justify-center' : ''"
      >
        <label class="sr-only text-xs font-medium text-gray-500 dark:text-gray-400 mb-1 block" for="search">
          Rechercher des pièces
        </label>

        <div class="relative w-full">
          <input
            type="text"
            placeholder="Rechercher une pièce ..."
            v-model="query"
            @focus="handleFocus"
            class="w-full bg-gray-100 py-3 px-12 text-sm rounded-lg border border-gray-200 md:(border-gray-300) focus:outline-none focus:ring-2 focus:ring-primary"
          />

          <div class="absolute left-4 top-1/2 transform -translate-y-1/2 h-4 w-4">
            <Transition name="icon" mode="out-in">
              <div v-if="!query.length" class="i-mdi-search w-5 h-5 text-gray-500" />
              <div v-else @click="clearSearch" class="i-line-md-close-small w-4 h-4 text-gray-500 cursor-pointer" />
            </Transition>
          </div>
        </div>
      </div>

      <div class="w-full max-w-2xl z-50">
        <Transition name="dropdown">
          <div
            v-if="isExpanded && filteredResults.length && !selectedResult"
            class="overflow-x-auto max-h-60 overflow-y-auto w-full border rounded-md shadow-sm bg-white mt-1 md:(max-h-100)"
          >
            <ul>
              <li
                v-for="result in filteredResults"
                :key="result.id"
                class="px-3 py-2 flex items-center justify-between hover:bg-gray-100 cursor-pointer rounded-md"
                @click="selectResult(result)"
              >
                <div class="flex items-center gap-2">
                  <img :src="result.medias[0].url" :alt="result.name" class="h-4 w-4" />
                  <span class="text-sm font-medium text-gray-900">{{ result.name.length > 15 ? result.name.substring(0, 15) + '...' : result.name }}</span>
                  <span class="text-xs text-gray-400">{{ result.category.name.length > 15 ? result.category.name.substring(0, 15) + '...' : result.category.name  }}</span>
                </div>
                <div class="flex items-center gap-2">
                  <span v-if="result.cta == ''" class="text-xs text-gray-400">{{ formatPrice(parseInt(result.price.toString())) }} F </span>
                  <span v-else class="text-xs text-gray-400">{{ result.cta }} </span>
                </div>
              </li>
            </ul>
            <div class="mt-2 px-3 py-2 border-t border-gray-100">
              <div class="flex items-center justify-between text-xs text-gray-500">
                <span>{{ filteredResults.length }} résultats</span>
                <span @click="closeSearch" class="cursor-pointer">ESC pour annuler</span>
              </div>
            </div>
          </div>
        </Transition>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted, onUnmounted } from 'vue'
import { useProductStore } from '~/stores/product_store'
import pinia from '~/stores/pinia'
import { GetProductDto } from '#dto/products_interface'
import { router } from '@inertiajs/vue3'
import { formatPrice } from '~/composables/format_price'

const useStore = useProductStore(pinia())


const query = ref('')
const isExpanded = ref(false)
const selectedResult = ref(null)
const debouncedQuery = ref('')
const clearSearch = () => {
  query.value = ''
}
// Fonction debounce pour optimiser la recherche
let debounceTimeout = null
watch(query, (newValue) => {
  clearTimeout(debounceTimeout)
  debounceTimeout = setTimeout(() => {
    debouncedQuery.value = newValue
  }, 200)
})


const filteredResults = computed(() => {
  let allResults = [...useStore.products]
  if (!debouncedQuery.value) {
    return allResults
  }
  const normalizedQuery = debouncedQuery.value.toLowerCase().trim()
  return allResults.filter((result) => {
    const searchableText = `${result.name} ${result.category}`.toLowerCase()
    return searchableText.includes(normalizedQuery)
  })
})

const emit = defineEmits(['clearSearch', 'isExpanded'])

// Gère l'ouverture et la fermeture
const handleFocus = () => {
  selectedResult.value = null
  isExpanded.value = true
  emit('isExpanded', true)
}

const closeSearch = () => {
  isExpanded.value = false
  emit('isExpanded', false)
  query.value = ''
}

// Sélectionne un résultat
const selectResult = (result: GetProductDto) => {
  router.get(`catalogue/product/${result.slug}`)
  query.value = result.name
  isExpanded.value = false
}

// Détecte la touche ESC pour fermer la recherche
const handleKeyDown = (event) => {
  if (event.key === 'Escape') {
    closeSearch()
  }
}

onMounted(() => {
  useStore.fetchProducts()
  document.addEventListener('keydown', handleKeyDown)
})

onUnmounted(() => {
  document.removeEventListener('keydown', handleKeyDown)
})
</script>

<style scoped>
/* Animation du dropdown */
.dropdown-enter-active, .dropdown-leave-active {
  transition: opacity 0.3s, transform 0.3s;
}
.dropdown-enter-from, .dropdown-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}

/* Animation des icônes */
.icon-enter-active, .icon-leave-active {
  transition: opacity 0.2s, transform 0.2s;
}
.icon-enter-from, .icon-leave-to {
  opacity: 0;
  transform: translateY(5px);
}
</style>
