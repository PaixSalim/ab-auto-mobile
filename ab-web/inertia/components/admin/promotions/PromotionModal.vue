<template>
  <Teleport to="body">
    <div v-if="modelValue" class="fixed inset-0 z-50 flex items-center justify-center p-4">
      <!-- Overlay -->
      <div
        class="absolute inset-0 bg-black transition-opacity duration-300"
        :class="modelValue ? 'bg-opacity-50' : 'bg-opacity-0'"
        @click="closeModal"
      ></div>

      <!-- Modal -->
      <div
        class="bg-white rounded-lg shadow-xl w-full max-w-md relative z-10 transition-all duration-300 transform"
        :class="modelValue ? 'scale-100 opacity-100' : 'scale-95 opacity-0'"
      >
        <!-- Header -->
        <div class="flex justify-between items-center p-6 border-b">
          <h3 class="text-xl font-semibold text-gray-900">
            {{ promotion ? 'Modifier la promotion' : 'Nouvelle promotion' }}
          </h3>
          <button
            @click="closeModal"
            class="text-gray-400 hover:text-gray-600 transition-colors"
            aria-label="Fermer"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
            </svg>
          </button>
        </div>

        <!-- Body -->
        <div class="p-6">
          <form @submit.prevent="submitForm">
            <div class="space-y-4">
              <!-- Produit -->
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Produit</label>
                <select
                  v-model="formData.productId"
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
                  required
                >
                  <option value="">Sélectionner un produit</option>
                  <option v-for="product in availableProducts" :key="product.id" :value="product.id">
                    {{ product.name }}
                  </option>
                </select>
              </div>

              <!-- Pourcentage de réduction -->
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Réduction (%)</label>
                <input
                  v-model="formData.discountPercent"
                  type="number"
                  min="1"
                  max="100"
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
                  required
                />
              </div>

              <!-- Image de la promotion -->
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Image de la promotion (optionnelle)</label>
                <input
                  type="file"
                  accept="image/*"
                  @change="handleFileChange"
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
                />
                <p v-if="selectedFile" class="mt-2 text-sm text-gray-600">
                  Fichier sélectionné: {{ selectedFile.name }}
                </p>
                <p v-else class="mt-2 text-sm text-gray-500">
                  Formats acceptés: JPG, PNG, GIF (max 2MB)
                </p>
              </div>

              <!-- Label de la promotion -->
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Label de la promotion</label>
                <input
                  v-model="formData.promoLabel"
                  type="text"
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
                  placeholder="Ex: SOLDES2024"
                  required
                />
              </div>

              <!-- Dates -->
              <div class="grid grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">Date de début</label>
                  <input
                    v-model="formData.promoStartDate"
                    type="date"
                    class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
                    required
                  />
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">Date de fin</label>
                  <input
                    v-model="formData.promoEndDate"
                    type="date"
                    class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
                    required
                  />
                </div>
              </div>
            </div>

            <!-- Actions -->
            <div class="flex justify-end gap-3 mt-6">
              <button
                type="button"
                @click="closeModal"
                class="px-4 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50 transition-colors"
              >
                Annuler
              </button>
              <button
                type="submit"
                :disabled="isSubmitting"
                class="px-4 py-2 bg-primary hover:bg-primary-hover text-white rounded-md transition-colors disabled:opacity-50"
              >
                {{ isSubmitting ? 'Enregistrement...' : (promotion ? 'Modifier' : 'Créer') }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script setup lang="ts">
import { ref, watch, onMounted } from 'vue'

const props = defineProps<{
  modelValue: boolean
  promotion?: any
}>()

const emit = defineEmits<{
  'update:modelValue': [value: boolean]
  'promotion-created': []
  'promotion-updated': []
}>()

const isSubmitting = ref(false)
const selectedFile = ref<File | null>(null)
const availableProducts = ref<any[]>([])

const formData = ref({
  productId: '',
  discountPercent: '',
  promoLabel: '',
  promoStartDate: '',
  promoEndDate: '',
})

// Charger les produits disponibles
const loadProducts = async () => {
  try {
    const response = await fetch('/api/v1/products')
    const products = await response.json()
    availableProducts.value = products
  } catch (error) {
  }
}

const handleFileChange = (event: Event) => {
  const target = event.target as HTMLInputElement
  if (target.files && target.files[0]) {
    selectedFile.value = target.files[0]
  } else {
    selectedFile.value = null
  }
}

const closeModal = () => {
  emit('update:modelValue', false)
}

const submitForm = async () => {
  isSubmitting.value = true
  
  try {
    const formDataToSend = new FormData()
    formDataToSend.append('productId', formData.value.productId)
    formDataToSend.append('discountPercent', formData.value.discountPercent)
    formDataToSend.append('promoLabel', formData.value.promoLabel)
    formDataToSend.append('promoStartDate', formData.value.promoStartDate)
    formDataToSend.append('promoEndDate', formData.value.promoEndDate)
    
    if (selectedFile.value) {
      formDataToSend.append('image', selectedFile.value)
    }
    
    if (props.promotion) {
      formDataToSend.append('id', props.promotion.id.toString())
    }
    
    const url = props.promotion 
      ? `/dashboard/promotions/edit/${props.promotion.id}`
      : '/dashboard/promotions/create'
    
    const response = await fetch(url, {
      method: 'POST',
      body: formDataToSend,
      headers: {
        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || ''
      }
    })
    
    if (!response.ok) {
      throw new Error('Erreur lors de la soumission')
    }
    
    // Afficher la notification de succès
    window.dispatchEvent(new CustomEvent('toast:show', {
      detail: {
        type: 'success',
        title: props.promotion ? 'Promotion modifiée' : 'Promotion créée',
        message: props.promotion 
          ? 'La promotion a été modifiée avec succès' 
          : 'La promotion a été créée avec succès'
      }
    }))
    
    if (props.promotion) {
      emit('promotion-updated')
    } else {
      emit('promotion-created')
    }
    
    closeModal()
  } catch (error) {
    // Afficher la notification d'erreur
    window.dispatchEvent(new CustomEvent('toast:show', {
      detail: {
        type: 'error',
        title: 'Erreur',
        message: 'Une erreur est survenue lors de la création/modification de la promotion'
      }
    }))
  } finally {
    isSubmitting.value = false
  }
}

// Préremplir le formulaire si on édite une promotion
watch(() => props.promotion, (newPromotion) => {
  if (newPromotion) {
    formData.value = {
      productId: newPromotion.productId?.toString() || '',
      discountPercent: newPromotion.discountPercent?.toString() || '',
      promoLabel: newPromotion.promoLabel || '',
      promoStartDate: newPromotion.promoStartDate
        ? (typeof newPromotion.promoStartDate === 'string'
            ? newPromotion.promoStartDate.substring(0, 10)
            : newPromotion.promoStartDate.toFormat?.('yyyy-MM-dd') || newPromotion.promoStartDate.toISOString?.().substring(0, 10) || '')
        : '',
      promoEndDate: newPromotion.promoEndDate
        ? (typeof newPromotion.promoEndDate === 'string'
            ? newPromotion.promoEndDate.substring(0, 10)
            : newPromotion.promoEndDate.toFormat?.('yyyy-MM-dd') || newPromotion.promoEndDate.toISOString?.().substring(0, 10) || '')
        : '',
    }
  }
}, { immediate: true })

// Charger les produits au montage du composant
onMounted(() => {
  loadProducts()
})
</script>
