<template>
  <div class="flex h-screen bg-slate-50 dark:bg-slate-950 overflow-hidden font-sans">
    <!-- Sidebar -->
    <Sidebar :is-open="isSidebarOpen" />

    <!-- Main Content -->
    <div class="flex-1 flex flex-col overflow-hidden relative">
      <!-- Top Navbar -->
      <header class="h-20 bg-white/80 dark:bg-slate-900/80 backdrop-blur-xl border-b border-slate-200 dark:border-slate-800 flex items-center justify-between px-8 z-20">
        <div class="flex items-center gap-4">
           <button @click="isSidebarOpen = !isSidebarOpen" class="p-2 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-xl sm:hidden">
              <div class="i-mdi-menu text-2xl text-slate-600"></div>
           </button>
           <h2 class="text-xl font-bold text-slate-800 dark:text-white">{{ title }}</h2>
        </div>

        <div class="flex items-center gap-6">
           <!-- Search Placeholder -->
           <div class="hidden md:flex items-center gap-2 bg-slate-100 dark:bg-slate-800 px-4 py-2 rounded-xl text-slate-500 border border-transparent focus-within:border-primary transition-all">
              <div class="i-mdi-magnify"></div>
              <input type="text" placeholder="Rechercher..." class="bg-transparent border-none outline-none text-sm w-48" />
           </div>

           <div class="h-6 w-px bg-slate-200 dark:bg-slate-800"></div>

           <!-- User Profile -->
           <div class="relative">
              <button @click="toggleActionMenu" class="flex items-center gap-3 p-1.5 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-2xl transition-all group">
                 <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-primary to-primary-dark flex items-center justify-center text-white font-bold text-lg shadow-lg shadow-primary/20">
                    {{ user?.fullName?.charAt(0) || 'U' }}
                 </div>
                 <div class="hidden sm:block text-left mr-2">
                    <p class="text-xs font-bold text-slate-900 dark:text-white leading-tight">{{ user?.fullName }}</p>
                    <p class="text-[10px] text-slate-500 uppercase font-bold tracking-tight">{{ roles[0] || 'Utilisateur' }}</p>
                 </div>
                 <div class="i-mdi-chevron-down text-slate-400 group-hover:text-primary transition-colors"></div>
              </button>

              <!-- Action Menu -->
              <transition
                enter-active-class="transition duration-100 ease-out"
                enter-from-class="transform scale-95 opacity-0"
                enter-to-class="transform scale-100 opacity-100"
                leave-active-class="transition duration-75 ease-in"
                leave-from-class="transform scale-100 opacity-100"
                leave-to-class="transform scale-95 opacity-0"
              >
                <div
                  v-if="showActionMenu"
                  class="absolute right-0 mt-3 w-56 bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 text-slate-700 dark:text-slate-200 rounded-2xl shadow-xl z-50 overflow-hidden"
                >
                  <div class="p-2 space-y-1">
                    <button @click="logout" class="flex items-center gap-3 w-full px-4 py-2.5 text-sm hover:bg-red-50 hover:text-red-600 rounded-xl transition-colors">
                      <div class="i-mdi-logout text-lg"></div>
                      Déconnexion
                    </button>
                    <button @click="router.visit('/')" class="flex items-center gap-3 w-full px-4 py-2.5 text-sm hover:bg-slate-50 dark:hover:bg-slate-800 rounded-xl transition-colors">
                      <div class="i-mdi-storefront text-lg"></div>
                      Aller à la boutique
                    </button>
                  </div>
                </div>
              </transition>
           </div>
        </div>
      </header>

      <!-- Page Content -->
      <main class="flex-1 overflow-x-hidden overflow-y-auto bg-slate-50 dark:bg-slate-950 p-6">
        <div class="max-w-7xl mx-auto">
           <slot></slot>
        </div>
      </main>

      <!-- Overlay for mobile -->
      <div
        v-if="isSidebarOpen"
        class="fixed inset-0 bg-slate-900/40 backdrop-blur-sm z-40 sm:hidden"
        @click="isSidebarOpen = false"
      ></div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { router, usePage } from '@inertiajs/vue3'
import Sidebar from './dashboard/Sidebar.vue'

defineProps<{
  title?: string
}>()

const page = usePage()
const user = computed(() => (page.props.auth as any)?.user || {})
const roles = computed(() => (page.props.auth as any)?.roles || [])

const isSidebarOpen = ref(false)
const showActionMenu = ref(false)

const toggleActionMenu = () => {
  showActionMenu.value = !showActionMenu.value
}

const logout = () => {
  router.post('/auth/logout')
}
</script>

<style>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap');

.font-sans {
  font-family: 'Inter', system-ui, sans-serif;
}

::-webkit-scrollbar {
  width: 6px;
}

::-webkit-scrollbar-track {
  background: transparent;
}

::-webkit-scrollbar-thumb {
  background: #e2e8f0;
  border-radius: 10px;
}

.dark ::-webkit-scrollbar-thumb {
  background: #1e293b;
}
</style>
