<template>
  <Layout>
    <div class="p-6">
      <h1 class="text-3xl font-bold mb-6 text-primary">Commandes sur mes produits</h1>

      <div v-if="orders.length === 0" class="text-center py-12">
        <p class="text-description text-lg">Aucune commande pour le moment</p>
      </div>

      <div v-else>
        <!-- Order Tabs -->
        <div class="mb-6">
          <button
            v-for="tab in orderTabs"
            :key="tab.value"
            @click="currentOrderTab = tab.value"
            :class="[
              'px-4 py-2 rounded-lg mr-2',
              currentOrderTab === tab.value
                ? 'bg-primary text-white'
                : 'bg-gray-200 text-gray-600 hover:bg-gray-300',
            ]"
          >
            {{ tab.label }}
          </button>
        </div>

        <!-- Order List -->
        <div v-if="filteredOrders.length > 0" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <div
            v-for="order in filteredOrders"
            :key="order.id"
            class="bg-white rounded-lg shadow-md p-4 border"
          >
            <div class="flex justify-between items-start mb-3">
              <div>
                <p class="font-semibold text-lg">Commande #{{ order.id }}</p>
                <p class="text-sm text-gray-600">{{ formatDate(order.createdAt.toString()) }}</p>
              </div>
              <span
                :class="[
                  'px-2 py-1 rounded-full text-xs font-semibold',
                  order.status === OrderStatus.PROCESSING
                    ? 'bg-yellow-100 text-yellow-800'
                    : order.status === OrderStatus.DELIVERED
                      ? 'bg-green-100 text-green-800'
                      : order.status === OrderStatus.CANCELLED 
                        ? 'bg-red-100 text-red-800' 
                        : 'bg-blue-100 text-blue-800',
                ]"
              >
                {{ getStatusLabel(order.status) }}
              </span>
            </div>

            <div class="mb-3">
              <p class="font-medium text-title">{{ order.product.name }}</p>
              <p class="text-sm text-description">Quantité: {{ order.quantity }}</p>
              <p class="text-lg font-bold text-primary">{{ formatPrice(order.product.price * order.quantity) }}</p>
            </div>

            <div class="mb-3">
              <p class="text-sm text-gray-600">
                <span class="font-medium">Client:</span> {{ order.customerName }}
              </p>
              <p class="text-sm text-gray-600">
                <span class="font-medium">Téléphone:</span> 
                <a
                  :href="`https://api.whatsapp.com/send?phone=${order.phoneNumber}&text=Bonjour,`"
                  target="_blank"
                  rel="noopener noreferrer"
                  class="text-primary hover:underline"
                >
                  +{{ order.phoneNumber }}
                </a>
              </p>
              <p v-if="order.city" class="text-sm text-gray-600">
                <span class="font-medium">Ville:</span> {{ order.city }}
              </p>
            </div>

            <div class="flex justify-between items-center">
              <button
                @click="viewOrderDetails(order)"
                class="text-primary hover:underline text-sm font-medium"
              >
                Voir les détails
              </button>
              
              <div class="relative">
                <button
                  @click="toggleActionMenu(order.id)"
                  class="text-gray-400 hover:text-gray-600 focus:outline-none"
                >
                  <div class="i-mdi-dots-vertical text-xl"></div>
                </button>
                <div
                  v-if="activeActionMenu === order.id"
                  class="absolute right-0 mt-2 w-48 bg-white border border-gray-200 rounded-lg shadow-lg z-10"
                >
                  <div class="py-1">
                    <button
                      v-if="order.status === OrderStatus.PROCESSING"
                      @click="
                        handleAction(
                          OrderAction.DELIVERED,
                          order.id,
                          `Voulez-vous vraiment marquer cette commande ${order.id} comme livrée ?`
                        )
                      "
                      class="block w-full text-left px-4 py-2 text-sm hover:bg-gray-100"
                    >
                      Marquer comme livrée
                    </button>
                    <button
                      @click="
                        handleAction(
                          OrderAction.CANCEL,
                          order.id,
                          `Voulez-vous vraiment annuler cette commande ${order.id} ?`
                        )
                      "
                      class="block w-full text-left px-4 py-2 text-sm hover:bg-gray-100 text-red-600"
                    >
                      Annuler la commande
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div v-else class="text-center py-8 text-gray-500">
          Aucune commande trouvée dans cette catégorie.
        </div>
      </div>

      <!-- Order Details Modal -->
      <ShowOrderDetails
        v-if="showOrderDetailModal"
        :order="selectedOrder!"
        @close="closeOrderDetailModal"
      />

      <!-- Confirm Action Modal -->
      <ConfirmAction
        v-if="confirm.show"
        :message="confirm.message"
        :action="getActionLabel(confirm.action)"
        @close="closeConfirmPopup"
        @action="executeAction"
      />
    </div>
  </Layout>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { router } from '@inertiajs/vue3'
import Layout from '~/components/seller/Layout.vue'
import { OrderAction, OrderStatus } from '#utils/enum'
import type { SellerOrderType } from '~/types/order'
import ShowOrderDetails from '~/components/seller/popup/ShowOrderDetails.vue'
import ConfirmAction from '~/components/seller/popup/ConfirmAction.vue'


const props = defineProps<{
  orders: SellerOrderType[]
}>()

const currentOrderTab = ref('all')
const activeActionMenu = ref<number | null>(null)
const showOrderDetailModal = ref(false)
const selectedOrder = ref<SellerOrderType>()

const orderTabs = [
  { label: 'Toutes', value: 'all' },
  { label: 'En cours', value: OrderStatus.PROCESSING },
  { label: 'Livrées', value: OrderStatus.DELIVERED },
  { label: 'Annulées', value: OrderStatus.CANCELLED },
]

const confirm = ref<{
  id: number
  message: string
  action: OrderAction
  show: boolean
}>({
  id: 0,
  message: '',
  action: OrderAction.CANCEL,
  show: false,
})

const filteredOrders = computed(() => {
  if (currentOrderTab.value === 'all') {
    return props.orders
  }
  return props.orders.filter((order) => order.status === currentOrderTab.value)
})

const formatDate = (dateString: string) => {
  return new Date(dateString).toLocaleDateString('fr-FR', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  })
}

const formatPrice = (price: number) => {
  return new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: 'XOF',
  }).format(price)
}

const getStatusLabel = (status: string) => {
  switch (status) {
    case OrderStatus.PROCESSING:
      return 'En cours'
    case OrderStatus.DELIVERED:
      return 'Livrée'
    case OrderStatus.CANCELLED:
      return 'Annulée'
    default:
      return status
  }
}

const toggleActionMenu = (orderId: number) => {
  if (activeActionMenu.value === orderId) {
    activeActionMenu.value = null
  } else {
    activeActionMenu.value = orderId
  }
}

const viewOrderDetails = (order: SellerOrderType) => {
  selectedOrder.value = order
  showOrderDetailModal.value = true
}

const closeOrderDetailModal = () => {
  showOrderDetailModal.value = false
  selectedOrder.value = undefined
}

const handleAction = (action: OrderAction, orderId: number, message: string) => {
  confirm.value.id = orderId
  confirm.value.message = message
  confirm.value.action = action
  confirm.value.show = true
  activeActionMenu.value = null
}

const closeConfirmPopup = () => {
  confirm.value.show = false
}

const getActionLabel = (action: OrderAction) => {
  switch (action) {
    case OrderAction.DELIVERED:
      return 'Marquer comme livrée'
    case OrderAction.CANCEL:
      return 'Annuler la commande'
    default:
      return action
  }
}

const executeAction = () => {
  router.post(
    `/seller/order/${confirm.value.action}`,
    {
      orderId: confirm.value.id,
    },
    {
      preserveScroll: true,
      onSuccess: () => {
        confirm.value.show = false
      },
      onError: () => {
        alert('Une erreur est survenue, veuillez réessayer')
      },
    }
  )
}

// Fermer le menu si on clique en dehors
const closeActionMenu = (event: MouseEvent) => {
  if (activeActionMenu.value && !(event.target as HTMLElement).closest('.relative')) {
    activeActionMenu.value = null
  }
}

onMounted(() => {
  document.addEventListener('click', closeActionMenu)
})

onUnmounted(() => {
  document.removeEventListener('click', closeActionMenu)
})
</script>
