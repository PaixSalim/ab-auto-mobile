<script setup lang="ts">
import SearchBar from '~/components/SearchBar.vue'
import { Link, usePage } from '@inertiajs/vue3'
import { computed, inject } from 'vue'
import { getMySpaceUrlFromAuth } from '~/utils/mySpaceUrl'

const page = usePage()
const auth = computed(() => (page.props as any).auth)
const user = computed(() => {
  return auth.value?.user || (page.props as any).user
})
const spaceHref = computed(() =>
  auth.value?.user ? getMySpaceUrlFromAuth(auth.value) : '/auth/login',
)
const openRegister = inject('openRegister') as () => void

// Logo URL
const logoUrl = '/uploads/logos/logo.png'

const openLink = () => {
  window.location.href = 'https://api.whatsapp.com/send?phone=22607513333'
}
</script>

<template>
  <header class="hidden md:block bg-white shadow-lg sticky top-0 z-[60] border-b-2 border-red-600">
    <div class="container mx-auto px-4">
      <!-- Main Header -->
      <div class="flex items-center justify-between py-3">
        <div class="flex items-center">
          <Link href="/" class="flex items-center">
            <img :src="logoUrl" alt="AB-AUTO Logo" class="h-12 w-12 mr-3" />
            <div class="text-2xl font-black text-red-600">
              AB<span class="text-orange-500">AUTO</span>
            </div>
          </Link>
        </div>

        <!-- Search Bar -->
        <div class="flex-1 max-w-2xl mx-8">
          <SearchBar />
        </div>

        <!-- Header Icons -->
        <div class="flex items-center space-x-6">
          <button @click="openLink" class="text-gray-700 hover:text-green-500 transition-colors" title="Contact WhatsApp">
            <div class="i-mdi-whatsapp h-6 w-6" />
          </button>
          
          <div v-if="!user" class="flex items-center gap-4">
            <Link href="/auth/login" class="text-gray-700 hover:text-red-600 font-bold transition-colors">
              Connexion
            </Link>
            <button 
              @click="openRegister" 
              class="bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700 transition-colors font-bold shadow-md"
            >
              S'inscrire
            </button>
          </div>
          
          <div v-else class="flex items-center gap-3">
            <Link
              :href="spaceHref"
              class="bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700 transition-colors font-bold shadow-md"
            >
              Mon espace
            </Link>
            <div class="relative group">
              <button
                type="button"
                class="flex items-center gap-2 text-gray-700 hover:text-red-600 transition-colors max-w-[12rem]"
              >
                <span class="text-gray-700 font-medium truncate">{{ user.fullName || user.email }}</span>
                <div class="i-mdi-chevron-down h-4 w-4 shrink-0" />
              </button>

              <div class="absolute right-0 mt-2 w-56 bg-white rounded-lg shadow-xl border border-gray-200 opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all duration-200 z-50">
                <div class="py-1">
                  <template v-if="user.role === 'customer'">
                    <Link href="/orders" class="block px-4 py-2 text-sm text-gray-700 hover:bg-red-50 hover:text-red-600 transition-colors">
                      <div class="flex items-center gap-2">
                        <div class="i-mdi-shopping h-4 w-4" />
                        Mes commandes
                      </div>
                    </Link>
                    <Link href="/comments" class="block px-4 py-2 text-sm text-gray-700 hover:bg-red-50 hover:text-red-600 transition-colors">
                      <div class="flex items-center gap-2">
                        <div class="i-mdi-comment h-4 w-4" />
                        Mes commentaires
                      </div>
                    </Link>
                  </template>
                  <template v-else-if="user.role === 'seller'">
                    <Link href="/seller/products" class="block px-4 py-2 text-sm text-gray-700 hover:bg-red-50 hover:text-red-600 transition-colors">
                      <div class="flex items-center gap-2">
                        <div class="i-mdi-package-variant h-4 w-4" />
                        Mes annonces
                      </div>
                    </Link>
                    <Link href="/seller/orders" class="block px-4 py-2 text-sm text-gray-700 hover:bg-red-50 hover:text-red-600 transition-colors">
                      <div class="flex items-center gap-2">
                        <div class="i-mdi-cart-outline h-4 w-4" />
                        Commandes vendeur
                      </div>
                    </Link>
                  </template>
                  <template v-else>
                    <Link href="/dashboard" class="block px-4 py-2 text-sm text-gray-700 hover:bg-red-50 hover:text-red-600 transition-colors">
                      <div class="flex items-center gap-2">
                        <div class="i-mdi-view-dashboard h-4 w-4" />
                        Tableau de bord
                      </div>
                    </Link>
                  </template>
                  <div class="border-t border-gray-200 my-1"></div>
                  <Link href="/auth/logout" method="post" as="button" class="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-red-50 hover:text-red-600 transition-colors">
                    <div class="flex items-center gap-2">
                      <div class="i-mdi-logout h-4 w-4" />
                      Déconnexion
                    </div>
                  </Link>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Navigation Categories -->
      <nav class="bg-gray-50 border-t border-gray-200">
        <div class="flex items-center gap-0 overflow-x-auto">
          <Link href="/" class="px-4 py-3 text-sm font-medium text-red-600 border-b-3 border-red-600 whitespace-nowrap">
            Accueil
          </Link>
          <Link href="/catalogue" class="px-4 py-3 text-sm font-medium text-gray-700 hover:text-red-600 border-b-3 border-transparent hover:border-red-600 whitespace-nowrap transition-colors">
            Catalogue
          </Link>
          <a href="#promotions" class="px-4 py-3 text-sm font-medium text-gray-700 hover:text-red-600 border-b-3 border-transparent hover:border-red-600 whitespace-nowrap transition-colors">
            Promotions
          </a>
          <Link href="/privacy" class="px-4 py-3 text-sm font-medium text-gray-700 hover:text-red-600 border-b-3 border-transparent hover:border-red-600 whitespace-nowrap transition-colors">
            Politique de confidentialité
          </Link>
          <!-- <Link href="/categories/pneus" class="px-4 py-3 text-sm font-medium text-gray-700 hover:text-red-600 border-b-3 border-transparent hover:border-red-600 whitespace-nowrap transition-colors">
            Pneus
          </Link>
          <Link href="/categories/freinage" class="px-4 py-3 text-sm font-medium text-gray-700 hover:text-red-600 border-b-3 border-transparent hover:border-red-600 whitespace-nowrap transition-colors">
            Freinage
          </Link>
          <Link href="/categories/eclairage" class="px-4 py-3 text-sm font-medium text-gray-700 hover:text-red-600 border-b-3 border-transparent hover:border-red-600 whitespace-nowrap transition-colors">
            Éclairage
          </Link>
          <Link href="/categories/batterie" class="px-4 py-3 text-sm font-medium text-gray-700 hover:text-red-600 border-b-3 border-transparent hover:border-red-600 whitespace-nowrap transition-colors">
            Batterie
          </Link> -->
        </div>
      </nav>
    </div>
  </header>
</template>
