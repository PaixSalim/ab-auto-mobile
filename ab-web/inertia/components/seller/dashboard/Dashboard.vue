<script setup lang="ts">
import { router, usePage } from '@inertiajs/vue3'
import { computed } from 'vue'

const props = defineProps<{
  products?: number
  orders?: number
  comments?: number
}>()

const page = usePage()
const user = computed(() => (page.props as any).auth?.user)
const isValidated = computed(() => user.value?.isValidated === true || user.value?.isValidated === 1)

const goTo = (route: string) => {
  if (!isValidated.value) return
  router.visit(route)
}

// Statistiques spécifiques au vendeur
const getStats = (products: number, orders: number, comments: number) => [
  {
    label: "Mes Produits",
    value: products || 0,
    icon: "i-mdi-package-variant",
    bgGradient: isValidated.value ? "from-blue-600 to-blue-800" : "from-gray-600 to-gray-700",
    iconBg: "bg-blue-500",
    textColor: "text-blue-200",
    route: "/seller/products"
  },
  {
    label: "Commandes",
    value: orders || 0,
    icon: "i-mdi-cart",
    bgGradient: isValidated.value ? "from-green-600 to-green-800" : "from-gray-600 to-gray-700",
    iconBg: "bg-green-500",
    textColor: "text-green-200",
    route: "/seller/orders"
  },
  {
    label: "Commentaires",
    value: comments || 0,
    icon: "i-mdi-comment-multiple",
    bgGradient: isValidated.value ? "from-purple-600 to-purple-800" : "from-gray-600 to-gray-700",
    iconBg: "bg-purple-500",
    textColor: "text-purple-200",
    route: "/seller/comments"
  }
]
</script>

<template>
  <div class="px-6 py-8">
    <h3 class="text-primary font-bold text-3xl mb-6">Tableau de bord</h3>

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div
        v-for="stat in getStats(products || 0, orders || 0, comments || 0)"
        :key="stat.label"
        class="relative group bg-gradient-to-br rounded-xl shadow-lg overflow-hidden transition-all duration-300"
        :class="[
          stat.bgGradient,
          isValidated ? 'hover:shadow-2xl hover:scale-105 cursor-pointer' : 'opacity-60 cursor-not-allowed grayscale'
        ]"
        @click="goTo(stat.route)"
      >
        <!-- Lock Overlay for Stats -->
        <div v-if="!isValidated" class="absolute inset-0 flex items-center justify-center bg-black/20 z-10">
          <div class="i-mdi-lock text-4xl text-white/50" />
        </div>

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
