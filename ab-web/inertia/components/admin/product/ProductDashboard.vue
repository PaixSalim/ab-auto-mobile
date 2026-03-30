<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref, watch } from 'vue'
import CreateProductModal from '~/components/admin/product/CreateProductModal.vue'
import EditProductModal from '~/components/admin/product/EditProductModal.vue'
import ShowProduct from '~/components/admin/product/ShowProduct.vue'
import { router } from '@inertiajs/vue3'
import MessagePopup from '~/components/admin/product/MessagePopup.vue'
import { GetProductDto, MediaType } from '#dto/products_interface'
import { BrandsDto } from '#dto/brands_interface'
import { CategoryDto } from '#dto/category_dto'
import Pagination from '~/components/admin/Pagination.vue'

const props = defineProps<{
  products: GetProductDto[]
  categories: CategoryDto[]
  brands: BrandsDto[]
}>()

enum PopupType {
  ERROR = 'error',
  WARNING = 'warning',
  SUCCESS = 'success',
}
const showMessagePopup = ref(false)
const popupMessage = ref('')
const popupType = ref<PopupType>(PopupType.SUCCESS)

const successModifyCallback = (message: string) => {
  showModal.value = false
  popupType.value = PopupType.SUCCESS
  showMessagePopup.value = true
  popupMessage.value = message
  setTimeout(() => {
    showMessagePopup.value = false
  }, 3000)
}

const errorModifyCallback = (message: string) => {
  showModal.value = false
  popupType.value = PopupType.ERROR
  showMessagePopup.value = true
  popupMessage.value = message
  setTimeout(() => {
    showMessagePopup.value = false
  }, 5000)
}

const closeCallbackModal = () => {
  showMessagePopup.value = false
}

// State
const modalModeProduct = ref<GetProductDto>()
const showModal = ref(false)
const modalMode = ref('view') // 'view' | 'create' | 'edit'
const formData = ref<GetProductDto>()
const showDeleteConfirm = ref(false)
const productToDelete = ref<GetProductDto>()

// Computed
const modalTitle = computed(() => {
  switch (modalMode.value) {
    case 'create':
      return 'Ajouter un nouveau Produit'
    case 'edit':
      return 'Modifier un Produit'
    case 'view':
      return 'Details des produits'
    default:
      return ''
  }
})

// Methods
const formatPrice = (product: GetProductDto) => {
  return (product.price * (1 - product.discount / 100)).toFixed(2)
}

const openModal = (mode: string, product?: GetProductDto) => {
  modalMode.value = mode
  modalModeProduct.value = product
  if (product) {
    formData.value = product
  } else {
  }
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
}

const confirmDelete = (product: GetProductDto) => {
  productToDelete.value = product
  showDeleteConfirm.value = true
}

const deleteProduct = () => {
  const name = productToDelete.value!.name
  const id = productToDelete.value?.id
  const url = `/admin/product/delete/${id}`
  
  console.log('🗑️ FRONTEND ADMIN DELETE - Product:', name);
  console.log('🗑️ FRONTEND ADMIN DELETE - ID:', id);
  console.log('🗑️ FRONTEND ADMIN DELETE - URL:', url);
  
  showDeleteConfirm.value = false
  
  router.post(url, {
    _method: 'DELETE',
    onSuccess: () => {
      console.log('🗑️ FRONTEND ADMIN DELETE - Success callback');
      successModifyCallback(`Le produit ${name} a été bien supprimé `)
    },
    onError: (errors) => {
      console.log('🗑️ FRONTEND ADMIN DELETE - Error callback:', errors);
      errorModifyCallback(`Le produit ${name} n'a pas pu être supprimé, veuillez réessayer`)
    },
    // Pas de preserveState: false pour voir les logs
  })
}

const handleKeydown = (event: KeyboardEvent) => {
  if (event.key === 'Escape') {
    closeModal()
  }
}

const searchQuery = ref('')
const currentPage = ref(1)
const itemsPerPage = ref(12)

const selectedCategoryId = ref<number>(0)

const filteredProducts = computed(() => {
  let result = [...props.products]
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    result = result.filter(
      (product) =>
        product.name.toLowerCase().includes(query) ||
        (product.brand?.name || '').toLowerCase().includes(query) ||
        (product.description || '').toLowerCase().includes(query)
    )
  }

  if (selectedCategoryId.value) {
    result = result.filter((product) => product.category?.id === selectedCategoryId.value)
  }

  return result
})

const paginatedProducts = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return filteredProducts.value.slice(start, end)
})

const totalProducts = computed(() => filteredProducts.value.length)

const totalPages = computed(() => Math.max(1, Math.ceil(totalProducts.value / itemsPerPage.value)))

// Réinitialiser la page quand les filtres changent
watch([searchQuery, selectedCategoryId], () => {
  currentPage.value = 1
})

onMounted(() => {
  document.addEventListener('keydown', handleKeydown)
})

onUnmounted(() => {
  document.removeEventListener('keydown', handleKeydown)
})

// YouTube URL Helper
const getYouTubeEmbedUrl = (url: string) => {
  const videoId = url.split('v=')[1]
  return `https://www.youtube.com/embed/${videoId}`
}
</script>
<template>
  <div class="text-white mx-auto px-6 py-8">
    <!-- Header -->
    <div class="flex justify-between items-center mb-8">
      <h1 class="text-2xl font-bold text-black">Gestion des Articles</h1>
      <button
        @click="openModal('create')"
        class="bg-primary hover:bg-opacity-90 px-4 py-2 rounded-lg flex items-center gap-2 transition-colors"
      >
        <div class="i-mdi-plus"></div>
        Ajouter un article
      </button>
    </div>

    <!-- Filtres -->
    <div class="bg-background-admin text-white p-4 rounded-lg shadow mb-6">
      <div class="flex flex-wrap gap-4">
        <div class="flex-1 min-w-[200px]">
          <label class="block text-sm font-medium mb-1">Recherche</label>
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Rechercher par nom de produit..."
            class="w-full bg-background-secondary text-white rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-primary"
          />
        </div>
        <div class="w-[200px]">
          <label class="block text-sm font-medium mb-1">Statut</label>
          <select
            v-model="selectedCategoryId"
            class="w-full px-3 py-2 bg-background-secondary text-white rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
          >
            <option value="0">Sélectionner</option>
            <option v-for="category in categories" :key="category.id" :value="category.id">
              {{ category.name }}
            </option>
          </select>
        </div>
      </div>
    </div>

    <!-- Products Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
      <div
        v-for="product in paginatedProducts"
        :key="product.id"
        class="bg-background-secondary rounded-xl overflow-hidden group hover:ring-2 hover:ring-primary transition-all duration-300"
      >
        <!-- Product Image -->
        <div class="relative aspect-square overflow-hidden">
          <img v-if="product.medias?.[0]?.type === MediaType.IMAGE"
            :src="product.medias?.[0]?.url || 'https://auto-cdn.uvatis.com/logo.png'"
            :alt="product.name"
            class="w-full h-full object-cover"
          />

          <div
            v-else-if="product.medias?.[0]?.type === MediaType.VIDEO"
            class="w-full h-full bg-background-secondary flex items-center justify-center"
          >
            <iframe
              :src="getYouTubeEmbedUrl(product.medias?.[0]?.url || '')"
              class="w-full h-full"
              allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
              allowfullscreen
            ></iframe>
          </div>
          <!-- Image Navigation -->
          <div v-if="product.medias?.length > 1" class="absolute bottom-2 right-2 flex gap-1">
            <button
              v-for="(media, _index) in product.medias"
              :key="media.url"
              class="w-2 h-2 rounded-full bg-white bg-opacity-50 hover:bg-opacity-100 transition-opacity"
            ></button>
          </div>
          <!-- Quick Actions -->
          <div
            class="absolute inset-0 bg-black bg-opacity-50 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center gap-4"
          >
            <button
              @click="openModal('edit', product)"
              class="bg-primary p-2 rounded-lg hover:bg-opacity-90 transition-colors"
              title="Modifier"
            >
              <div class="i-mdi-pencil text-xl"></div>
            </button>
            <button
              @click="openModal('view', product)"
              class="bg-white text-#1a1b26 p-2 rounded-lg hover:bg-opacity-90 transition-colors"
              title="Voir"
            >
              <div class="i-mdi-eye text-xl"></div>
            </button>
            <button
              @click="confirmDelete(product)"
              class="bg-red-500 p-2 rounded-lg hover:bg-opacity-90 transition-colors"
              title="Supprimer"
            >
              <div class="i-mdi-delete text-xl"></div>
            </button>
          </div>
        </div>

        <!-- Product Info -->
        <div class="p-4">
          <h3 class="font-semibold text-lg mb-2">{{ product.name }}</h3>
          <p class="text-gray-400 text-sm line-clamp-2 mb-3">{{ product.description }}</p>
          <div class="flex justify-between items-center">
            <div class="flex items-baseline gap-2">
              <span class="text-primary font-bold">{{ formatPrice(product) }} Fcfa</span>
              <span v-if="product.discount > 0" class="text-gray-400 text-sm line-through"
                >{{ product.price }} Fcfa</span
              >
            </div>
            <span class="text-xs text-gray-400">{{ product.medias?.length || 0 }} media(s)</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Pagination -->
    <div v-if="totalProducts > 0" class="mt-8">
      <Pagination
        v-model:currentPage="currentPage"
        :total-items="totalProducts"
        :items-per-page="itemsPerPage"
        item-name="articles"
      />
    </div>

    <!-- CRUD Modal -->
    <div
      v-if="showModal"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50"
    >
      <div class="bg-#232430 rounded-xl w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        <!-- Modal Header -->
        <div class="flex justify-between items-center p-6 border-b border-gray-700">
          <h2 class="text-xl font-bold">
            {{ modalTitle }}
          </h2>
          <button @click="closeModal" class="text-gray-400 hover:text-white">
            <div class="i-mdi-close text-2xl"></div>
          </button>
        </div>

        <!-- Modal Content -->
        <EditProductModal
          v-if="['edit'].includes(modalMode)"
          :categories="categories"
          :brands="brands"
          :product-prop="modalModeProduct!"
          @success="(p) => successModifyCallback(`Le produit ${p} a été bien modifié `)"
          @error="
            (p) => errorModifyCallback(`Le produit ${p} n'a pas être modifié, veuillez réessayer `)
          "
          @error-size="
            (p) =>
              errorModifyCallback(
                `L'image ${p} n'a pas été ajoutée (type non autorisé ou taille > 10 Mo)`
              )
          "
        />

        <CreateProductModal
          v-if="['create'].includes(modalMode)"
          :categories="categories"
          :brands="brands"
          @success="(p) => successModifyCallback(`Le produit ${p} a été bien ajouté `)"
          @error="
            (p) => errorModifyCallback(`Le produit ${p} n'a pas être ajouté, veuillez réessayer `)
          "
          @error-size="
            (p) =>
              errorModifyCallback(
                `L'image ${p} n'a pas été ajoutée (type non autorisé ou taille > 10 Mo)`
              )
          "
        />

        <ShowProduct v-if="['view'].includes(modalMode)" :product="modalModeProduct!" :src="'/'" @close="closeModal" />
      </div>
    </div>

    <!-- Callback Crud Modal -->
    <MessagePopup
      :show="showMessagePopup"
      :type="popupType"
      :message="popupMessage"
      @close-callback="closeCallbackModal"
    />

    <!-- Delete Confirmation Modal -->
    <div
      v-if="showDeleteConfirm"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50"
    >
      <div class="bg-#232430 rounded-xl p-6 max-w-md w-full">
        <h3 class="text-xl font-bold mb-4">Confirmer la suppression</h3>
        <p class="text-gray-400 mb-6">
          Êtes-vous sûr de vouloir supprimer "{{ productToDelete?.name }}"? Cette action est
          irréversible.
        </p>
        <div class="flex justify-end gap-4">
          <button
            @click="showDeleteConfirm = false"
            class="px-4 py-2 rounded-lg border border-gray-600 hover:bg-gray-700 transition-colors"
          >
            Annuler
          </button>
          <button
            @click="deleteProduct"
            class="px-4 py-2 rounded-lg bg-red-500 hover:bg-red-600 transition-colors"
          >
            Supprimer
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
