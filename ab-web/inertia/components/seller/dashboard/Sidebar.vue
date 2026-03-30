<template>
  <aside
    :class="[
      'text-white border-r-1 border-gray-700 transform top-0 left-0 w-64 bg-background-primary h-full overflow-auto ease-in-out transition-all duration-300',
      'sm:translate-x-0 sm:relative sm:z-0',
      isOpen ? 'translate-x-0 z-50' : '-translate-x-full',
      'fixed sm:static',
    ]"
  >
    <div class="flex items-center justify-start mx-4 mt-8">
      <div class="flex items-center">
        <img :src="logoUrl" class="w-15 h-15 rounded-full" alt="Logo Auto-pro" />
        <span class="text-primary text-2xl mx-2 font-semibold">Auto-Pro</span>
      </div>
    </div>

    <nav class="mt-10 overflow-hidden">
      <div
        v-for="nav in navs"
        :key="nav.route"
        class="relative group"
      >
        <Link
          :class="[
            'flex items-center py-4 text-lg py-2 px-6 transition-all duration-300',
            page.url === nav.route ? 'bg-primary/10 border-l-4 border-primary text-primary' : 'text-gray-400 hover:text-white hover:bg-white/5',
            !isValidated && nav.route !== '/seller/' ? 'opacity-40 cursor-not-allowed grayscale pointer-events-none' : '',
          ]"
          :href="!isValidated && nav.route !== '/seller/' ? '#' : nav.route"
          prefetch
        >
          <div :class="[nav.icon, 'text-xl']"></div>
          <span class="mx-3 flex-1">{{ nav.label }}</span>
          
          <!-- Lock Icon -->
          <div v-if="!isValidated && nav.route !== '/seller/'" class="i-mdi-lock text-sm opacity-60" />
        </Link>
        
        <!-- Tooltip for locked items -->
        <div 
          v-if="!isValidated && nav.route !== '/seller/'"
          class="absolute left-full ml-2 px-3 py-2 bg-gray-800 text-white text-xs rounded-lg opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap z-50 pointer-events-none border border-white/10"
        >
          Compte en attente de validation
        </div>
      </div>
    </nav>
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
const isValidated = computed(() => user.value?.isValidated === true || user.value?.isValidated === 1)

const navs = [
  {
    label: 'Dashboard',
    route: '/seller/',
    icon: 'i-mdi-home',
  },
  {
    label: 'Mes Produits',
    route: '/seller/products',
    icon: 'i-mdi-shopping',
  },
  {
    label: 'Commandes',
    route: '/seller/orders',
    icon: 'i-mdi-cart',
  },
  {
    label: 'Commentaires',
    route: '/seller/comments',
    icon: 'i-mdi-comment-text',
  },
]
const logoUrl = '/uploads/logos/logo.png'
</script>
