<template>
  <div class="p-6">
    <div class="flex text-white justify-between items-center mb-6">
      <h1 class="text-2xl font-bold">Promotions</h1>
      <button @click="openCreateModal" class="bg-primary hover:bg-opacity-90 px-4 py-2 rounded-lg flex items-center gap-2 transition-colors">
        <div class="i-mdi-plus mr-2"></div>
        Ajouter
      </button>
    </div>

    <!-- Filtres -->
    <div class=" bg-background-admin text-white p-4 rounded-lg shadow mb-6">
      <div class="flex flex-wrap gap-4">
        <div class="flex-1 min-w-[200px]">
          <label class="block text-sm font-medium  mb-1">Recherche</label>
          <input
            v-model="filters.search"
            type="text"
            placeholder="Rechercher par nom de produit..."
            class="w-full bg-background-secondary text-white rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-primary "
          />
        </div>
        <div class="w-[200px]">
          <label class="block text-sm font-medium  mb-1">Statut</label>
          <select
            v-model="filters.status"
            class="w-full px-3 py-2 bg-background-secondary text-white rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
          >
            <option value="all">Tous</option>
            <option value="active">Actives</option>
            <option value="upcoming">À venir</option>
            <option value="expired">Expirées</option>
          </select>
        </div>
      </div>
    </div>

    <!-- Liste des promotions -->
    <div class="rounded-lg shadow overflow-hidden">
      <!-- État de chargement -->
      <div v-if="loading" class="p-6">
        <!-- Version desktop du shimmer -->
        <div class="hidden md:block">
          <div class="animate-pulse flex space-x-4 mb-4">
            <div class="rounded-lg bg-gray-600 h-12 w-12"></div>
            <div class="flex-1 space-y-2 py-1">
              <div class="h-4 bg-gray-600 rounded w-3/4"></div>
              <div class="h-4 bg-gray-600 rounded w-5/6"></div>
            </div>
            <div class="w-24 h-4 bg-gray-600 rounded"></div>
            <div class="w-24 h-4 bg-gray-600 rounded"></div>
            <div class="w-24 h-4 bg-gray-600 rounded"></div>
            <div class="w-24 h-4 bg-gray-600 rounded"></div>
          </div>
          <div class="animate-pulse flex space-x-4 mb-4">
            <div class="rounded-lg bg-gray-600 h-12 w-12"></div>
            <div class="flex-1 space-y-2 py-1">
              <div class="h-4 bg-gray-600 rounded w-3/4"></div>
              <div class="h-4 bg-gray-600 rounded w-5/6"></div>
            </div>
            <div class="w-24 h-4 bg-gray-600 rounded"></div>
            <div class="w-24 h-4 bg-gray-600 rounded"></div>
            <div class="w-24 h-4 bg-gray-600 rounded"></div>
            <div class="w-24 h-4 bg-gray-600 rounded"></div>
          </div>
        </div>

        <!-- Version mobile du shimmer -->
        <div class="md:hidden space-y-6">
          <div v-for="i in 2" :key="i" class="animate-pulse bg-background-admin rounded-lg p-4">
            <div class="flex items-center mb-3">
              <div class="rounded-lg bg-gray-600 h-12 w-12"></div>
              <div class="ml-3 flex-1">
                <div class="h-4 bg-gray-600 rounded w-3/4 mb-2"></div>
                <div class="h-3 bg-gray-600 rounded w-1/2"></div>
              </div>
            </div>
            <div class="space-y-2">
              <div class="h-4 bg-gray-600 rounded w-1/3"></div>
              <div class="h-4 bg-gray-600 rounded w-1/2"></div>
              <div class="h-4 bg-gray-600 rounded w-2/3"></div>
            </div>
            <div class="flex justify-end mt-3">
              <div class="h-4 bg-gray-600 rounded w-24"></div>
            </div>
          </div>
        </div>
      </div>

      <!-- Message si aucune promotion -->
      <div v-else-if="filteredPromotions.length === 0" class="p-6 text-center text-gray-200 dark:text-gray-400">
        Aucune promotion trouvée.
      </div>

      <!-- Table pour desktop et tablette -->
      <table class="min-w-full divide-y divide-gray-400 hidden md:table">
        <thead class="bg-background-secondary">
        <tr>
          <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-200 uppercase tracking-wider">Produit</th>
          <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-200 uppercase tracking-wider">Réduction</th>
          <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-200 uppercase tracking-wider">Label</th>
          <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-200 uppercase tracking-wider">Période</th>
          <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-200 uppercase tracking-wider">Statut</th>
          <th scope="col" class="px-6 py-3 text-right text-xs font-medium text-gray-200 uppercase tracking-wider">Actions</th>
        </tr>
        </thead>
        <tbody class="bg-background-admin divide-y divide-gray-500">
        <tr v-for="promotion in filteredPromotions" :key="promotion.id">
          <td class="px-6 py-4 whitespace-nowrap">
            <div class="flex items-center">
              <div class="h-10 w-10 flex-shrink-0">
                <img class="h-10 w-10 rounded-lg object-cover" :src="promotion.url" alt="" />
              </div>
              <div class="ml-4">
                <div class="text-sm font-medium text-gray-100">{{ promotion.product.name }}</div>
                <div class="text-sm text-gray-500">ID: {{ promotion.id }}</div>
              </div>
            </div>
          </td>
          <td class="px-6 py-4 whitespace-nowrap">
            <div class="text-sm text-gray-100 dark:text-white">{{ promotion.discountPercent }}%</div>
          </td>
          <td class="px-6 py-4 whitespace-nowrap">
            <div class="text-sm text-gray-100 dark:text-white">{{ promotion.promoLabel || '-' }}</div>
          </td>
          <td class="px-6 py-4 whitespace-nowrap">
            <div class="text-sm text-gray-100">
              {{ formatDate(promotion.promoStartDate) }} - {{ formatDate(promotion.promoEndDate) }}
            </div>
          </td>
          <td class="px-6 py-4 whitespace-nowrap">
              <span
                class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full"
                :class="getStatusClass(promotion)"
              >
                {{ getStatusText(promotion) }}
              </span>
          </td>
          <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
            <button @click="editPromotion(promotion)" class="text-gray-300 hover:text-primary mr-3">
              Modifier
            </button>
            <button @click="deletePromotion(promotion.id)" class="text-primary hover:text-primary/50">
              Supprimer
            </button>
          </td>
        </tr>
        </tbody>
      </table>

      <!-- Version mobile (cartes) -->
      <div class="md:hidden divide-y divide-gray-700">
        <div v-for="promotion in filteredPromotions" :key="promotion.id" class="p-4 bg-background-admin">
          <div class="flex items-center mb-3">
            <div class="h-12 w-12 flex-shrink-0">
              <img class="h-12 w-12 rounded-lg object-cover" :src="promotion.url" alt="" />
            </div>
            <div class="ml-3">
              <div class="text-sm font-medium text-gray-100">{{ promotion.product.name }}</div>
              <div class="text-xs text-gray-500">ID: {{ promotion.id }}</div>
            </div>
          </div>

          <div class="gap-3 text-sm mb-4">
            <div>
              <span class="text-gray-500">Réduction:</span>
              <span class="ml-1 text-gray-100">{{ promotion.discountPercent }}%</span>
            </div>

            <div>
              <span class="text-gray-500">Label:</span>
              <span class="ml-1 text-gray-100">{{ promotion.promoLabel || '-' }}</span>
            </div>

            <div class="col-span-2">
              <span class="text-gray-500">Période:</span>
              <span class="ml-1 text-gray-100">
                {{ formatDate(promotion.promoStartDate) }} - {{ formatDate(promotion.promoEndDate) }}
              </span>
            </div>

            <div class="flex justify-between mt-3">
              <span class="text-gray-500">Statut:</span>
              <span
                class="ml-1 px-2 inline-flex text-xs leading-5 font-semibold rounded-full"
                :class="getStatusClass(promotion)"
              >
                {{ getStatusText(promotion) }}
              </span>
            </div>
          </div>

          <div class="flex justify-end space-x-4 border-t border-gray-700 pt-3">
            <button @click="editPromotion(promotion)" class="text-gray-300 hover:text-primary">
              Modifier
            </button>
            <button @click="deletePromotion(promotion.id)" class="text-primary hover:text-primary/50">
              Supprimer
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de création/édition -->
    <div v-if="showModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-background-admin mx-3 my-3 text-white rounded-lg shadow-xl max-w-xl mx-1 w-full max-h-[90vh] overflow-y-auto">
        <div class="p-6">
          <h2 class="text-xl font-bold mb-4">{{ isEditing ? 'Modifier la promotion' : 'Créer une nouvelle promotion' }}</h2>

          <form @submit.prevent="savePromotion">
            <!-- Sélection du produit -->
            <InputLabelAdmin
              v-model:category-id="currentPromotion.productId"
              id="product"
              label="Produit"
              name="product"
              placeholder="Sélectionnez un produit"
              type="select"
              :products="products"
              :required="true"
            />


            <!-- Pourcentage de réduction -->
            <div class="mb-4">
              <label class="block text-sm text-gray-300 font-bold mb-1">Pourcentage de réduction</label>
              <div class="relative">
                <input
                  v-model.number="currentPromotion.discountPercent"
                  type="number"
                  min="1"
                  max="99"
                  class="w-full bg-background-secondary text-white rounded-lg p-3 focus:outline-none focus:ring-2 focus:ring-primary pr-8"
                  required
                />
                <div class="absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none">
                  <span class="text-gray-500">%</span>
                </div>
              </div>
            </div>

            <!-- URL de l'image -->
            <div class="mb-4">
              <label class="block text-sm text-gray-300 font-bold mb-1">Image de la promotion (optionnelle)</label>
              
              <!-- Input file standard -->
              <div v-if="!currentPromotion.url && !hasImage">
                <input
                  type="file"
                  accept="image/*"
                  @change="handleFileChange"
                  class="w-full bg-background-secondary text-white rounded-lg p-3 focus:outline-none focus:ring-2 focus:ring-primary"
                />
                <p class="text-xs text-gray-500 mt-1">
                  Formats acceptés: JPG, PNG, GIF (max 2MB)
                </p>
              </div>
              
              <!-- Afficher l'image existante ou la nouvelle image -->
              <div v-if="currentPromotion.url || hasImage" class="mt-2">
                <div class="relative inline-block">
                  <img 
                    :src="hasImage && images[0] ? images[0].preview : currentPromotion.url" 
                    alt="Aperçu de l'image" 
                    class="h-32 object-contain rounded-md border border-gray-600" 
                  />
                  <button
                    type="button"
                    @click="removeCurrentImage"
                    class="absolute top-0 right-0 bg-red-600 text-white rounded-full p-1 hover:bg-red-700 transition-colors"
                    title="Supprimer l'image"
                  >
                    <div class="i-mdi-close w-4 h-4"></div>
                  </button>
                </div>
                <p class="text-xs text-gray-400 mt-1">
                  {{ isEditing ? 'Vous pouvez remplacer cette image en en ajoutant une nouvelle' : 'Image actuelle de la promotion' }}
                </p>
              </div>
              
              <!-- Message si aucune image -->
              <div v-if="!currentPromotion.url && !hasImage" class="text-xs text-gray-500 mt-1">
                Une image par défaut sera utilisée si aucune image n'est fournie
              </div>
            </div>

            <!-- Label de promotion -->
            <div class="mb-4">
              <label class="block text-sm font-bold text-gray-300 mb-1">Label de promotion</label>
              <input
                v-model="currentPromotion.promoLabel"
                type="text"
                placeholder="Ex: Promo de Ramadan"
                class="w-full bg-background-secondary text-white rounded-lg p-3 focus:outline-none focus:ring-2 focus:ring-primary"
              />
            </div>

            <!-- Dates de promotion -->
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
              <div>
                <label class="block text-sm font-medium text-gray-300 mb-1">Date de début</label>
                <input
                  v-model="startDateInput"
                  type="datetime-local"
                  class="w-full px-3 py-2 bg-background-secondary text-white rounded-lg p-3 focus:outline-none focus:ring-2 focus:ring-primary"
                  required
                />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-300 mb-1">Date de fin</label>
                <input
                  v-model="endDateInput"
                  type="datetime-local"
                  class="w-full bg-background-secondary text-white rounded-lg p-3 focus:outline-none focus:ring-2 focus:ring-primary"
                  required
                />
              </div>
            </div>

            <div class="flex justify-end mt-6 space-x-3">
              <button
                type="button"
                @click="closeModal"
                class="px-4 py-2 border border-gray-300  rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 "
              >
                Annuler
              </button>
              <button
                type="submit"
                :disabled="isSaving"
                class="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-primary hover:bg-primary/40 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary disabled:opacity-50"
              >
                {{ isSaving ? 'Enregistrement...' : (isEditing ? 'Mettre à jour' : 'Créer') }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>

    <!-- Modal de confirmation de suppression -->
    <div v-if="showDeleteModal" class="fixed text-white inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-background-admin rounded-lg shadow-xl max-w-md mx-3 w-full">
        <div class="p-6">
          <h2 class="text-xl font-bold mb-4">Confirmer la suppression</h2>
          <p class="mb-6 text-gray-300">Êtes-vous sûr de vouloir supprimer cette promotion ? Cette action est irréversible.</p>

          <div class="flex justify-end space-x-3">
            <button
              @click="showDeleteModal = false"
              class="px-4 py-2 border border-gray-300  rounded-md shadow-sm text-sm font-medium text-gray-600  bg-white  hover:bg-gray-50  focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary"
            >
              Annuler
            </button>
            <button
              @click="confirmDelete"
              class="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-primary hover:bg-primary/40 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary"
            >
              Supprimer
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { DateTime } from 'luxon'
import { GetProductDto } from '#dto/products_interface'
import InputLabelAdmin from '~/components/admin/form/InputLabelAdmin.vue'
import { router } from '@inertiajs/vue3'
import { AdminGetPromotionDto } from '#dto/promoted_products_dto'

const props = defineProps<{
  promos: AdminGetPromotionDto[]
}>()

// État
const promotions = ref<AdminGetPromotionDto[]>([])
const products = ref<GetProductDto[]>([])
const loading = ref(true)
const showModal = ref(false)
const showDeleteModal = ref(false)
const isEditing = ref(false)
const deletePromotionId = ref<number | null>(null)
const startDateInput = ref('')
const endDateInput = ref('')
const images = ref<{ file: File; type: 'image'; preview: string }[]>([])
const currentPromotion = ref<{
  productId: number,
  discountPercent: number,
  url: string,
  promoLabel: string,
  promoStartDate: string,
  promoEndDate: string,
}>({
  productId: 0,
  discountPercent: 10,
  url: '',
  promoLabel: '',
  promoStartDate: '',
  promoEndDate: '',
})

const filters = ref({
  search: '',
  status: 'all'
})

const handleFileChange = (event: Event) => {
  const target = event.target as HTMLInputElement
  if (target.files && target.files[0]) {
    const file = target.files[0]
    const reader = new FileReader()
    
    reader.onload = (e) => {
      if (e.target?.result) {
        images.value = [{
          file: file,
          type: 'image',
          preview: e.target.result as string,
        }]
      }
    }
    
    reader.readAsDataURL(file)
  }
}

const removeCurrentImage = (): void => {
  currentPromotion.value.url = ''
  images.value = []
}

// Computed
const hasImage = computed(() => images.value.length > 0)

const filteredPromotions = computed(() => {
  let result = [...promotions.value]

  // Filtre par recherche
  if (filters.value.search) {
    const searchTerm = filters.value.search.toLowerCase()
    result = result.filter(promo =>
      promo.product.name.toLowerCase().includes(searchTerm) ||
      (promo.promoLabel && promo.promoLabel.toLowerCase().includes(searchTerm))
    )
  }

  // Filtre par statut
  const now = DateTime.now()
  if (filters.value.status === 'active') {
    result = result.filter(promo => {
      const startDate = DateTime.fromISO(promo.promoStartDate)
      const endDate = DateTime.fromISO(promo.promoEndDate)
      return startDate <= now && endDate >= now
    })
  } else if (filters.value.status === 'upcoming') {
    result = result.filter(promo => DateTime.fromISO(promo.promoStartDate) > now)
  } else if (filters.value.status === 'expired') {
    result = result.filter(promo => DateTime.fromISO(promo.promoEndDate) < now)
  }

  return result
})

// Méthodes
const fetchData = async () => {
  try {
    loading.value = true

      const response = await fetch('/api/v1/products')
      const data = await response.json()

      if (data && data.length > 0) {
        products.value = data
      }
    promotions.value = props.promos
  } catch (error) {
  } finally {
    loading.value = false
  }
}

const formatDate = (dateString: string) => {
  return DateTime.fromISO(dateString).toFormat('dd/MM/yyyy')
}

const getStatusClass = (promotion: AdminGetPromotionDto) => {
  const now = DateTime.now()
  const startDate = DateTime.fromISO(promotion.promoStartDate)
  const endDate = DateTime.fromISO(promotion.promoEndDate)

  if (startDate > now) {
    return 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-300'
  } else if (endDate < now) {
    return 'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300'
  } else {
    return 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300'
  }
}

const getStatusText = (promotion: AdminGetPromotionDto) => {
  const now = DateTime.now()
  const startDate = DateTime.fromISO(promotion.promoStartDate)
  const endDate = DateTime.fromISO(promotion.promoEndDate)

  if (startDate > now) {
    return 'À venir'
  } else if (endDate < now) {
    return 'Expirée'
  } else {
    return 'Active'
  }
}

const openCreateModal = () => {
  isEditing.value = false
  currentPromotion.value = {
    productId: -1,
    discountPercent: 10,
    url: '',
    promoLabel: '',
    promoStartDate: '',
    promoEndDate: '',
  }

  // Réinitialiser les images
  images.value = []

  // Initialiser les dates avec la date actuelle et la date dans 30 jours
  const now = DateTime.now()
  const thirtyDaysLater = now.plus({ days: 30 })

  startDateInput.value = now.toFormat("yyyy-MM-dd'T'HH:mm")
  endDateInput.value = thirtyDaysLater.toFormat("yyyy-MM-dd'T'HH:mm")

  showModal.value = true
}

const editPromotion = (promotion: AdminGetPromotionDto) => {
  isEditing.value = true
  currentPromotion.value = { 
    productId: promotion.product.id, 
    url: promotion.url, 
    discountPercent: promotion.discountPercent, 
    promoLabel: promotion.promoLabel, 
    promoStartDate: promotion.promoStartDate, 
    promoEndDate: promotion.promoEndDate 
  }

  startDateInput.value = DateTime.fromISO(promotion.promoStartDate).toFormat("yyyy-MM-dd'T'HH:mm")
  endDateInput.value = DateTime.fromISO(promotion.promoEndDate).toFormat("yyyy-MM-dd'T'HH:mm")

  // Réinitialiser les images pour l'édition
  images.value = []

  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
}

const isSaving = ref(false)

const savePromotion = async () => {
  if (isSaving.value) return
  isSaving.value = true

  const startDate = DateTime.fromFormat(startDateInput.value, "yyyy-MM-dd'T'HH:mm").toISO()
  const endDate = DateTime.fromFormat(endDateInput.value, "yyyy-MM-dd'T'HH:mm").toISO()

  const formData = new FormData()
  formData.append('productId', String(currentPromotion.value.productId))
  formData.append('promoLabel', String(currentPromotion.value.promoLabel))
  formData.append('discountPercent', String(currentPromotion.value.discountPercent))
  formData.append('promoStartDate', startDate!)
  formData.append('promoEndDate', endDate!)
  if (images.value.length > 0) {
    formData.append('image', images.value[0].file)
  }

  let url: string
  let isEdit = false

  if (isEditing.value) {
    const promo = promotions.value.find(p => p.product.id === currentPromotion.value.productId)
    if (!promo) { isSaving.value = false; return }
    url = `/dashboard/promotions/edit/${promo.id}`
    isEdit = true
  } else {
    url = '/dashboard/promotions/create'
  }

  try {
    const response = await fetch(url, { method: 'POST', body: formData })
    if (response.ok || response.redirected) {
      showModal.value = false
      window.dispatchEvent(new CustomEvent('toast:show', {
        detail: {
          type: 'success',
          title: isEdit ? 'Promotion modifiée' : 'Promotion créée',
          message: isEdit ? 'La promotion a été modifiée avec succès' : 'La promotion a été créée avec succès'
        }
      }))
      router.visit('/dashboard/promotions', { preserveScroll: true })
    } else {
      throw new Error('Erreur serveur')
    }
  } catch (error) {
    window.dispatchEvent(new CustomEvent('toast:show', {
      detail: {
        type: 'error',
        title: 'Erreur',
        message: isEdit
          ? 'Une erreur est survenue lors de la modification de la promotion'
          : 'Une erreur est survenue lors de la création de la promotion'
      }
    }))
  } finally {
    isSaving.value = false
  }
}

const deletePromotion = (id: number) => {
  deletePromotionId.value = id
  showDeleteModal.value = true
}

const confirmDelete = async () => {
  if (deletePromotionId.value) {
    try {
      await fetch(`/dashboard/promotions/delete/${deletePromotionId.value}`, { method: 'DELETE' })
    } catch {}
    showDeleteModal.value = false
    router.visit('/dashboard/promotions', { preserveScroll: true })
  }
}

// Sync local list whenever Inertia re-renders with fresh props
watch(() => props.promos, (newPromos) => {
  promotions.value = newPromos
}, { deep: true })

// Initialisation
onMounted(fetchData)
</script>

<style scoped>
.animate-pulse {
  animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
}

@keyframes pulse {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: .5;
  }
}
</style>

