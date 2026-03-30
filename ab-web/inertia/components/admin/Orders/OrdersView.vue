<template>
  <section class="text-white rounded-xl p-6">
    <h2 class="text-2xl font-semibold mb-4 text-black"> Gestion des Commandes</h2>

    <!-- Order Tabs -->
    <div class="mb-4">
      <button
        v-for="tab in orderTabs"
        :key="tab.value"
        @click="currentOrderTab = tab.value"
        :class="[
          'px-2 py-2 rounded-lg mb-2 mr-2',
          currentOrderTab === tab.value
            ? 'bg-primary text-white'
            : 'bg-background-admin text-gray-400 hover:bg-opacity-80',
        ]"
      >
        {{ tab.label }}
      </button>
    </div>

    <!-- Order List -->
    <div v-if="filteredOrders.length > 0">
      <div class="grid md:(grid-cols-4 gap-3)">
        <div
          v-for="order in paginatedOrders"
          :key="order.id"
          class="bg-background-secondary p-4 rounded-lg mb-4"
        >
          <div class="flex justify-between items-center mb-2">
            <p class="font-semibold">Commande #{{ order.id }}</p>
            <div class="flex items-center">
              <p
                :class="[
                'px-2 py-1 rounded-lg text-xs md:(text-sm) mr-2',
                order.status === OrderStatus.PROCESSING
                  ? 'bg-yellow-500 text-yellow-900'
                  : order.status === OrderStatus.DELIVERED
                    ? 'bg-green-500 text-green-900'
                      : order.status === OrderStatus.CANCELLED ? 'bg-red-500 text-white' : 'bg-emerald-500',
              ]"
              >
                {{ order.status }}
              </p>
              <div class="relative">
                <button
                  @click="toggleActionMenu(order.id)"
                  class="text-gray-400 hover:text-white focus:outline-none"
                >
                  <div class="i-mdi-dots-vertical text-xl"></div>
                </button>
                <div
                  v-if="activeActionMenu === order.id"
                  class="absolute right-0 mt-2 w-48 bg-background-admin border-1 border-gray-700 rounded-lg z-10"
                >
                  <div class="py-1">
                    <button
                      @click="
                        emitAction(
                          OrderAction.CANCEL,
                          order.id,
                          `Voulez-vous vraiment annuler cette commande ${order.id} ?`
                        )
                      "
                      class="block w-full text-left px-4 py-2 text-sm hover:bg-primary"
                      >Annuler</button
                    >
                    <button
                      @click="
                        emitAction(
                          OrderAction.DELETE,
                          order.id,
                          `Voulez-vous vraiment supprimer cette commande ${order.id} ? `
                        )
                      "
                      class="block text-left w-full px-4 py-2 text-sm hover:bg-primary"
                      >Supprimer</button
                    >
                    <button
                      @click="
                        emitAction(
                          OrderAction.DELIVERED,
                          order.id,
                          `Voulez-vous vraiment marquer cette commande ${order.id} comme livrée ? `
                        )
                      "
                      class="block text-left w-full px-4 py-2 text-sm hover:bg-primary"
                      >Marquer comme livré</button
                    >
                  </div>
                </div>
              </div>
            </div>
          </div>
          <!-- Informations du vendeur -->
          <div v-if="order.product.seller" class="mb-3 p-3 bg-gray-800 rounded-lg">
            <div class="flex items-center gap-2 mb-2">
              <div class="i-mdi-store w-4 h-4 text-primary"></div>
              <p class="text-sm font-medium text-gray-300">Informations vendeur</p>
            </div>
            <div class="grid grid-cols-1 gap-1 text-xs">
              <p><span class="text-gray-400">Nom:</span> {{ order.product.seller.fullName || 'Non spécifié' }}</p>
              <p><span class="text-gray-400">Email:</span> {{ order.product.seller.email }}</p>
              <p><span class="text-gray-400">Téléphone:</span> {{ order.product.seller.phone || 'Non disponible' }}</p>
              <p><span class="text-gray-400">Ville:</span> {{ order.product.seller.city || 'Non spécifiée' }}</p>
            </div>
          </div>
          <p class="text-gray-400">Date: {{ formatDate(order.createdAt.toString()) }}</p>
          <p class="text-gray-400">Total: {{ formatPrice(order.product.price * order.quantity) }}</p>
          <div class="flex justify-between">
            <button
              @click="$emit('view', order)"
              class="mt-2 text-primary hover:underline"
            >
              Voir les détails
            </button>
          </div>
        </div>
      </div>
    </div>
    <div v-else class="text-center py-8 text-gray-400">
      Aucune commande trouvée dans cette catégorie.
    </div>

    <!-- Pagination -->
    <div v-if="totalOrders > 0" class="mt-8">
      <Pagination
        v-model:currentPage="currentPage"
        :total-items="totalOrders"
        :items-per-page="itemsPerPage"
        item-name="commandes"
      />
    </div>
  </section>
</template>

<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref, watch } from 'vue'
import { GetOrderDto } from '#dto/orders_interface'
import { OrderStatus, OrderAction } from '#utils/enum'
import Pagination from '~/components/admin/Pagination.vue'

const props = defineProps<{
  orders: GetOrderDto[]
}>()

const emit = defineEmits<{
  action: [action: OrderAction, orderId: number, message: string]
}>()

const currentOrderTab = ref('all')
const activeActionMenu = ref<number | null>(null)
const currentPage = ref(1)
const itemsPerPage = ref(8)

const orderTabs = [
  { value: 'all', label: 'Toutes' },
  { value: OrderStatus.PROCESSING, label: 'En cours' },
  { value: OrderStatus.DELIVERED, label: 'Livrées' },
  { value: OrderStatus.CANCELLED, label: 'Annulées' },
]

const filteredOrders = computed(() => {
  let result = props.orders
  if (currentOrderTab.value !== 'all') {
    result = result.filter((order) => order.status === currentOrderTab.value)
  }
  return result
})

const paginatedOrders = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return filteredOrders.value.slice(start, end)
})

const totalOrders = computed(() => filteredOrders.value.length)

const totalPages = computed(() => Math.max(1, Math.ceil(totalOrders.value / itemsPerPage.value)))

// Réinitialiser la page quand l'onglet change
watch(currentOrderTab, () => {
  currentPage.value = 1
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

const toggleActionMenu = (orderId: number) => {
  if (activeActionMenu.value === orderId) {
    activeActionMenu.value = null
  } else {
    activeActionMenu.value = orderId
  }
}

const emitAction = (action: OrderAction, orderId: number, message: string) => {
  emit('action', action, orderId, message)
  activeActionMenu.value = null
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
