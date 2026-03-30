<script setup lang="ts">
import { ref } from 'vue'

interface Order {
  id: number
  customerName: string
  city: string | null
  phoneNumber: string
  status: string
  quantity: number
  createdAt: string
  product: {
    id: number
    name: string
    price: number
    slug: string
    image?: string
    seller?: {
      id: number
      fullName: string | null
      email: string
      phone: string | null
    }
  }
}

const props = withDefaults(
  defineProps<{
    orders: Order[]
  }>(),
  { orders: () => [] },
)

const selectedOrder = ref<Order | null>(null)
const showDetails = ref(false)

function viewOrder(order: Order) {
  selectedOrder.value = order
  showDetails.value = true
}

function closeDetails() {
  showDetails.value = false
  selectedOrder.value = null
}

function getStatusColor(status: string) {
  switch (status) {
    case 'En cours':
      return 'bg-yellow-100 text-yellow-800'
    case 'Confirmée':
      return 'bg-blue-100 text-blue-800'
    case 'Livrée':
      return 'bg-green-100 text-green-800'
    case 'Annulée':
      return 'bg-red-100 text-red-800'
    default:
      return 'bg-gray-100 text-gray-800'
  }
}

function formatDate(dateString: string) {
  return new Date(dateString).toLocaleDateString('fr-FR', {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

function formatPrice(price: number) {
  return new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: 'XOF',
    minimumFractionDigits: 0
  }).format(price)
}
</script>

<template>
  <div class="max-w-6xl mx-auto p-6">
    <div class="mb-8">
      <div class="flex items-center gap-4 mb-4">
        <a href="/" class="inline-flex items-center text-gray-600 hover:text-gray-900 transition-colors">
          <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
          </svg>
          Retour à l'accueil
        </a>
      </div>
      <h1 class="text-3xl font-bold text-gray-900 mb-2">Mes Commandes</h1>
      <p class="text-gray-600">Consultez l'historique de vos commandes</p>
    </div>

    <div v-if="orders.length === 0" class="text-center py-12">
      <div class="text-gray-400 mb-4">
        <svg class="w-24 h-24 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z" />
        </svg>
      </div>
      <h3 class="text-xl font-semibold text-gray-900 mb-2">Aucune commande</h3>
      <p class="text-gray-600 mb-6">Vous n'avez pas encore passé de commande</p>
      <a href="/catalogue" class="inline-flex items-center px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors">
        <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z" />
        </svg>
        Parcourir les produits
      </a>
    </div>

    <div v-else class="space-y-4">
      <div v-for="order in orders" :key="order.id" class="bg-white rounded-lg shadow-sm border border-gray-200 p-6 hover:shadow-md transition-shadow">
        <div class="flex items-start justify-between">
          <div class="flex-1">
            <div class="flex items-center gap-4 mb-3">
              <span class="text-sm font-medium text-gray-500">Commande #{{ order.id }}</span>
              <span :class="['px-2 py-1 rounded-full text-xs font-medium', getStatusColor(order.status)]">
                {{ order.status }}
              </span>
            </div>
            
            <h3 class="text-lg font-semibold text-gray-900 mb-2">{{ order.product.name }}</h3>
            
            <!-- Informations du vendeur -->
            <div v-if="order.product.seller" class="mb-3 p-2 bg-gray-50 rounded-lg">
              <div class="flex items-center gap-2 text-sm">
                <div class="i-mdi-store w-4 h-4 text-gray-600"></div>
                <span class="text-gray-600">Vendu par:</span>
                <span class="font-medium text-gray-900">{{ order.product.seller.fullName || 'Vendeur' }}</span>
              </div>
            </div>
            
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm text-gray-600">
              <div>
                <span class="font-medium">Quantité:</span> {{ order.quantity }}
              </div>
              <div>
                <span class="font-medium">Total:</span> {{ formatPrice(order.product.price * order.quantity) }}
              </div>
              <div>
                <span class="font-medium">Date:</span> {{ formatDate(order.createdAt) }}
              </div>
            </div>

              <div v-if="order.city || order.phoneNumber" class="mt-3 pt-3 border-t border-gray-100 text-sm text-gray-600">
              <div v-if="order.city" class="mb-1">
                <span class="font-medium">Ville:</span> {{ order.city }}
              </div>
              <div>
                <span class="font-medium">Téléphone:</span> {{ order.phoneNumber }}
              </div>
            </div>
          </div>

          <div class="flex flex-col gap-2 ml-4">
            <a 
              :href="`/catalogue/product/${order.product.slug}`"
              class="text-blue-600 hover:text-blue-800 text-sm font-medium"
            >
              Voir le produit
            </a>
            <button
              @click="viewOrder(order)"
              class="text-gray-600 hover:text-gray-800 text-sm font-medium"
            >
              Détails
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal détails -->
    <div v-if="showDetails && selectedOrder" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div class="bg-white rounded-lg max-w-md w-full p-6">
        <div class="flex justify-between items-center mb-4">
          <h2 class="text-xl font-bold">Détails de la commande</h2>
          <button @click="closeDetails" class="text-gray-400 hover:text-gray-600">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        <div class="space-y-4">
          <div>
            <h3 class="font-semibold text-gray-900">{{ selectedOrder.product.name }}</h3>
            <p class="text-gray-600">Quantité: {{ selectedOrder.quantity }}</p>
            <p class="text-lg font-bold text-blue-600">
              {{ formatPrice(selectedOrder.product.price * selectedOrder.quantity) }}
            </p>
            
            <!-- Informations du vendeur dans le modal -->
            <div v-if="selectedOrder.product.seller" class="mt-3 p-3 bg-gray-50 rounded-lg">
              <div class="flex items-center gap-2 mb-2">
                <div class="i-mdi-store w-4 h-4 text-gray-600"></div>
                <span class="text-sm font-medium text-gray-900">Vendu par:</span>
              </div>
              <div class="text-sm text-gray-700">
                <p class="font-medium">{{ selectedOrder.product.seller.fullName || 'Vendeur' }}</p>
                <div class="flex items-center gap-4 mt-1 text-xs text-gray-600">
                  <span v-if="selectedOrder.product.seller.phone">📞 {{ selectedOrder.product.seller.phone }}</span>
                  <span>✉️ {{ selectedOrder.product.seller.email }}</span>
                </div>
              </div>
            </div>
          </div>

          <div class="border-t pt-4">
            <h4 class="font-medium text-gray-900 mb-2">Informations de livraison</h4>
            <div class="space-y-1 text-sm text-gray-600">
              <p><span class="font-medium">Nom:</span> {{ selectedOrder.customerName }}</p>
              <p v-if="selectedOrder.city"><span class="font-medium">Ville:</span> {{ selectedOrder.city }}</p>
              <p><span class="font-medium">Téléphone:</span> {{ selectedOrder.phoneNumber }}</p>
            </div>
          </div>

          <div class="border-t pt-4">
            <div class="flex justify-between items-center">
              <span class="text-sm text-gray-500">Commande #{{ selectedOrder.id }}</span>
              <span :class="['px-2 py-1 rounded-full text-xs font-medium', getStatusColor(selectedOrder.status)]">
                {{ selectedOrder.status }}
              </span>
            </div>
            <p class="text-xs text-gray-500 mt-1">{{ formatDate(selectedOrder.createdAt) }}</p>
          </div>
        </div>

        <div class="mt-6 flex gap-3">
          <a 
            :href="`/catalogue/product/${selectedOrder.product.slug}`"
            class="flex-1 bg-blue-600 text-white text-center py-2 rounded-lg hover:bg-blue-700 transition-colors"
          >
            Voir le produit
          </a>
          <button
            @click="closeDetails"
            class="flex-1 bg-gray-200 text-gray-800 py-2 rounded-lg hover:bg-gray-300 transition-colors"
          >
            Fermer
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
