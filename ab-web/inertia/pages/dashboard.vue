<script setup lang="ts">
import { computed } from 'vue'
import { usePage, Head } from '@inertiajs/vue3'
import Layout from '~/components/admin/Layout.vue'
import PaginatedList from '~/components/admin/PaginatedList.vue'
import { usePermissions } from '~/composables/usePermissions'

const page = usePage()
const user = computed(() => page.props.auth.user)
const { isSuperAdmin, isAdminRole, isSellerRole, can } = usePermissions()

/** Affichage « vue admin » (stats / blocs) : admin ou superadmin, pas le vendeur seul */
const isAdmin = computed(() => isAdminRole.value)
const isSeller = computed(() => isSellerRole.value && !isAdminRole.value)

// Définition des en-têtes pour les tableaux
const sellerHeaders = [
  { key: 'fullName', label: 'Vendeur' },
  { key: 'companyName', label: 'Entreprise' },
  { key: 'actions', label: 'Actions', textClass: 'text-right' }
]

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
    pendingSellers?: number
    categories?: number
    brands?: number
    customers?: number
    validatedSellers?: number
    pendingProducts?: number
    validatedProducts?: number
    comments?: number
  }
  recentProducts: any[]
  recentOrders?: any[]
  pendingSellersList?: any[]
}>()

const displayStats = computed(() => {
  type Stat = {
    label: string
    value: number
    icon: string
    color: string
    bg: string
    /** Au moins une permission requise (superadmin : ignoré, tout voir) */
    anyPerm?: string[]
  }

  const sellerStats: Stat[] = [
    { label: 'Articles soumis', value: props.stats.products, icon: 'i-mdi-package-variant', color: 'text-purple-600', bg: 'bg-purple-50' },
    { label: 'Article en attente', value: props.stats.pendingProducts || 0, icon: 'i-mdi-clock-outline', color: 'text-amber-600', bg: 'bg-amber-50' },
    { label: 'Articles validés', value: props.stats.validatedProducts || 0, icon: 'i-mdi-check-circle', color: 'text-green-600', bg: 'bg-green-50' },
    { label: 'Commandes', value: props.stats.orders, icon: 'i-mdi-cart-outline', color: 'text-blue-600', bg: 'bg-blue-50' },
  ]

  if (!isAdmin.value) {
    return sellerStats
  }

  const adminStats: Stat[] = [
    { label: 'Articles soumis', value: props.stats.products, icon: 'i-mdi-package-variant', color: 'text-purple-600', bg: 'bg-purple-50', anyPerm: ['view_all_products', 'manage_all_products', 'validate_products'] },
    { label: 'Article en attente', value: props.stats.pendingProducts || 0, icon: 'i-mdi-clock-outline', color: 'text-amber-600', bg: 'bg-amber-50', anyPerm: ['validate_products', 'view_all_products', 'manage_all_products'] },
    { label: 'Articles validés', value: props.stats.validatedProducts || 0, icon: 'i-mdi-check-circle', color: 'text-green-600', bg: 'bg-green-50', anyPerm: ['view_all_products', 'manage_all_products'] },
    { label: 'Commandes', value: props.stats.orders, icon: 'i-mdi-cart-outline', color: 'text-blue-600', bg: 'bg-blue-50', anyPerm: ['view_all_orders', 'manage_all_orders'] },
    { label: 'Vendeurs validés', value: props.stats.validatedSellers || 0, icon: 'i-mdi-account-check', color: 'text-green-600', bg: 'bg-green-50', anyPerm: ['view_sellers', 'manage_sellers', 'validate_sellers'] },
    { label: 'Vendeurs en attente', value: props.stats.pendingSellers || 0, icon: 'i-mdi-account-clock-outline', color: 'text-orange-600', bg: 'bg-orange-50', anyPerm: ['view_sellers', 'validate_sellers', 'manage_sellers'] },
    { label: 'Clients', value: props.stats.customers || 0, icon: 'i-mdi-account-group', color: 'text-cyan-600', bg: 'bg-cyan-50', anyPerm: ['view_customers', 'manage_customers'] },
    { label: 'Catégories', value: props.stats.categories || 0, icon: 'i-mdi-folder-outline', color: 'text-indigo-600', bg: 'bg-indigo-50', anyPerm: ['view_categories', 'manage_categories'] },
    { label: 'Marques', value: props.stats.brands || 0, icon: 'i-mdi-tag-outline', color: 'text-pink-600', bg: 'bg-pink-50', anyPerm: ['view_brands', 'manage_brands'] },
    { label: 'Commentaires', value: props.stats.comments || 0, icon: 'i-mdi-comment-multiple-outline', color: 'text-teal-600', bg: 'bg-teal-50', anyPerm: ['view_comments', 'manage_comments'] },
  ]

  if (isSuperAdmin.value) {
    return adminStats.map(({ anyPerm: _a, ...rest }) => rest)
  }

  return adminStats
    .filter((s) => !s.anyPerm?.length || s.anyPerm.some((p) => can(p)))
    .map(({ anyPerm: _a, ...rest }) => rest)
})

const showPendingSellersBlock = computed(
  () =>
    isAdmin.value &&
    (props.pendingSellersList?.length ?? 0) > 0 &&
    (can('view_sellers') || can('validate_sellers') || can('manage_sellers')),
)

const showRecentOrdersBlock = computed(
  () =>
    isAdmin.value &&
    (props.recentOrders?.length ?? 0) > 0 &&
    (can('view_all_orders') || can('manage_all_orders')),
)

/** Tableau « derniers articles » côté admin : uniquement si permission catalogue / validation */
const showAdminRecentProducts = computed(
  () =>
    can('view_all_products') ||
    can('manage_all_products') ||
    can('validate_products'),
)

</script>

<template>
  <Head title="Tableau de Bord"/>
  
  <Layout :title="'Tableau de Bord ' + (isAdmin ? 'Admin' : 'Vendeur')">
    <div class="space-y-8">
      <!-- Stats Grid -->
      <section :class="isAdmin ? 'grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6' : 'grid grid-cols-1 md:grid-cols-3 gap-6'">
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
            <!-- Pending Sellers List (Admin Only) -->
            <div v-if="showPendingSellersBlock" class="bg-white dark:bg-slate-900 rounded-[2rem] border border-slate-200 dark:border-slate-800 overflow-hidden shadow-sm">
               <div class="p-8 border-b border-slate-100 dark:border-slate-800 flex items-center justify-between">
                  <h4 class="text-xl font-bold">Inscriptions à valider</h4>
                  <span class="px-3 py-1 bg-red-50 text-red-600 text-xs font-bold rounded-lg">{{ pendingSellersList.length }} nouveaux</span>
               </div>
               
               <PaginatedList
                  :items="pendingSellersList"
                  :headers="sellerHeaders"
                  :items-per-page="5"
                  item-name="vendeurs"
                  empty-message="Aucun vendeur en attente de validation."
               >
                  <template #cell-fullName="{ item }">
                     <div>
                        <p class="font-bold text-sm">{{ item.fullName }}</p>
                        <p class="text-xs text-slate-500">{{ item.email }}</p>
                     </div>
                  </template>
                  <template #cell-actions="{ item }">
                     <div class="text-right space-x-2">
                        <button class="px-4 py-2 bg-emerald-500 hover:bg-emerald-600 text-white text-xs font-bold rounded-xl transition-all shadow-lg shadow-emerald-500/10">Valider</button>
                        <button class="px-4 py-2 bg-slate-100 dark:bg-slate-800 hover:bg-red-50 hover:text-red-600 text-xs font-bold rounded-xl transition-all">Rejeter</button>
                     </div>
                  </template>
               </PaginatedList>
            </div>

            <!-- Recent Orders (Admin Only) -->
            <div v-if="showRecentOrdersBlock" class="bg-white dark:bg-slate-900 rounded-[2rem] border border-slate-200 dark:border-slate-800 overflow-hidden shadow-sm">
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
            <div
              v-if="!isAdmin || showAdminRecentProducts"
              class="bg-white dark:bg-slate-900 rounded-[2rem] border border-slate-200 dark:border-slate-800 overflow-hidden shadow-sm"
            >
               <div class="p-8 border-b border-slate-100 dark:border-slate-800 flex items-center justify-between">
                  <h4 class="text-xl font-bold">{{ isAdmin ? 'Derniers Articles' : 'Mes Articles' }}</h4>
                  <button class="text-primary text-sm font-bold hover:underline">Tout voir</button>
               </div>
               
               <PaginatedList
                  :items="recentProducts"
                  :headers="productHeaders"
                  :items-per-page="5"
                  :item-name="isAdmin ? 'articles' : 'mes articles'"
                  :empty-message="isAdmin ? 'Aucun article ajouté pour le moment.' : 'Vous n\'avez pas encore ajouté d\'article.'"
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

         <!-- Right Column: Quick Stats / Profile Info -->
         <aside class="space-y-8">
            <div class="bg-white dark:bg-slate-900 rounded-[2rem] border border-slate-200 dark:border-slate-800 p-8 shadow-sm">
               <h4 class="text-lg font-bold mb-6">{{ isAdmin ? 'Vue d\'ensemble' : 'Informations' }}</h4>
               <div class="space-y-6">
                  <div v-if="isAdmin && (can('view_all_orders') || can('manage_all_orders')) && (can('view_all_products') || can('manage_all_products'))" class="flex items-start gap-4">
                     <div class="w-10 h-10 rounded-xl bg-slate-50 dark:bg-slate-800 flex items-center justify-center">
                        <div class="i-mdi-trending-up text-slate-400"></div>
                     </div>
                     <div>
                        <p class="text-[10px] font-black text-slate-400 uppercase tracking-widest">Taux de conversion</p>
                        <p class="text-sm font-bold">{{ Math.round((stats.orders / Math.max(stats.products, 1)) * 100) }}%</p>
                     </div>
                  </div>
                  <div v-if="isAdmin && (can('view_sellers') || can('validate_sellers') || can('manage_sellers'))" class="flex items-start gap-4">
                     <div class="w-10 h-10 rounded-xl bg-slate-50 dark:bg-slate-800 flex items-center justify-center">
                        <div class="i-mdi-account-multiple text-slate-400"></div>
                     </div>
                     <div>
                        <p class="text-[10px] font-black text-slate-400 uppercase tracking-widest">Total vendeurs</p>
                        <p class="text-sm font-bold">{{ (stats.validatedSellers || 0) + (stats.pendingSellers || 0) }}</p>
                     </div>
                  </div>
                  <div class="flex items-start gap-4">
                     <div class="w-10 h-10 rounded-xl bg-slate-50 dark:bg-slate-800 flex items-center justify-center">
                        <div class="i-mdi-map-marker text-slate-400"></div>
                     </div>
                     <div>
                        <p class="text-[10px] font-black text-slate-400 uppercase tracking-widest">Localisation</p>
                        <p class="text-sm font-bold">{{ user?.city || 'Ouagadougou' }}, {{ user?.neighborhood || 'Burkina Faso' }}</p>
                     </div>
                  </div>
                  <div class="flex items-start gap-4">
                     <div class="w-10 h-10 rounded-xl bg-slate-50 dark:bg-slate-800 flex items-center justify-center">
                        <div class="i-mdi-building text-slate-400"></div>
                     </div>
                     <div>
                        <p class="text-[10px] font-black text-slate-400 uppercase tracking-widest">Entreprise</p>
                        <p class="text-sm font-bold">{{ user?.companyName || (isAdmin ? 'AB-AUTO Admin' : 'Individuel') }}</p>
                     </div>
                  </div>
                  <div v-if="isAdmin && isSuperAdmin" class="flex items-start gap-4">
                     <div class="w-10 h-10 rounded-xl bg-slate-50 dark:bg-slate-800 flex items-center justify-center">
                        <div class="i-mdi-calendar text-slate-400"></div>
                     </div>
                     <!-- <div>
                        <p class="text-[10px] font-black text-slate-400 uppercase tracking-widest">Système actif</p>
                        <p class="text-sm font-bold">{{ Math.floor((Date.now() - new Date('2024-01-01').getTime()) / (1000 * 60 * 60 * 24)) }} jours</p>
                     </div> -->
                  </div>
               </div>
            </div>
            
            <!-- Quick Help -->
            <div class="p-6 rounded-[2rem] bg-gradient-to-br from-slate-900 to-slate-950 border border-slate-800 shadow-xl">
               <p class="text-[10px] text-slate-500 font-bold mb-3 uppercase tracking-widest text-center">Besoin d'aide ?</p>
               <button class="w-full bg-white/5 hover:bg-white/10 text-white text-sm py-3 rounded-2xl transition border border-white/5 font-bold">
                  Support Technique
               </button>
            </div>
         </aside>
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
