<script setup lang="ts">
import { computed } from 'vue'
import { usePage, Head } from '@inertiajs/vue3'
import Layout from '~/components/seller/Layout.vue'
import PaginatedList from '~/components/admin/PaginatedList.vue'

const page = usePage()
const user = computed(() => page.props.auth.user)
const roles = computed(() => page.props.auth.roles || [])

const isSeller = computed(() => roles.value.includes('seller'))

// Définition des en-têtes pour les tableaux
const orderHeaders = [
  { key: 'customer', label: 'Client' },
  { key: 'product', label: 'Produit' },
  { key: 'amount', label: 'Montant' },
  { key: 'date', label: 'Date', textClass: 'text-right' }
]

const productHeaders = [
  { key: 'product', label: 'Article' },
  { key: 'price', label: 'Prix' },
  { key: 'status', label: 'Statut' },
  { key: 'actions', label: 'Action', textClass: 'text-right' }
]

const props = defineProps<{
  stats: {
    products: number
    orders: number
    comments: number
  }
  recentProducts: any[]
  recentOrders?: any[]
}>()

// Log pour déboguer les données reçues

const displayStats = computed(() => {
  const items = [
    { label: 'Mes Articles', value: props.stats.products, icon: 'i-mdi-package-variant', color: 'text-purple-600', bg: 'bg-purple-50' },
    { label: 'Commandes', value: props.stats.orders, icon: 'i-mdi-cart-outline', color: 'text-blue-600', bg: 'bg-blue-50' },
    { label: 'Commentaires', value: props.stats.comments, icon: 'i-mdi-comment-multiple-outline', color: 'text-teal-600', bg: 'bg-teal-50' },
  ]
  
  return items
})
</script>

<template>
  <Head title="Tableau de Bord Vendeur"/>
  
  <Layout title="Tableau de Bord Vendeur">
    <div class="space-y-10">
      <!-- Welcome Section -->
      <!-- <section class="relative overflow-hidden p-8 rounded-[2rem] bg-gradient-to-br from-slate-900 to-slate-800 text-white shadow-2xl">
         <div class="relative z-10 flex flex-col md:flex-row md:items-center justify-between gap-6">
            <div>
               <h3 class="text-3xl font-bold mb-2">Bon retour, {{ user?.fullName }} !</h3>
               <p class="text-slate-400 max-w-md">Voici ce qui se passe sur votre boutique AB-AUTO aujourd'hui.</p>
               <div v-if="user?.registrationNumber" class="mt-4 inline-flex items-center gap-2 px-3 py-1.5 rounded-xl bg-white/5 border border-white/10 text-xs font-mono">
                  <span class="text-slate-500 uppercase">Matricule:</span>
                  <span class="text-primary font-bold">{{ user.registrationNumber }}</span>
               </div>
            </div>
            
            <div class="flex items-center gap-3">
               <button class="bg-primary hover:bg-primary-dark text-white px-6 py-3 rounded-2xl font-bold shadow-lg shadow-primary/20 transition-all active:scale-95">
                  Nouveau Produit
               </button>
            </div>
         </div>
         
         <div class="absolute -top-24 -right-24 w-64 h-64 bg-primary/20 rounded-full blur-[100px]"></div>
         <div class="absolute -bottom-24 -left-24 w-64 h-64 bg-indigo-500/20 rounded-full blur-[100px]"></div>
      </section> -->

      <!-- Stats Grid -->
      <section class="grid grid-cols-1 md:grid-cols-3 gap-6">
         <div v-for="stat in displayStats" :key="stat.label" class="bg-white dark:bg-slate-900 p-6 rounded-3xl border border-slate-200 dark:border-slate-800 shadow-sm hover:shadow-md transition-all">
            <div class="flex items-center gap-5">
               <div :class="[stat.bg, 'w-14 h-14 rounded-2xl flex items-center justify-center']">
                  <div :class="[stat.icon, stat.color, 'text-2xl']"></div>
               </div>
               <div>
                  <p class="text-xs font-bold text-slate-500 uppercase tracking-wider mb-1">{{ stat.label }}</p>
                  <p class="text-2xl font-black text-slate-800 dark:text-white">{{ stat.value }}</p>
               </div>
            </div>
         </div>
      </section>

      <!-- Tables Section -->
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-8 text-slate-800 dark:text-white">
         <div class="lg:col-span-2 space-y-8">
            <!-- Recent Orders -->
            <div v-if="recentOrders?.length" class="bg-white dark:bg-slate-900 rounded-[2rem] border border-slate-200 dark:border-slate-800 overflow-hidden shadow-sm">
               <div class="p-8 border-b border-slate-100 dark:border-slate-800 flex items-center justify-between">
                  <h4 class="text-xl font-bold">Commandes Récentes</h4>
                  <span class="px-3 py-1 bg-blue-50 text-blue-600 text-xs font-bold rounded-lg">{{ recentOrders.length }} commandes</span>
               </div>
               <PaginatedList
                  :items="recentOrders"
                  :headers="orderHeaders"
                  :items-per-page="5"
                  item-name="commandes"
                  empty-message="Aucune commande récente."
               >
                  <template #cell-customer="{ item }">
                     <div>
                        <p class="font-bold text-sm">{{ item.customer?.fullName || 'Client inconnu' }}</p>
                        <p class="text-xs text-slate-500">{{ item.customer?.email || '' }}</p>
                     </div>
                  </template>
                  <template #cell-product="{ item }">
                     <span class="text-sm text-slate-600 dark:text-slate-400">{{ item.product?.name || 'Produit inconnu' }}</span>
                  </template>
                  <template #cell-amount="{ item }">
                     <span class="font-mono font-bold text-sm">{{ (item.quantity * (item.product?.price || 0)).toLocaleString() }} F</span>
                  </template>
                  <template #cell-date="{ item }">
                     <span class="text-xs text-slate-500">
                        {{ new Date(item.createdAt || item.created_at).toLocaleDateString('fr-FR') }}
                     </span>
                  </template>
               </PaginatedList>
            </div>

            <!-- Recent Products -->
            <div class="bg-white dark:bg-slate-900 rounded-[2rem] border border-slate-200 dark:border-slate-800 overflow-hidden shadow-sm">
               <div class="p-8 border-b border-slate-100 dark:border-slate-800 flex items-center justify-between">
                  <h4 class="text-xl font-bold">Mes Articles</h4>
                  <button class="text-primary text-sm font-bold hover:underline">Tout voir</button>
               </div>
               
               <PaginatedList
                  :items="recentProducts"
                  :headers="productHeaders"
                  :items-per-page="5"
                  item-name="mes articles"
                  empty-message="Vous n'avez pas encore ajouté d'article."
               >
                  <template #cell-product="{ item }">
                     <div class="flex items-center gap-4">
                        <div class="w-12 h-12 rounded-xl bg-slate-100 dark:bg-slate-800"></div>
                        <div>
                           <p class="font-bold text-sm">{{ item.name }}</p>
                           <p class="text-[10px] text-slate-500 uppercase">{{ item.category?.name || 'Inconnu' }}</p>
                        </div>
                     </div>
                  </template>
                  <template #cell-price="{ item }">
                     <span class="font-mono font-bold text-sm">{{ item.price }} F</span>
                  </template>
                  <template #cell-status="{ item }">
                     <span class="px-2 py-1 rounded-lg text-[10px] font-black uppercase bg-emerald-100 text-emerald-600 dark:bg-emerald-900/30 dark:text-emerald-400">Actif</span>
                  </template>
                  <template #cell-actions="{ item }">
                     <button class="p-2 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-lg transition-colors">
                        <div class="i-mdi-pencil-outline text-lg text-slate-400"></div>
                     </button>
                  </template>
               </PaginatedList>
            </div>
         </div>

    
      </div>
    </div>
  </Layout>
</template>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;900&display=swap');

.font-sans {
  font-family: 'Inter', sans-serif;
}
</style>
