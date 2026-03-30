<template>
  <div class="bg-gray-100 min-h-screen">
    <div class="container mx-auto px-4 py-6">
      <!-- Fil d'Ariane -->
      <div class="text-sm text-text-secondary mb-4">
        <span @click="router.get('/')" class="hover:text-primary cursor-pointer">Accueil</span> &gt;
        <span @click="resetFilters" class="hover:text-primary cursor-pointer">Catalogue</span>
      </div>

      <h1 class="text-2xl md:text-3xl font-bold text-text-title mb-6">Catalogue de pièces auto</h1>

      <!-- Barre de recherche et tri -->
      <div class="flex flex-col gap-y-2 md:(flex-row gap-4) mb-6">
        <div class="relative flex-grow">
          <input
            type="text"
            v-model="searchQuery"
            placeholder="Rechercher une pièce..."
            class="w-full pl-10 pr-4 py-2 rounded-md border focus:outline-none focus:border-primary"
          />
          <div
            class="i-mdi-magnify absolute left-3 top-1/2 transform -translate-y-1/2 text-text-secondary w-5 h-5"
          />
        </div>
        <div class="flex justify-between md:gap-3">
          <button
            @click="toggleFilters"
            class="lg:hidden px-4 py-2 border rounded-md flex items-center gap-2"
            :class="showMobileFilters ? 'bg-primary text-white border-primary' : 'bg-white text-text-secondary'"
          >
            <div class="i-line-md-filter w-5 h-5" />
            Filtres
            <span v-if="activeFiltersCount > 0" class="bg-state-error text-primary text-xs rounded-full w-5 h-5 flex items-center justify-center">
              {{ activeFiltersCount }}
            </span>
          </button>
          <select
            v-model="sortBy"
            class="px-2 py-2 rounded-md border border-background-tertiary focus:outline-none focus:border-primary bg-white"
          >
            <option value="popularity">Trier par</option>
            <option value="price_asc">Prix croissant</option>
            <option value="price_desc">Prix décroissant</option>
            <option value="newest">Nouveautés</option>
          </select>
          <button
            @click="toggleViewMode"
            class=" p-2 rounded-md border"
            :class="
              viewMode === 'grid'
                ? 'bg-primary text-white border-primary'
                : 'bg-white text-text-secondary border-background-tertiary'
            "
          >
            <div class="i-mdi-view-grid-outline w-5 h-5" />
          </button>
          <button
            @click="viewMode = 'list'"
            class="hidden md:block p-2 rounded-md border"
            :class="
              viewMode === 'list'
                ? 'bg-primary text-white border-primary'
                : 'bg-white text-text-secondary border-background-tertiary'
            "
          >
            <div class="i-line-md-list w-5 h-5" />
          </button>
        </div>
      </div>

      <div class="flex flex-col lg:flex-row gap-6">
        <div
          v-if="showMobileFilters"
          class="fixed inset-0 bg-black bg-opacity-50 z-40 lg:hidden"
          @click="showMobileFilters = false"
        ></div>

        <div
          :class="[
            'lg:w-1/4 transition-all duration-300 ease-in-out',
            'lg:relative lg:opacity-100 lg:translate-x-0 lg:pointer-events-auto',
            showMobileFilters
              ? 'fixed left-0 top-0 bottom-0 w-4/5 max-w-xs z-50 opacity-100 translate-x-0 pointer-events-auto'
              : 'fixed left-0 top-0 bottom-0 w-4/5 max-w-xs z-50 opacity-0 -translate-x-full pointer-events-none lg:pointer-events-auto'
          ]"
        >
          <div class="bg-white rounded-lg shadow-sm p-4 h-full overflow-y-auto">
            <!-- En-tête mobile avec bouton de fermeture -->
            <div class="flex justify-between items-center mb-4">
              <h2 class="text-lg font-semibold text-text-title">Filtres</h2>
              <div class="flex items-center gap-2">
                <button @click="resetFilters" class="text-sm text-primary hover:underline">
                  Réinitialiser
                </button>
                <button
                  @click="showMobileFilters = false"
                  class="lg:hidden p-1 rounded-full hover:(bg-primary text-white)"
                >
                  <div class="i-line-md-close-small w-5 h-5 text-text-secondary" />
                </button>
              </div>
            </div>

            <!-- Shimmer pour les filtres quand useStore.isLoading est true -->
            <template v-if="useStore.isLoading">
              <div class="mb-6">
                <ShimmerEffect height="24px" width="120px" class="mb-3" />
                <div class="space-y-3">
                  <ShimmerEffect height="20px" width="100%" v-for="i in 5" :key="`cat-${i}`" />
                </div>
              </div>

              <div class="mb-6">
                <ShimmerEffect height="24px" width="100px" class="mb-3" />
                <div class="space-y-3">
                  <ShimmerEffect height="20px" width="100%" v-for="i in 5" :key="`brand-${i}`" />
                </div>
              </div>

              <div class="mb-6">
                <ShimmerEffect height="24px" width="80px" class="mb-3" />
                <ShimmerEffect height="40px" width="100%" />
              </div>
            </template>

            <template v-else>
              <!-- Catégories -->
              <div class="mb-6">
                <h3 class="font-medium text-text-title mb-2">Catégories</h3>
                <div class="space-y-2">
                  <label
                    v-for="category in useStore.categories"
                    :key="category.id"
                    class="flex items-center cursor-pointer"
                  >
                    <input
                      type="checkbox"
                      :value="category.name"
                      v-model="selectedCategories"
                      class="rounded text-primary focus:ring-primary"
                    />
                    <span class="ml-2 text-text-body">{{ category.name }}</span>
                  </label>
                </div>
              </div>

              <!-- Marques -->
              <div class="mb-6">
                <h3 class="font-medium text-text-title mb-2">Marques</h3>
                <div class="space-y-2">
                  <label
                    v-for="brand in useStore.brands"
                    :key="brand.id"
                    class="flex items-center cursor-pointer"
                  >
                    <input
                      type="checkbox"
                      :value="brand.name"
                      v-model="selectedBrands"
                      class="rounded text-primary focus:ring-primary"
                    />
                    <span class="ml-2 text-text-body">{{ brand.name }}</span>
                  </label>
                </div>
              </div>

              <!-- Prix -->
              <div class="mb-6">
                <h3 class="font-medium text-text-title mb-2">Prix</h3>
                <div class="px-2">
                  <div class="flex justify-between text-sm text-text-secondary mb-2">
                    <span>{{ formatPrice(priceRange[0]) }} Fcfa</span>
                    <span>{{ formatPrice(priceRange[1]) }} Fcfa</span>
                  </div>
                  <div class="relative h-2 bg-background-tertiary rounded-full mb-4">
                    <div
                      class="absolute h-full bg-primary rounded-full"
                      :style="{
                        left: `${((priceRange[0] - 0) / 90000000) * 100}%`,
                        right: `${100 - ((priceRange[1] - 0) / 90000000) * 100}%`,
                      }"
                    ></div>
                  </div>
                  <div class="flex gap-4">
                    <input
                      type="number"
                      v-model.number="priceRange[0]"
                      min="0"
                      max="5000000"
                      @input="validatePriceRange(0)"
                      class="w-full p-2 text-sm border border-background-tertiary rounded-md"
                    />
                    <input
                      type="number"
                      v-model.number="priceRange[1]"
                      min="0"
                      max="5000000"
                      @input="validatePriceRange(1)"
                      class="w-full p-2 text-sm border border-background-tertiary rounded-md"
                    />
                  </div>
                </div>
              </div>

              <!-- État -->
              <div class="mb-6">
                <h3 class="font-medium text-text-title mb-2">État</h3>
                <div class="space-y-2">
                  <label class="flex items-center cursor-pointer">
                    <input
                      type="checkbox"
                      v-model="filters.new"
                      class="rounded text-primary focus:ring-primary"
                    />
                    <span class="ml-2 text-text-body">Neuf</span>
                  </label>
                  <label class="flex items-center cursor-pointer">
                    <input
                      type="checkbox"
                      v-model="filters.used"
                      class="rounded text-primary focus:ring-primary"
                    />
                    <span class="ml-2 text-text-body">Occasion</span>
                  </label>
                </div>
              </div>

              <!-- Bouton d'application des filtres -->
              <button
                @click="applyFilters"
                class="w-full mt-6 py-2 bg-primary hover:bg-primary-hover text-white rounded-md transition-colors"
              >
                Appliquer les filtres
              </button>

              <!-- Bouton de fermeture pour mobile (en bas) -->
              <button
                @click="showMobileFilters = false"
                class="lg:hidden w-full mt-4 py-2 border border-background-tertiary text-text-secondary rounded-md transition-colors"
              >
                Fermer
              </button>
            </template>
          </div>
        </div>

        <!-- Liste des produits -->
        <div class="lg:w-3/4">
          <!-- Nombre de résultats et pagination -->
          <div class="flex justify-between items-center mb-4">
            <p class="text-text-secondary">
              <template v-if="useStore.isLoading">
                <ShimmerEffect height="20px" width="120px" />
              </template>
              <template v-else> {{ filteredProducts.length }} produits trouvés </template>
            </p>
          </div>

          <!-- Shimmer pour les produits en mode grille -->
          <div
            v-if="useStore.isLoading && viewMode === 'grid'"
            class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4"
          >
            <div
              v-for="i in 9"
              :key="`grid-${i}`"
              class="bg-white rounded-lg shadow-sm overflow-hidden"
            >
              <ShimmerEffect height="200px" width="100%" radius="0" />
              <div class="p-4">
                <ShimmerEffect height="24px" width="80%" class="mb-2" />
                <ShimmerEffect height="16px" width="60%" class="mb-3" />
                <ShimmerEffect height="16px" width="40%" class="mb-4" />
                <div class="flex justify-between items-center">
                  <ShimmerEffect height="24px" width="30%" />
                  <ShimmerEffect height="36px" width="36px" radius="50%" />
                </div>
              </div>
            </div>
          </div>

          <!-- Shimmer pour les produits en mode liste -->
          <div v-if="useStore.isLoading && viewMode === 'list'" class="space-y-4">
            <div
              v-for="i in 5"
              :key="`list-${i}`"
              class="bg-white rounded-lg shadow-sm overflow-hidden"
            >
              <div class="flex flex-col sm:flex-row">
                <div class="sm:w-1/4">
                  <ShimmerEffect height="200px" width="100%" radius="0" />
                </div>
                <div class="p-4 sm:w-3/4">
                  <ShimmerEffect height="24px" width="70%" class="mb-2" />
                  <ShimmerEffect height="16px" width="40%" class="mb-3" />
                  <ShimmerEffect height="16px" width="90%" class="mb-2" />
                  <ShimmerEffect height="16px" width="80%" class="mb-4" />
                  <div class="flex justify-between items-center">
                    <ShimmerEffect height="24px" width="20%" />
                    <div class="flex gap-2">
                      <ShimmerEffect height="36px" width="100px" radius="6px" />
                      <ShimmerEffect height="36px" width="140px" radius="6px" />
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Affichage en grille -->
          <div
            v-if="!useStore.isLoading && viewMode === 'grid'"
            class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4"
          >
            <div
              v-for="product in paginatedProducts"
              :key="product.id"
              class="bg-white rounded-lg shadow-sm overflow-hidden hover:shadow-md transition-shadow"
            >
              <div @click="navigateToProduct(product)" class="relative cursor-pointer hover:(border border-primary border-rounded-lg)">
                <img
                  :src="product.medias?.[0]?.url || 'https://via.placeholder.com/400x300?text=Sans+image'"
                  :alt="product.name"
                />
                <span
                  v-if="product.discount"
                  class="absolute top-2 left-2 bg-state-error text-white bg-primary text-xs px-2 py-1 rounded-full"
                >
                  -{{ product.discount }}%
                </span>
              </div>
              <div class="p-4">
                <div class="flex justify-between items-start mb-2">
                  <h3 class="font-medium text-text-title">{{ product.name }}</h3>
                  <span
                    class="text-xs px-2 py-1 rounded"
                    :class="
                      product.state === 'new'
                        ? 'bg-primary-light text-primary'
                        : 'bg-secondary-light text-secondary'
                    "
                  >
                    {{ product.state === 'new' ? 'Neuf' : 'Occasion' }}
                  </span>
                </div>
                <img
                  class="w-14"
                  :src="product.brand.url"
                  :alt="product.brand.url"
                />
                <div class="flex justify-between items-center">
                  <div>
                    <span
                      v-if="product.discount"
                      class="text-text-secondary text-sm line-through mr-2"
                      >{{ formatPrice(parseInt(product.price.toString())) }} Fcfa</span
                    >
                    <span v-if="product.cta === ''" class="font-bold "
                      >{{ formatPrice(parseInt((product.price * (1 - product.discount / 100)).toString()))}} Fcfa</span
                    >

                    <span v-else class="font-bold ">
                      {{ product.cta }}
                    </span>

                  </div>
                  <button
                    class="p-2 rounded-full bg-primary-light text-primary hover:bg-primary hover:text-white transition-colors"
                    @click="navigateToProduct(product)"
                  >
                    <div class="i-mdi-eye-arrow-right-outline w-5 h-5" />
                  </button>
                </div>
              </div>
            </div>
          </div>



          <!-- Affichage en liste -->
          <div v-if="!useStore.isLoading && viewMode === 'list'" class="space-y-4">
            <div
              v-for="product in paginatedProducts"
              :key="product.id"
              class="bg-white rounded-lg shadow-sm overflow-hidden hover:shadow-md transition-shadow"
            >
              <div class="flex flex-col sm:flex-row">
                <div class="relative sm:w-1/4">
                  <img @click="navigateToProduct(product)"
                    :src="product.medias?.[0]?.url || 'https://via.placeholder.com/400x300?text=Sans+image'"
                    :alt="product.name"
                    class="w-full cursor-pointer h-48 sm:h-full object-cover hover:(border-primary border border-rounded-lg)"
                  />
                  <span
                    v-if="product.discount"
                    class="absolute top-2 left-2 bg-state-error text-white bg-primary rounded-full text-xs px-2 py-1 rounded"
                  >
                    -{{ product.discount }}%
                  </span>
                </div>
                <div class="p-4 sm:w-3/4 flex flex-col">
                  <div class="flex justify-between items-start mb-2">
                    <div>
                      <h3 class="font-medium text-text-title">{{ product.name }}</h3>
                      <img
                        class="w-14"
                        :src="product.brand.url"
                        :alt="product.brand.url"
                      />
                    </div>
                    <span
                      class="text-xs px-2 py-1 rounded"
                      :class="
                        product.state === 'new'
                          ? 'bg-primary-light text-primary'
                          : 'bg-secondary-light text-secondary'
                      "
                    >
                      {{ product.state === 'new' ? 'Neuf' : 'Occasion' }}
                    </span>
                  </div>
                  <p class="text-sm text-text-body my-2 flex-grow">{{ product.description.split('.')[0] }}</p>
                  <div class="flex justify-between items-center">
                    <div>
                      <span
                        v-if="product.discount"
                        class="text-text-secondary text-sm line-through mr-2"
                        >{{ formatPrice(parseInt(product.price.toString())) }} Fcfa</span
                      >
                      <span v-if="product.cta === ''" class="font-bold t md:text-lg"
                        >{{ formatPrice(parseInt((product.price * (1 - product.discount / 100)).toString()))}} Fcfa</span
                      >

                      <span v-else class="font-bold">
                        {{ product.cta }}
                      </span>
                    </div>
                    <div class="flex gap-2">
                      <button
                        class="px-4 py-2 rounded-md bg-primary-light text-primary hover:bg-primary hover:text-white transition-colors"
                        @click="navigateToProduct(product)"
                      >
                        Voir détails
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Pagination -->
          <div class="flex justify-center mt-8">
            <div v-if="useStore.isLoading" class="flex gap-2">
              <ShimmerEffect
                height="40px"
                width="40px"
                radius="6px"
                v-for="i in 5"
                :key="`page-${i}`"
              />
            </div>
            <div v-else class="flex items-center gap-1">
              <div class="flex items-center gap-1">
                <button
                  @click="currentPage = 1"
                  :disabled="currentPage === 1"
                  class="p-2 rounded-md border border-background-tertiary disabled:opacity-50"
                >
                  <div class="i-mdi-chevron-double-left w-5 h-5 text-text-secondary" />
                </button>
                <button
                  @click="currentPage > 1 && currentPage--"
                  :disabled="currentPage === 1"
                  class="p-2 rounded-md border border-background-tertiary disabled:opacity-50"
                >
                  <div class="i-mdi-chevron-left w-5 h-5 text-text-secondary" />
                </button>

                <button
                  v-for="page in displayedPages"
                  :key="page"
                  @click="currentPage = page"
                  class="w-10 h-10 flex items-center justify-center rounded-md border"
                  :class="
                    currentPage === page
                      ? 'bg-primary text-white border-primary'
                      : 'border-background-tertiary text-text-body'
                  "
                >
                  {{ page }}
                </button>

                <button
                  @click="currentPage < totalPages && currentPage++"
                  :disabled="currentPage === totalPages"
                  class="p-2 rounded-md border border-background-tertiary disabled:opacity-50"
                >
                  <div class="i-mdi-chevron-right w-5 h-5 text-text-secondary" />
                </button>
                <button
                  @click="currentPage = totalPages"
                  :disabled="currentPage === totalPages"
                  class="p-2 rounded-md border border-background-tertiary disabled:opacity-50"
                >
                  <div class="i-mdi-chevron-double-right w-4 h-4 text-text-secondary" />
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { GetProductDto, ProductState } from '#dto/products_interface'
import ShimmerEffect from '~/components/shimmer/ShimmerEffect.vue'
import { useProductStore } from '~/stores/product_store'
import pinia from '~/stores/pinia'
import { router } from '@inertiajs/vue3'
import { formatPrice } from '~/composables/format_price'

const props = defineProps<{
  categoryName?: string
  brandName?: string
}>()
const useStore = useProductStore(pinia())

const showMobileFilters = ref(false);

const toggleFilters = () => {
  showMobileFilters.value = !showMobileFilters.value;
};

const handleResize = () => {
  if (window.innerWidth >= 1024 && showMobileFilters.value) {
    showMobileFilters.value = false;
    document.body.style.overflow = '';
  }
};

const toggleViewMode = () => {
  viewMode.value = viewMode.value === 'grid' ? 'list' : 'grid'
}

onBeforeUnmount(() => {
  window.removeEventListener('resize', handleResize);
});

const activeFiltersCount = computed(() => {
  let count = 0;

  if (selectedCategories.value.length > 0) count++;
  if (selectedBrands.value.length > 0) count++;
  if (priceRange.value[0] > 0 || priceRange.value[1] < 90000000) count++;
  if (filters.value.new || filters.value.used) count++;

  return count;
})

onMounted(() => {
  window.addEventListener('resize', handleResize);
  if (useStore.products.length === 0) {
    useStore.fetchProducts()
  }
  if (useStore.categories.length === 0) {
    useStore.fetchCategories()
  }
  if (useStore.brands.length === 0) {
    useStore.fetchBrands()
  }
  if (props.categoryName) {
    selectedCategories.value.push(props.categoryName)
  }
  if (props.brandName) {
    selectedBrands.value.push(props.brandName)
  }
})

const viewMode = ref('list')
const searchQuery = ref('')
const sortBy = ref('popularity')
const currentPage = ref(1)
const itemsPerPage = ref(9)
const selectedCategories = ref<string[]>([])
const selectedBrands = ref<string[]>([])
const priceRange = ref([0, 90000000])
const validatePriceRange = (index: number) => {
  if (priceRange.value[index] < 0) {
    priceRange.value[index] = 0
  }
  if (priceRange.value[index] > 90000000) {
    priceRange.value[index] = 90000000
  }
}
const filters = ref({
  new: false,
  used: false,
})

const filteredProducts = computed(() => {
  let result = [...useStore.products]
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    result = result.filter(
      (product) =>
        product.name.toLowerCase().includes(query) ||
        product.brand.name.toLowerCase().includes(query) ||
        product.description.toLowerCase().includes(query)
    )
  }

  if (selectedCategories.value.length > 0) {
    result = result.filter((product) => selectedCategories.value.includes(product.category.name))
  }

  if (selectedBrands.value.length > 0) {
    result = result.filter((product) => selectedBrands.value.includes(product.brand.name))
  }

  result = result.filter(
    (product) => product.price >= priceRange.value[0] && product.price <= priceRange.value[1]
  )

  if (filters.value.new && !filters.value.used) {
    result = result.filter((product) => product.state === ProductState.NEW)
  } else if (!filters.value.new && filters.value.used) {
    result = result.filter((product) => product.state === ProductState.OLD)
  }

  switch (sortBy.value) {
    case 'price_asc':
      result.sort((a, b) => a.price - b.price)
      break
    case 'price_desc':
      result.sort((a, b) => b.price - a.price)
      break
    case 'new':
      result.sort((a, b) => b.id - a.id)
      break
    default:
      break
  }

  return result
})

const totalPages = computed(() => Math.ceil(filteredProducts.value.length / itemsPerPage.value))

const paginatedProducts = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return filteredProducts.value.slice(start, end)
})

const displayedPages = computed(() => {
  const pages = []
  const maxPagesToShow = 5

  if (totalPages.value <= maxPagesToShow) {
    for (let i = 1; i <= totalPages.value; i++) {
      pages.push(i)
    }
  } else {
    let startPage = Math.max(1, currentPage.value - Math.floor(maxPagesToShow / 2))
    let endPage = startPage + maxPagesToShow - 1

    if (endPage > totalPages.value) {
      endPage = totalPages.value
      startPage = Math.max(1, endPage - maxPagesToShow + 1)
    }

    for (let i = startPage; i <= endPage; i++) {
      pages.push(i)
    }
  }

  return pages
})
const resetFilters = () => {
  selectedCategories.value = []
  selectedBrands.value = []
  priceRange.value = [0, 90000000]
  filters.value = {
    new: false,
    used: false,
  }
  searchQuery.value = ''
  currentPage.value = 1
}

let applyFilters = () => {
  currentPage.value = 1
}

const navigateToProduct = (product: GetProductDto) => {
  router.get(`/catalogue/product/${product.slug}`)
}

watch([searchQuery, sortBy, selectedCategories, selectedBrands, priceRange, filters], () => {
  currentPage.value = 1
})

const simulateLoading = () => {
  useStore.isLoading = true
  setTimeout(() => {
    useStore.isLoading = false
  }, 1000)
}

const originalApplyFilters = applyFilters
applyFilters = () => {
  simulateLoading()
  originalApplyFilters()
}
</script>
