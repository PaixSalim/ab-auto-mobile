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
                    <p class="text-[10px] text-slate-500 uppercase font-bold tracking-tight">{{ roles[0] || 'Vendeur' }}</p>
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
                  class="absolute right-0 mt-2 w-48 bg-white dark:bg-slate-900 rounded-2xl border border-slate-200 dark:border-slate-800 shadow-xl z-50"
                >
                  <div class="p-2">
                    <button
                      @click="goToHome"
                      class="w-full text-left px-4 py-2 text-sm text-slate-700 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-xl transition-colors font-medium flex items-center gap-3"
                    >
                      <div class="i-mdi-store text-lg"></div>
                      Boutique
                    </button>
                    <button
                      @click="logout"
                      class="w-full text-left px-4 py-2 text-sm text-slate-700 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-xl transition-colors font-medium flex items-center gap-3"
                    >
                      <div class="i-mdi-logout text-lg"></div>
                      Déconnexion
                    </button>
                  </div>
                </div>
              </transition>
           </div>
        </div>
      </header>

      <!-- Validation Warning Banner -->
      <div v-if="user && !user.isValidated" class="bg-amber-50 dark:bg-amber-900/20 border-b border-amber-200 dark:border-amber-800 p-4">
        <div class="flex items-center justify-center gap-3 text-amber-800 dark:text-amber-200 max-w-4xl mx-auto">
          <div class="i-mdi-alert-circle text-xl"></div>
          <p class="text-sm font-medium">
            Votre compte est en attente de validation. Certaines fonctionnalités sont limitées.
          </p>
        </div>
      </div>

      <!-- Page Content -->
      <main class="flex-1 overflow-x-hidden overflow-y-auto bg-slate-50 dark:bg-slate-950">
        <slot />
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { usePage, router } from '@inertiajs/vue3'
import Sidebar from '~/components/seller/Sidebar.vue'

const props = defineProps<{
  title?: string
}>()

const page = usePage()
const user = computed(() => (page.props as any).auth?.user)
const roles = computed(() => (page.props as any).auth?.roles || [])

const isSidebarOpen = ref(false)
const showActionMenu = ref(false)

const toggleSidebar = () => {
  isSidebarOpen.value = !isSidebarOpen.value
}

const toggleActionMenu = () => {
  showActionMenu.value = !showActionMenu.value
}

const logout = () => {
  router.post('/auth/logout')
}

const goToHome = () => {
  router.visit('/')
}

// Close action menu when clicking outside
document.addEventListener('click', (e) => {
  const target = e.target as HTMLElement
  if (!target.closest('.relative')) {
    showActionMenu.value = false
  }
})
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;900&display=swap');

.font-sans {
  font-family: 'Inter', sans-serif;
}
</style>
