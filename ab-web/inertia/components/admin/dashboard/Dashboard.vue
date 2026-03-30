<script setup lang="ts">
import { ref } from 'vue'
import { router } from '@inertiajs/vue3'

const props = defineProps<{
  products: number
  orders: number
  promotions: number
  sellers: number
  customers: number
  pendingValidations: number
}>()

// Ajouter des logs pour le débogage
// Fabrique les statistiques à partir des données chargées
const getStats = (products: number, orders: number, promotions: number, sellers: number, customers: number, pendingValidations: number) => [
  {
    label: "Articles",
    value: products,
    icon: "i-mdi-package-variant",
    bgGradient: "from-purple-600 to-purple-800",
    iconBg: "bg-purple-500",
    textColor: "text-purple-200",
    route: "/dashboard/products"
  },
  {
    label: "Commandes",
    value: orders,
    icon: "i-mdi-cart",
    bgGradient: "from-yellow-600 to-yellow-800",
    iconBg: "bg-yellow-500",
    textColor: "text-yellow-200",
    route: "/dashboard/orders"
  },
  {
    label: "Promotions",
    value: promotions,
    icon: "i-mdi-cart-discount",
    bgGradient: "from-green-600 to-green-800",
    iconBg: "bg-green-500",
    textColor: "text-green-200",
    route: "/dashboard/dashboard"
  },
   {
    label: "Vendeurs",
    value: sellers,
    icon: "i-mdi-account-multiple",
    bgGradient: "from-blue-600 to-blue-800",
    iconBg: "bg-blue-500",
    textColor: "text-blue-200",
    route: "/sellers-admin"
  }, 
   {
    label: "Clients",
    value: customers,
    icon: "i-mdi-account-group",
    bgGradient: "from-indigo-600 to-indigo-800",
    iconBg: "bg-indigo-500",
    textColor: "text-indigo-200",
    route: "/dashboard/customers"
  },
  {
    label: "Catégories",
    value: "📁",
    icon: "i-mdi-folder-multiple",
    bgGradient: "from-pink-600 to-pink-800",
    iconBg: "bg-pink-500",
    textColor: "text-pink-200",
    route: "/dashboard/categories"
  },
  {
    label: "Validation en attente",
    value: pendingValidations,
    icon: "i-mdi-check-circle",
    bgGradient: "from-orange-600 to-orange-800",
    iconBg: "bg-orange-500",
    textColor: "text-orange-200",
    route: "/dashboard/validation"
  }
]

const goTo = (route: string) => {
  router.visit(route)
}

</script>

<template>
    <div class="px-6 py-8">
      <h3 class="text-primary font-bold text-3xl mb-6">Tableau de bord</h3>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">

        <div
          v-for="stat in getStats(props.products, props.orders, props.promotions, props.sellers, props.customers, props.pendingValidations)"
          :key="stat.label"
          class="bg-gradient-to-br rounded-xl shadow-lg overflow-hidden transition-all duration-300 hover:shadow-2xl hover:scale-105 cursor-pointer"
          :class="stat.bgGradient"
          @click="goTo(stat.route)"
        >
          <div class="px-6 py-8 flex items-center">
            <div class="flex items-center justify-center w-12 h-12 rounded-full bg-opacity-30" :class="stat.iconBg">
              <div :class="['text-3xl text-white', stat.icon]"></div>
            </div>
            <div class="ml-4">
              <h4 class="text-2xl font-semibold text-white">{{ stat.value }}</h4>
              <p :class="stat.textColor">{{ stat.label }}</p>
            </div>
          </div>
        </div>

      </div>
    </div>
</template>
