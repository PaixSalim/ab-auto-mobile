<template>
  <Layout title="Commentaires sur mes produits">
    <div class="p-6">
      <div class="flex justify-between items-center mb-6">
        <h1 class="text-2xl font-bold text-black">Commentaires sur mes produits</h1>
        <div class="flex gap-2">
          <button
            @click="refreshComments"
            class="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
          >
            <div class="i-mdi-refresh text-lg"></div>
            Actualiser
          </button>
        </div>
      </div>

      <!-- Statistiques -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
        <div class="bg-white p-4 rounded-lg shadow border">
          <div class="flex items-center">
            <div class="p-3 bg-blue-100 rounded-full">
              <div class="i-mdi-comment-multiple text-blue-600 text-xl"></div>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-600">Total Commentaires</p>
              <p class="text-2xl font-bold text-gray-900">{{ totalComments }}</p>
            </div>
          </div>
        </div>
        <div class="bg-white p-4 rounded-lg shadow border">
          <div class="flex items-center">
            <div class="p-3 bg-green-100 rounded-full">
              <div class="i-mdi-package-variant text-green-600 text-xl"></div>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-600">Produits avec commentaires</p>
              <p class="text-2xl font-bold text-gray-900">{{ productsWithComments.length }}</p>
            </div>
          </div>
        </div>
        <div class="bg-white p-4 rounded-lg shadow border">
          <div class="flex items-center">
            <div class="p-3 bg-purple-100 rounded-full">
              <div class="i-mdi-star text-purple-600 text-xl"></div>
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-600">Moyenne par produit</p>
              <p class="text-2xl font-bold text-gray-900">{{ averageComments }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Filtres -->
      <div class="bg-white p-4 rounded-lg shadow mb-6 border">
        <div class="flex flex-wrap gap-4">
          <div class="flex-1 min-w-[200px]">
            <label class="block text-sm font-medium text-gray-700 mb-1">Recherche</label>
            <div class="relative">
              <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                <div class="i-mdi-magnify text-gray-400"></div>
              </div>
              <input
                v-model="filters.search"
                type="text"
                placeholder="Rechercher par utilisateur ou contenu..."
                class="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
              />
            </div>
          </div>
          <div class="w-[200px]">
            <label class="block text-sm font-medium text-gray-700 mb-1">Produit</label>
            <select
              v-model="filters.productId"
              class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
            >
              <option value="">Tous les produits</option>
              <option v-for="product in products" :key="product.id" :value="product.id">
                {{ product.name }}
              </option>
            </select>
          </div>
        </div>
      </div>

      <!-- Tableau des commentaires -->
      <div class="bg-white rounded-lg shadow overflow-hidden border">
        <!-- Message si aucun commentaire -->
        <div v-if="filteredComments.length === 0" class="p-8 text-center">
          <div class="i-mdi-comment-off text-6xl mx-auto mb-4 text-gray-400"></div>
          <h3 class="text-xl font-medium text-gray-900 mb-2">Aucun commentaire trouvé</h3>
          <p class="text-gray-500">
            {{ hasFilters ? 'Essayez de modifier vos filtres pour voir plus de résultats.' : 'Aucun commentaire n\'a été ajouté pour le moment.' }}
          </p>
        </div>

        <!-- Tableau des commentaires -->
        <table v-else class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Utilisateur
              </th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Commentaire
              </th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Produit
              </th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Date
              </th>
              <th scope="col" class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                Actions
              </th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr v-for="comment in filteredComments" :key="comment.id" class="hover:bg-gray-50">
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="flex items-center">
                  <div class="flex-shrink-0 h-10 w-10 bg-gray-200 rounded-full flex items-center justify-center">
                    <div class="i-mdi-account text-xl text-gray-500"></div>
                  </div>
                  <div class="ml-4">
                    <div class="text-sm font-medium text-gray-900">{{ comment.user || 'Client anonyme' }}</div>
                    <div class="text-sm text-gray-500">IP: {{ comment.ip || 'Non disponible' }}</div>
                  </div>
                </div>
              </td>
              <td class="px-6 py-4">
                <div class="text-sm text-gray-900 max-w-xs">{{ comment.comment }}</div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="text-sm text-gray-900">
                  {{ getProductName(comment.productId) }}
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="text-sm text-gray-500">
                  {{ formatDate(comment.createdAt) }}
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                <div class="flex justify-end space-x-2">
                  <button
                    @click="replyToComment(comment)"
                    class="text-blue-600 hover:text-blue-900"
                    title="Répondre"
                  >
                    <div class="i-mdi-reply text-xl"></div>
                  </button>
                  <button
                    @click="viewComment(comment)"
                    class="text-gray-400 hover:text-gray-600"
                    title="Voir les détails"
                  >
                    <div class="i-mdi-eye text-xl"></div>
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </Layout>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { router } from '@inertiajs/vue3'
import Layout from '~/components/seller/Layout.vue'

// Log pour vérifier si le template est chargé

interface Comment {
  id: number
  user: string
  comment: string
  isActive: boolean
  createdAt: string
  productId: number
  ip?: string
  replies?: Comment[]
}

interface Product {
  id: number
  name: string
  category?: { name: string }
  medias?: { url: string }[]
  comments?: Comment[]
}

const props = defineProps<{
  products: Product[]
}>()

// Log pour déboguer les données reçues

// État réactif
const filters = ref({
  search: '',
  productId: ''
})

// Fonctions utilitaires
function formatDate(date: string) {
  return new Date(date).toLocaleDateString('fr-FR', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  })
}

function getProductName(productId: number) {
  const product = props.products.find(p => p.id === productId)
  return product ? product.name : 'Produit inconnu'
}

function refreshComments() {
  router.reload()
}

function replyToComment(comment: Comment) {
  // Implémenter la logique de réponse
}

function viewComment(comment: Comment) {
  // Implémenter la logique de vue détaillée
}

// Computed properties
const allComments = computed(() => {
  const comments: Comment[] = []
  props.products.forEach(product => {
    if (product.comments) {
      comments.push(...product.comments)
    }
  })
  return comments
})

const filteredComments = computed(() => {
  let comments = allComments.value

  // Filtrer par recherche
  if (filters.value.search) {
    const search = filters.value.search.toLowerCase()
    comments = comments.filter(comment => 
      comment.user?.toLowerCase().includes(search) ||
      comment.comment.toLowerCase().includes(search)
    )
  }

  // Filtrer par produit
  if (filters.value.productId) {
    comments = comments.filter(comment => comment.productId === parseInt(filters.value.productId))
  }

  return comments
})

const productsWithComments = computed(() => {
  return props.products.filter(product => product.comments && product.comments.length > 0)
})

const totalComments = computed(() => {
  return allComments.value.length
})

const averageComments = computed(() => {
  const productsCount = productsWithComments.value.length
  if (productsCount === 0) return 0
  return Math.round(totalComments.value / productsCount * 10) / 10
})

const hasFilters = computed(() => {
  return filters.value.search || filters.value.productId
})
</script>
