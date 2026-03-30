<template>
  <aside
    :class="[
      'bg-slate-800 dark:bg-slate-900 border-r border-slate-700 dark:border-slate-800 text-white transform top-0 left-0 w-64 h-full overflow-y-auto ease-in-out transition-all duration-300 z-40',
      'sm:translate-x-0 sm:relative sm:z-0',
      isOpen ? 'translate-x-0' : '-translate-x-full',
      'fixed sm:static',
    ]"
  >
    <!-- Logo Section -->
    <div class="flex items-center justify-center mx-6 mt-8 mb-8">
      <div class="flex items-center gap-3">
        <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-primary to-primary-dark flex items-center justify-center text-white font-bold text-lg shadow-lg shadow-primary/20">
          AP
        </div>
        <span class="text-xl font-bold text-white">Auto-Pro</span>
      </div>
    </div>

    <!-- Navigation -->
    <nav class="px-4 space-y-1">
      <div
        v-for="nav in navigation"
        :key="nav.route"
        class="relative group"
      >
        <Link
          :class="[
            'flex items-center gap-3 px-4 py-3 rounded-xl transition-all duration-200 font-medium',
            currentPage === nav.route 
              ? 'bg-primary text-white shadow-lg shadow-primary/20' 
              : 'text-slate-300 hover:bg-slate-700 hover:text-white',
            !isValidated && nav.route !== '/seller/' ? 'opacity-40 cursor-not-allowed grayscale pointer-events-none' : '',
          ]"
          :href="!isValidated && nav.route !== '/seller/' ? '#' : nav.route"
          prefetch
        >
          <div :class="[nav.icon, 'text-xl']"></div>
          <span class="flex-1">{{ nav.label }}</span>
          
          <!-- Lock Icon for non-validated users -->
          <div v-if="!isValidated && nav.route !== '/seller/'" class="i-mdi-lock text-sm opacity-60" />
        </Link>
        
        <!-- Tooltip for locked items -->
        <div 
          v-if="!isValidated && nav.route !== '/seller/'"
          class="absolute left-full ml-2 px-3 py-2 bg-slate-800 dark:bg-slate-700 text-white text-xs rounded-lg opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap z-50 pointer-events-none border border-slate-600 dark:border-slate-600 shadow-xl"
        >
          Compte en attente de validation
        </div>
      </div>
    </nav>

    <!-- Bottom Section -->
    <div class="absolute bottom-0 left-0 right-0 p-4 border-t border-slate-200 dark:border-slate-800">
      <div class="flex items-center gap-3 px-4 py-3">
        <div class="w-8 h-8 rounded-lg bg-gradient-to-br from-emerald-500 to-emerald-600 flex items-center justify-center text-white text-sm font-bold">
          {{ user?.fullName?.charAt(0)?.toUpperCase() || 'U' }}
        </div>
        <div class="flex-1 min-w-0">
          <p class="text-sm font-medium text-slate-800 dark:text-white truncate">
            {{ user?.fullName || 'Utilisateur' }}
          </p>
          <p class="text-xs text-slate-500 dark:text-slate-400 truncate">
            {{ user?.companyName || 'Vendeur' }}
          </p>
        </div>
      </div>
    </div>
  </aside>
</template>

<script setup lang="ts">
import { Link, usePage } from '@inertiajs/vue3'
import { computed } from 'vue'

defineProps<{
  isOpen: boolean
}>()

const page = usePage()
const user = computed(() => (page.props as any).auth?.user)
const roles = computed(() => (page.props as any).auth?.roles || [])
const currentPage = computed(() => (page.props as any).url || '')

const isValidated = computed(() => {
  return user.value?.isValidated === true || user.value?.isValidated === 1
})

const navigation = [
  {
    label: 'Tableau de bord',
    route: '/seller/',
    icon: 'i-mdi-home',
  },
  {
    label: 'Mes Produits',
    route: '/seller/products',
    icon: 'i-mdi-package-variant',
  },
  {
    label: 'Commandes',
    route: '/seller/orders',
    icon: 'i-mdi-cart-outline',
  },
  {
    label: 'Commentaires',
    route: '/seller/comments',
    icon: 'i-mdi-comment-multiple-outline',
  },
]
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;900&display=swap');

.font-sans {
  font-family: 'Inter', sans-serif;
}
</style>
