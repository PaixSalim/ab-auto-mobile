<script setup lang="ts">
import { computed, ref } from 'vue'
import { usePage, Head } from '@inertiajs/vue3'
import Layout from '~/components/admin/Layout.vue'
import PaginatedList from '~/components/admin/PaginatedList.vue'

const page = usePage()
const user = computed(() => page.props.auth.user)
const roles = computed(() => page.props.auth.roles || [])

const isAdmin = computed(() => roles.value.includes('admin') || roles.value.includes('superadmin'))
const isSeller = computed(() => roles.value.includes('seller'))

// Données de test pour le dashboard
const stats = ref({
  totalRevenue: 2847590,
  monthlyRevenue: 487320,
  totalOrders: 1247,
  monthlyOrders: 189,
  totalProducts: 847,
  activeProducts: 623,
  pendingProducts: 45,
  totalCustomers: 3421,
  newCustomers: 287,
  totalSellers: 156,
  pendingSellers: 12,
  conversionRate: 3.8,
  avgOrderValue: 2284,
  topProducts: [
    { name: 'Batterie Varta', sales: 234, revenue: 145890 },
    { name: 'Huile Mobil 1', sales: 189, revenue: 98760 },
    { name: 'Filtre Mann', sales: 156, revenue: 72450 }
  ],
  recentOrders: [
    { id: 'ORD-2024-001', customer: 'Jean Dupont', amount: 2840, status: 'delivered', date: '2024-03-28' },
    { id: 'ORD-2024-002', customer: 'Marie Martin', amount: 1560, status: 'processing', date: '2024-03-28' },
    { id: 'ORD-2024-003', customer: 'Pierre Bernard', amount: 3220, status: 'pending', date: '2024-03-27' }
  ],
  chartData: {
    labels: ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin'],
    revenue: [420000, 480000, 520000, 490000, 580000, 487000],
    orders: [145, 167, 182, 171, 203, 189]
  }
})

// Formatage des nombres
const formatCurrency = (amount: number) => {
  return new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: 'EUR',
    minimumFractionDigits: 0
  }).format(amount)
}

const formatNumber = (num: number) => {
  return new Intl.NumberFormat('fr-FR').format(num)
}

const getChangeColor = (value: number) => {
  return value > 0 ? 'text-green-600' : value < 0 ? 'text-red-600' : 'text-gray-600'
}

const getChangeIcon = (value: number) => {
  return value > 0 ? 'i-mdi-trending-up' : value < 0 ? 'i-mdi-trending-down' : 'i-mdi-minus'
}
</script>

<template>
  <Head title="Tableau de Bord - AB-AUTO"/>
  
  <Layout title="Tableau de Bord">
    <div class="space-y-8">
      <!-- Header -->
      <div class="flex flex-col lg:flex-row justify-between items-start lg:items-center gap-6">
        <div>
          <h1 class="text-4xl font-bold text-gray-900 dark:text-white">
            Bonjour, {{ user?.fullName || 'Utilisateur' }}
          </h1>
          <p class="text-gray-600 dark:text-gray-400 mt-2">
            Voici un aperçu de votre activité commerciale
          </p>
        </div>
        <div class="flex items-center gap-4">
          <button class="px-6 py-3 bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-600 rounded-xl hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors">
            <div class="i-mdi-download text-xl"></div>
          </button>
          <button class="px-6 py-3 bg-primary text-white rounded-xl hover:bg-primary-dark transition-colors">
            <div class="i-mdi-plus text-xl mr-2"></div>
            Nouveau Produit
          </button>
        </div>
      </div>

      <!-- KPI Cards -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <!-- Revenu Total -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl p-6 border border-gray-200 dark:border-gray-700">
          <div class="flex items-center justify-between mb-4">
            <div class="w-12 h-12 bg-blue-100 dark:bg-blue-900 rounded-xl flex items-center justify-center">
              <div class="i-mdi-currency-eur text-blue-600 dark:text-blue-400 text-xl"></div>
            </div>
            <div class="flex items-center text-sm">
              <div class="i-mdi-trending-up text-green-500 mr-1"></div>
              <span class="text-green-500">+12.5%</span>
            </div>
          </div>
          <div class="text-2xl font-bold text-gray-900 dark:text-white">
            {{ formatCurrency(stats.totalRevenue) }}
          </div>
          <div class="text-sm text-gray-600 dark:text-gray-400 mt-1">
            Revenu total
          </div>
        </div>

        <!-- Commandes -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl p-6 border border-gray-200 dark:border-gray-700">
          <div class="flex items-center justify-between mb-4">
            <div class="w-12 h-12 bg-green-100 dark:bg-green-900 rounded-xl flex items-center justify-center">
              <div class="i-mdi-shopping-cart text-green-600 dark:text-green-400 text-xl"></div>
            </div>
            <div class="flex items-center text-sm">
              <div class="i-mdi-trending-up text-green-500 mr-1"></div>
              <span class="text-green-500">+8.3%</span>
            </div>
          </div>
          <div class="text-2xl font-bold text-gray-900 dark:text-white">
            {{ formatNumber(stats.totalOrders) }}
          </div>
          <div class="text-sm text-gray-600 dark:text-gray-400 mt-1">
            Commandes totales
          </div>
        </div>

        <!-- Produits -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl p-6 border border-gray-200 dark:border-gray-700">
          <div class="flex items-center justify-between mb-4">
            <div class="w-12 h-12 bg-purple-100 dark:bg-purple-900 rounded-xl flex items-center justify-center">
              <div class="i-mdi-package-variant text-purple-600 dark:text-purple-400 text-xl"></div>
            </div>
            <div class="flex items-center text-sm">
              <div class="i-mdi-trending-up text-green-500 mr-1"></div>
              <span class="text-green-500">+5.7%</span>
            </div>
          </div>
          <div class="text-2xl font-bold text-gray-900 dark:text-white">
            {{ formatNumber(stats.totalProducts) }}
          </div>
          <div class="text-sm text-gray-600 dark:text-gray-400 mt-1">
            Produits actifs
          </div>
        </div>

        <!-- Clients -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl p-6 border border-gray-200 dark:border-gray-700">
          <div class="flex items-center justify-between mb-4">
            <div class="w-12 h-12 bg-orange-100 dark:bg-orange-900 rounded-xl flex items-center justify-center">
              <div class="i-mdi-account-group text-orange-600 dark:text-orange-400 text-xl"></div>
            </div>
            <div class="flex items-center text-sm">
              <div class="i-mdi-trending-up text-green-500 mr-1"></div>
              <span class="text-green-500">+15.2%</span>
            </div>
          </div>
          <div class="text-2xl font-bold text-gray-900 dark:text-white">
            {{ formatNumber(stats.totalCustomers) }}
          </div>
          <div class="text-sm text-gray-600 dark:text-gray-400 mt-1">
            Clients totaux
          </div>
        </div>
      </div>

      <!-- Charts Section -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <!-- Revenue Chart -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl p-6 border border-gray-200 dark:border-gray-700">
          <div class="flex items-center justify-between mb-6">
            <h3 class="text-lg font-semibold text-gray-900 dark:text-white">
              Évolution des revenus
            </h3>
            <select class="px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-sm">
              <option>6 derniers mois</option>
              <option>12 derniers mois</option>
              <option>24 derniers mois</option>
            </select>
          </div>
          <!-- Simple chart placeholder -->
          <div class="h-64 flex items-end justify-between gap-2">
            <div v-for="(value, index) in chartData.revenue" :key="index" 
                 class="flex-1 bg-blue-500 rounded-t-lg relative group cursor-pointer hover:bg-blue-600 transition-colors"
                 :style="{ height: `${(value / Math.max(...chartData.revenue)) * 100}%` }">
              <div class="absolute -top-8 left-1/2 transform -translate-x-1/2 bg-gray-900 text-white text-xs px-2 py-1 rounded opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap">
                {{ formatCurrency(value) }}
              </div>
            </div>
          </div>
          <div class="flex justify-between mt-2 text-xs text-gray-600 dark:text-gray-400">
            <span v-for="label in chartData.labels" :key="label">{{ label }}</span>
          </div>
        </div>

        <!-- Orders Chart -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl p-6 border border-gray-200 dark:border-gray-700">
          <div class="flex items-center justify-between mb-6">
            <h3 class="text-lg font-semibold text-gray-900 dark:text-white">
              Évolution des commandes
            </h3>
            <select class="px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-sm">
              <option>6 derniers mois</option>
              <option>12 derniers mois</option>
              <option>24 derniers mois</option>
            </select>
          </div>
          <!-- Simple chart placeholder -->
          <div class="h-64 flex items-end justify-between gap-2">
            <div v-for="(value, index) in chartData.orders" :key="index" 
                 class="flex-1 bg-green-500 rounded-t-lg relative group cursor-pointer hover:bg-green-600 transition-colors"
                 :style="{ height: `${(value / Math.max(...chartData.orders)) * 100}%` }">
              <div class="absolute -top-8 left-1/2 transform -translate-x-1/2 bg-gray-900 text-white text-xs px-2 py-1 rounded opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap">
                {{ formatNumber(value) }} commandes
              </div>
            </div>
          </div>
          <div class="flex justify-between mt-2 text-xs text-gray-600 dark:text-gray-400">
            <span v-for="label in chartData.labels" :key="label">{{ label }}</span>
          </div>
        </div>
      </div>

      <!-- Tables Section -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <!-- Top Products -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl p-6 border border-gray-200 dark:border-gray-700">
          <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">
            Produits les plus vendus
          </h3>
          <div class="overflow-x-auto">
            <table class="w-full">
              <thead>
                <tr class="border-b border-gray-200 dark:border-gray-700">
                  <th class="text-left py-3 px-4 text-sm font-medium text-gray-700 dark:text-gray-300">
                    Produit
                  </th>
                  <th class="text-right py-3 px-4 text-sm font-medium text-gray-700 dark:text-gray-300">
                    Ventes
                  </th>
                  <th class="text-right py-3 px-4 text-sm font-medium text-gray-700 dark:text-gray-300">
                    Revenu
                  </th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(product, index) in stats.topProducts" :key="index"
                    class="border-b border-gray-100 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors">
                  <td class="py-3 px-4">
                    <div class="font-medium text-gray-900 dark:text-white">
                      {{ product.name }}
                    </div>
                  </td>
                  <td class="py-3 px-4 text-right text-gray-600 dark:text-gray-400">
                    {{ formatNumber(product.sales) }}
                  </td>
                  <td class="py-3 px-4 text-right font-medium text-gray-900 dark:text-white">
                    {{ formatCurrency(product.revenue) }}
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <!-- Recent Orders -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl p-6 border border-gray-200 dark:border-gray-700">
          <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">
            Commandes récentes
          </h3>
          <div class="overflow-x-auto">
            <table class="w-full">
              <thead>
                <tr class="border-b border-gray-200 dark:border-gray-700">
                  <th class="text-left py-3 px-4 text-sm font-medium text-gray-700 dark:text-gray-300">
                    Commande
                  </th>
                  <th class="text-left py-3 px-4 text-sm font-medium text-gray-700 dark:text-gray-300">
                    Client
                  </th>
                  <th class="text-right py-3 px-4 text-sm font-medium text-gray-700 dark:text-gray-300">
                    Montant
                  </th>
                  <th class="text-center py-3 px-4 text-sm font-medium text-gray-700 dark:text-gray-300">
                    Statut
                  </th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="order in stats.recentOrders" :key="order.id"
                    class="border-b border-gray-100 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors">
                  <td class="py-3 px-4">
                    <div class="font-medium text-gray-900 dark:text-white">
                      {{ order.id }}
                    </div>
                    <div class="text-xs text-gray-500 dark:text-gray-400">
                      {{ order.date }}
                    </div>
                  </td>
                  <td class="py-3 px-4 text-gray-600 dark:text-gray-400">
                    {{ order.customer }}
                  </td>
                  <td class="py-3 px-4 text-right font-medium text-gray-900 dark:text-white">
                    {{ formatCurrency(order.amount) }}
                  </td>
                  <td class="py-3 px-4 text-center">
                    <span :class="{
                      'px-2 py-1 text-xs rounded-full font-medium': true,
                      'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200': order.status === 'delivered',
                      'bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200': order.status === 'processing',
                      'bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200': order.status === 'pending'
                    }">
                      {{ order.status === 'delivered' ? 'Livrée' : 
                         order.status === 'processing' ? 'En cours' : 'En attente' }}
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Additional Stats -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        <!-- Conversion Rate -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl p-6 border border-gray-200 dark:border-gray-700">
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-semibold text-gray-900 dark:text-white">
              Taux de conversion
            </h3>
            <div class="i-mdi-chart-line text-blue-500 text-xl"></div>
          </div>
          <div class="text-3xl font-bold text-gray-900 dark:text-white">
            {{ stats.conversionRate }}%
          </div>
          <div class="text-sm text-gray-600 dark:text-gray-400 mt-2">
            <span class="text-green-500">+0.3%</span> par rapport au mois dernier
          </div>
        </div>

        <!-- Average Order Value -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl p-6 border border-gray-200 dark:border-gray-700">
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-semibold text-gray-900 dark:text-white">
              Panier moyen
            </h3>
            <div class="i-mdi-cash text-green-500 text-xl"></div>
          </div>
          <div class="text-3xl font-bold text-gray-900 dark:text-white">
            {{ formatCurrency(stats.avgOrderValue) }}
          </div>
          <div class="text-sm text-gray-600 dark:text-gray-400 mt-2">
            <span class="text-green-500">+5.2%</span> par rapport au mois dernier
          </div>
        </div>

        <!-- Pending Tasks -->
        <div class="bg-white dark:bg-gray-800 rounded-2xl p-6 border border-gray-200 dark:border-gray-700">
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-semibold text-gray-900 dark:text-white">
              Tâches en attente
            </h3>
            <div class="i-mdi-alert-circle text-orange-500 text-xl"></div>
          </div>
          <div class="text-3xl font-bold text-gray-900 dark:text-white">
            {{ stats.pendingProducts + stats.pendingSellers }}
          </div>
          <div class="text-sm text-gray-600 dark:text-gray-400 mt-2">
            {{ stats.pendingProducts }} produits + {{ stats.pendingSellers }} vendeurs
          </div>
        </div>
      </div>
    </div>
  </Layout>
</template>

<style scoped>
/* Animations */
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

.animate-fade-in {
  animation: fadeIn 0.5s ease-out;
}

/* Chart hover effects */
.group:hover .group-hover\:opacity-100 {
  opacity: 1;
}

/* Smooth transitions */
.transition-all {
  transition: all 0.3s ease;
}
</style>
