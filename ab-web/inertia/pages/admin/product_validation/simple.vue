<script setup lang="ts">
import { ref } from 'vue'
import { router } from '@inertiajs/vue3'
import Layout from '~/components/admin/Layout.vue'

interface Product {
  id: number
  name: string
  description: string
  price: number
  state: string
  warranty: string
  validationStatus: string
  rejectionReason: string | null
  seller?: {
    id: number
    fullName: string | null
    email: string
    phone: string | null
    city?: string | null
  }
  category?: {
    id: number
    name: string
  }
  brand?: {
    id: number
    name: string
  }
  medias: {
    id: number
    url: string
    type: string
  }[]
}

const props = defineProps<{
  products: Product[]
  error?: string
}>()

const showRejectModal = ref(false)
const selectedProduct = ref<Product | null>(null)
const rejectionReason = ref('')

const approveProduct = (productId: number) => {
  // Afficher notification de chargement
  showToast('info', 'Validation', 'Approbation du produit en cours...')
  
  router.post('/dashboard/validation/approve', { productId }, {
    onSuccess: () => {
      showToast('success', 'Produit approuvé', 'Le produit a été approuvé avec succès et est maintenant visible en boutique.')
    },
    onError: () => {
      showToast('error', 'Erreur', 'Une erreur est survenue lors de l\'approbation du produit.')
    }
  })
}

const openRejectModal = (product: Product) => {
  selectedProduct.value = product
  rejectionReason.value = ''
  showRejectModal.value = true
}

const rejectProduct = () => {
  if (!selectedProduct.value || !rejectionReason.value.trim()) return
  
  // Afficher notification de chargement
  showToast('info', 'Validation', 'Rejet du produit en cours...')
  
  router.post('/dashboard/validation/reject', { 
    productId: selectedProduct.value.id, 
    reason: rejectionReason.value 
  }, {
    onSuccess: () => {
      showRejectModal.value = false
      selectedProduct.value = null
      rejectionReason.value = ''
      showToast('success', 'Produit rejeté', 'Le produit a été rejeté. Le vendeur a été notifié.')
    },
    onError: () => {
      showToast('error', 'Erreur', 'Une erreur est survenue lors du rejet du produit.')
    }
  })
}

// Fonction utilitaire pour afficher les notifications
const showToast = (type: 'success' | 'error' | 'warning' | 'info', title: string, message: string) => {
  // Émettre un événement pour le composant Toast
  window.dispatchEvent(new CustomEvent('toast:show', {
    detail: {
      type,
      title,
      message,
      duration: 4000
    }
  }))
}

const formatPrice = (price: number) => {
  return new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: 'XOF',
  }).format(price)
}

const getStatusColor = (status: string) => {
  switch (status) {
    case 'approved':
      return 'bg-green-100 text-green-800'
    case 'pending':
      return 'bg-yellow-100 text-yellow-800'
    case 'rejected':
      return 'bg-red-100 text-red-800'
    default:
      return 'bg-gray-100 text-gray-800'
  }
}

const getStatusText = (status: string) => {
  switch (status) {
    case 'approved':
      return 'Approuvé'
    case 'pending':
      return 'En attente'
    case 'rejected':
      return 'Rejeté'
    default:
      return status
  }
}
</script>

<template>
  <Layout>
    <div class="p-6">
      <!-- Header -->
      <div class="mb-6">
        <h1 class="text-3xl font-bold text-black text-center mb-2">Validation des produits</h1>
        <p class="text-gray-400 text-center">
          Produits en attente de validation : {{ products.length }}
        </p>
        
        <!-- Bouton pour créer un produit test -->
        <div v-if="products.length === 0" class="bg-blue-900/20 border border-blue-500 rounded p-4 mb-4">
          <p class="text-blue-400 mb-2">Aucun produit en attente ?</p>
          <p class="text-blue-300 text-sm mb-3">
            Créez un produit test pour voir le fonctionnement de la validation :
          </p>
          <a 
            href="/test/validation" 
            class="inline-block bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded text-sm mr-2"
          >
            Créer un produit test
          </a>
          <a 
            href="/test/status" 
            class="inline-block bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded text-sm"
          >
            Vérifier les statuts
          </a>
        </div>
        
        <!-- Message d'erreur si présent -->
        <div v-if="error" class="bg-red-900/20 border border-red-500 rounded p-4 mb-4">
          <p class="text-red-400 font-medium">Erreur:</p>
          <p class="text-red-300">{{ error }}</p>
        </div>
      </div>

      <!-- Liste des produits en attente -->
      <div v-if="products.length === 0" class="text-center py-12">
        <div class="text-6xl text-green-500 mb-4">✓</div>
        <p class="text-gray-400 text-lg">Aucun produit en attente de validation</p>
      </div>

      <div v-else class="grid gap-6">
        <div
          v-for="product in products"
          :key="product.id"
          class="bg-background-secondary rounded-lg p-6 border border-gray-700"
        >
          <!-- En-tête -->
          <div class="flex justify-between items-start mb-4">
            <div>
              <h3 class="text-xl font-semibold text-white mb-2">{{ product.name }}</h3>
              
              <!-- Catégorie et marque -->
              <div class="flex items-center gap-4 text-sm text-gray-400">
                <span v-if="product.category">{{ product.category.name }}</span>
                <span v-if="product.brand">{{ product.brand.name }}</span>
                <span :class="['px-2 py-1 rounded text-xs font-medium', getStatusColor(product.validationStatus)]">
                  {{ getStatusText(product.validationStatus) }}
                </span>
              </div>
            </div>
            <div class="text-right">
              <p class="text-xl font-bold text-primary">{{ formatPrice(product.price) }}</p>
              <p class="text-sm text-gray-400">{{ product.state }}</p>
            </div>
          </div>

          <!-- Images -->
          <div v-if="product.medias && product.medias.length > 0" class="mb-4">
            <div class="flex gap-2">
              <img
                v-for="(media, index) in product.medias.slice(0, 3)"
                :key="media.id"
                :src="media.url"
                :alt="product.name"
                class="w-20 h-20 object-cover rounded"
              />
              <div
                v-if="product.medias.length > 3"
                class="w-20 h-20 bg-gray-700 rounded flex items-center justify-center text-gray-400"
              >
                +{{ product.medias.length - 3 }}
              </div>
            </div>
          </div>

          <!-- Description -->
          <div class="mb-4">
            <p class="text-gray-300 text-sm line-clamp-3">{{ product.description }}</p>
          </div>

          <!-- Vendeur -->
          <div v-if="product.seller" class="mb-4 p-3 bg-gray-800 rounded">
            <p class="text-sm text-gray-400 mb-1">Vendeur</p>
            <p class="text-white">{{ product.seller.fullName || 'Non spécifié' }}</p>
            <p class="text-sm text-gray-400">{{ product.seller.email }}</p>
            <p class="text-sm text-gray-400">{{ product.seller.phone || 'Non disponible' }}</p>
            <p class="text-sm text-gray-400">{{ product.seller.city || 'Non spécifiée' }}</p>
          </div>
          <div v-else class="mb-4 p-3 bg-gray-800 rounded">
            <p class="text-sm text-gray-400 mb-1">Vendeur</p>
            <p class="text-white">Non spécifié</p>
          </div>

          <!-- Raison de rejet si existante -->
          <div v-if="product.rejectionReason" class="mb-4 p-3 bg-red-900/20 border border-red-500 rounded">
            <p class="text-sm text-red-400 mb-1">Raison du rejet</p>
            <p class="text-red-300">{{ product.rejectionReason }}</p>
          </div>

          <!-- Actions -->
          <div class="flex gap-3">
            <button
              @click="approveProduct(product.id)"
              class="flex-1 bg-green-600 hover:bg-green-700 text-white py-2 px-4 rounded transition-colors"
            >
              ✅ Approuver
            </button>
            <button
              @click="openRejectModal(product)"
              class="flex-1 bg-red-600 hover:bg-red-700 text-white py-2 px-4 rounded transition-colors"
            >
              ❌ Rejeter
            </button>
          </div>
        </div>
      </div>

      <!-- Modal de rejet -->
      <div
        v-if="showRejectModal"
        class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
      >
        <div class="bg-background-secondary rounded-lg w-full max-w-md p-6">
          <h3 class="text-xl font-semibold text-white mb-4">Rejeter le produit</h3>
          <p class="text-gray-400 mb-4">
            Veuillez indiquer la raison du rejet pour que le vendeur puisse corriger le produit.
          </p>
          <textarea
            v-model="rejectionReason"
            class="w-full bg-background-tertiary text-white rounded p-3 min-h-[100px] resize-none"
            placeholder="Raison du rejet..."
          ></textarea>
          <div class="flex gap-3 mt-4">
            <button
              @click="showRejectModal = false"
              class="flex-1 bg-gray-600 hover:bg-gray-700 text-white py-2 px-4 rounded transition-colors"
            >
              Annuler
            </button>
            <button
              @click="rejectProduct"
              :disabled="!rejectionReason.trim()"
              class="flex-1 bg-red-600 hover:bg-red-700 text-white py-2 px-4 rounded transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Rejeter
            </button>
          </div>
        </div>
      </div>
    </div>
  </Layout>
</template>
