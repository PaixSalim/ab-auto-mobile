<template>
  <!-- Header with Search and Cart -->
  <header class="md:hidden px-4 sticky top-0 bg-white z-50">
    <div class="flex items-center gap-4 max-w-7xl mx-auto py-2">
      <div class="flex w-full items-center gap-2">
        <SearchBar @isExpanded="handleExpanded" class="flex-1 w-full"/>
        <div v-if="!isExpanded" @click="openLink" class="i-mdi-whatsapp h-6 w-6 text-green-500 flex-none" />
        
        <div v-if="!isExpanded && !user" class="flex items-center gap-2 flex-none">
          <Link href="/auth/login" class="text-gray-700 hover:text-primary">
            <div class="i-mdi-login h-6 w-6" />
          </Link>
          <button 
            @click="openRegister" 
            class="bg-primary text-white px-3 py-1.5 rounded-lg text-sm font-bold shadow-lg shadow-primary/20"
          >
            S'inscrire
          </button>
        </div>
        
        <div v-if="!isExpanded && user" class="flex items-center gap-2 flex-none">
          <Link
            :href="spaceHref"
            class="bg-primary text-white px-3 py-1.5 rounded-lg text-xs font-bold shadow-md whitespace-nowrap max-w-[7.5rem] truncate"
          >
            Mon espace
          </Link>
          <Link href="/auth/logout" method="post" as="button" class="text-gray-700 hover:text-primary p-1" title="Déconnexion">
            <div class="i-mdi-logout h-6 w-6" />
          </Link>
        </div>
      </div>
    </div>
  </header>
</template>

<script setup lang="ts">
import SearchBar from '~/components/SearchBar.vue'
import { Link, usePage } from '@inertiajs/vue3'
import { ref, computed, inject } from 'vue'
import { getMySpaceUrlFromAuth } from '~/utils/mySpaceUrl'

const page = usePage()
const auth = computed(() => (page.props as any).auth)
const user = computed(
  () => auth.value?.user || (page.props as any).user,
)
const spaceHref = computed(() =>
  auth.value?.user ? getMySpaceUrlFromAuth(auth.value) : '/auth/login',
)
const openRegister = inject('openRegister') as () => void

const openLink = () => {
  window.location.href = 'https://api.whatsapp.com/send?phone=22607513333'
}
const isExpanded = ref(false)
const handleExpanded = (bool: boolean) => {
  isExpanded.value = bool
}
</script>
