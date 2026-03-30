<template>
  <div class="min-h-screen bg-gray-50">
    <div class="container mx-auto py-6">
      <div class="mb-6">
        <h1 class="text-2xl font-bold text-gray-900 mb-2">Gestion des commentaires</h1>
        <p class="text-gray-600">Modérez et gérez tous les commentaires des utilisateurs</p>
      </div>

      <!-- Filtres -->
      <div class="bg-white rounded-lg shadow-sm p-4 mb-6">
        <div class="flex flex-wrap gap-4 items-end">
          <div class="flex-1 min-w-48">
            <label class="block text-sm font-medium text-gray-700 mb-2">Rechercher</label>
            <input
              v-model="searchQuery"
              type="text"
              placeholder="Rechercher un commentaire..."
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
            />
          </div>
          
          <div class="min-w-48">
            <label class="block text-sm font-medium text-gray-700 mb-2">Statut</label>
            <select
              v-model="statusFilter"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
            >
              <option value="">Tous</option>
              <option value="active">Actifs</option>
              <option value="inactive">Inactifs</option>
            </select>
          </div>

          <div class="min-w-48">
            <label class="block text-sm font-medium text-gray-700 mb-2">Produit</label>
            <select
              v-model="productFilter"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
            >
              <option value="">Tous les produits</option>
              <option v-for="product in products" :key="product.id" :value="product.id">
                {{ product.name }}
              </option>
            </select>
          </div>
        </div>
      </div>

      <!-- Liste des commentaires -->
      <div class="bg-white rounded-lg shadow-sm overflow-hidden">
        <div v-if="filteredComments.length === 0" class="text-center py-12">
          <div class="i-mdi-message-text text-4xl text-gray-400 mb-4"></div>
          <h3 class="text-lg font-medium text-gray-900 mb-2">Aucun commentaire trouvé</h3>
          <p class="text-gray-500">
            {{ searchQuery || statusFilter || productFilter 
              ? 'Essayez de modifier vos filtres' 
              : 'Les commentaires apparaîtront ici une fois que les utilisateurs commenceront à donner leur avis' }}
          </p>
        </div>

        <div v-else class="divide-y divide-gray-200">
          <div
            v-for="comment in paginatedComments"
            :key="comment.id"
            class="p-6 hover:bg-gray-50 transition-colors"
          >
            <div class="flex items-start justify-between">
              <div class="flex-1">
                <div class="flex items-center gap-3 mb-3">
                  <div class="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center">
                    <span class="i-mdi-account text-primary"></span>
                  </div>
                  <div>
                    <h4 class="font-semibold text-gray-900">
                      {{ comment.author?.fullName || comment.user }}
                    </h4>
                    <p class="text-sm text-gray-500">
                      {{ formatDate(comment.createdAt) }} • 
                      <span class="font-medium">{{ comment.product?.name }}</span>
                    </p>
                  </div>
                </div>
                
                <p class="text-gray-700 mb-3">{{ comment.comment }}</p>
                
                <!-- Actions -->
                <div class="flex items-center gap-2">
                  <button
                    @click="toggleStatus(comment)"
                    :class="[
                      'px-3 py-1 rounded-full text-xs font-medium transition-colors',
                      comment.isActive 
                        ? 'bg-red-100 text-red-700 hover:bg-red-200' 
                        : 'bg-green-100 text-green-700 hover:bg-green-200'
                    ]"
                  >
                    <span class="i-mdi-eye mr-1"></span>
                    {{ comment.isActive ? 'Désactiver' : 'Activer' }}
                  </button>
                  
                  <button
                    @click="editComment(comment)"
                    class="px-3 py-1 bg-blue-100 text-blue-700 rounded-full text-xs font-medium hover:bg-blue-200 transition-colors"
                  >
                    <span class="i-mdi-pencil mr-1"></span>
                    Modifier
                  </button>
                  
                  <button
                    @click="deleteComment(comment)"
                    class="px-3 py-1 bg-red-100 text-red-700 rounded-full text-xs font-medium hover:bg-red-200 transition-colors"
                  >
                    <span class="i-mdi-delete mr-1"></span>
                    Supprimer
                  </button>
                </div>
              </div>
              
              <!-- Statut badge -->
              <div class="ml-4">
                <span
                  :class="[
                    'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium',
                    comment.isActive 
                      ? 'bg-green-100 text-green-800' 
                      : 'bg-gray-100 text-gray-800'
                  ]"
                >
                  <span class="i-mdi-check-circle mr-1" v-if="comment.isActive"></span>
                  <span class="i-mdi-close-circle mr-1" v-else></span>
                  {{ comment.isActive ? 'Actif' : 'Inactif' }}
                </span>
              </div>
            </div>
          </div>
        </div>

        <!-- Pagination -->
        <div v-if="totalPages > 1" class="px-6 py-4 border-t border-gray-200">
          <div class="flex items-center justify-between">
            <div class="text-sm text-gray-700">
              Affichage de {{ startIndex + 1 }} à {{ endIndex }} sur {{ filteredComments.length }} commentaires
            </div>
            <div class="flex gap-2">
              <button
                @click="currentPage--"
                :disabled="currentPage === 1"
                class="px-3 py-1 border border-gray-300 rounded-md text-sm font-medium hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Précédent
              </button>
              
              <span class="px-3 py-1 text-sm font-medium">
                Page {{ currentPage }} sur {{ totalPages }}
              </span>
              
              <button
                @click="currentPage++"
                :disabled="currentPage === totalPages"
                class="px-3 py-1 border border-gray-300 rounded-md text-sm font-medium hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Suivant
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal d'édition -->
    <div
      v-if="editingComment"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
      @click.self="editingComment = null"
    >
      <div class="bg-white rounded-lg shadow-xl p-6 max-w-2xl w-full mx-4 max-h-[80vh] overflow-y-auto">
        <h3 class="text-lg font-semibold mb-4">Modifier le commentaire</h3>
        
        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700 mb-2">Commentaire</label>
          <textarea
            v-model="editingComment.comment"
            rows="4"
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
          ></textarea>
        </div>
        
        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700 mb-2">Statut</label>
          <select
            v-model="editingComment.isActive"
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
          >
            <option :value="true">Actif</option>
            <option :value="false">Inactif</option>
          </select>
        </div>
        
        <div class="flex justify-end gap-3">
          <button
            @click="editingComment = null"
            class="px-4 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50"
          >
            Annuler
          </button>
          <button
            @click="saveEdit"
            :disabled="isSaving"
            class="px-4 py-2 bg-primary text-white rounded-md hover:bg-primary/90 disabled:opacity-50"
          >
            <span v-if="isSaving" class="i-line-md-loading-loop mr-2"></span>
            Enregistrer
          </button>
        </div>
      </div>
    </div>

    <!-- Toast de succès -->
    <div
      v-if="showToast"
      class="fixed bottom-4 right-4 bg-green-500 text-white px-6 py-3 rounded-lg shadow-lg flex items-center gap-2 max-w-md z-50"
    >
      <span class="i-mdi-check-circle text-xl"></span>
      <div>
        <p class="font-semibold">{{ toastTitle }}</p>
        <p class="text-sm">{{ toastMessage }}</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { router } from '@inertiajs/vue3'

interface Comment {
  id: number
  user?: string
  comment: string
  isActive: boolean
  createdAt: string
  author?: {
    id: number
    fullName: string
  }
  product?: {
    id: number
    name: string
  }
  replies?: Comment[]
}

interface Product {
  id: number
  name: string
}

const searchQuery = ref('')
const statusFilter = ref('')
const productFilter = ref('')
const currentPage = ref(1)
const itemsPerPage = 10
const editingComment = ref<Comment | null>(null)
const isSaving = ref(false)
const showToast = ref(false)
const toastTitle = ref('')
const toastMessage = ref('')

// Données simulées - à remplacer par un appel API
const comments = ref<Comment[]>([
  {
    id: 1,
    user: 'Jean Dupont',
    comment: 'Excellent produit, je suis très satisfait de mon achat !',
    isActive: true,
    createdAt: '2024-01-15T10:30:00Z',
    author: { id: 1, fullName: 'Jean Dupont' },
    product: { id: 1, name: 'iPhone 13 Pro' }
  },
  {
    id: 2,
    user: 'Marie Martin',
    comment: 'Bon rapport qualité/prix, livraison rapide.',
    isActive: true,
    createdAt: '2024-01-14T15:45:00Z',
    author: { id: 2, fullName: 'Marie Martin' },
    product: { id: 2, name: 'MacBook Air M2' }
  },
  {
    id: 3,
    user: 'Paul Durand',
    comment: 'Produit conforme à la description, je recommande.',
    isActive: false,
    createdAt: '2024-01-13T09:20:00Z',
    author: { id: 3, fullName: 'Paul Durand' },
    product: { id: 1, name: 'iPhone 13 Pro' }
  }
])

const products = ref<Product[]>([
  { id: 1, name: 'iPhone 13 Pro' },
  { id: 2, name: 'MacBook Air M2' },
  { id: 3, name: 'iPad Pro 2024' }
])

// Filtrage
const filteredComments = computed(() => {
  return comments.value.filter(comment => {
    const matchesSearch = !searchQuery.value || 
      comment.comment.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
      (comment.author?.fullName || comment.user || '').toLowerCase().includes(searchQuery.value.toLowerCase())
    
    const matchesStatus = !statusFilter.value || 
      (statusFilter.value === 'active' && comment.isActive) ||
      (statusFilter.value === 'inactive' && !comment.isActive)
    
    const matchesProduct = !productFilter.value || comment.product?.id === parseInt(productFilter.value)
    
    return matchesSearch && matchesStatus && matchesProduct
  })
})

// Pagination
const totalPages = computed(() => Math.ceil(filteredComments.value.length / itemsPerPage))
const startIndex = computed(() => (currentPage.value - 1) * itemsPerPage)
const endIndex = computed(() => Math.min(startIndex.value + itemsPerPage, filteredComments.value.length))
const paginatedComments = computed(() => {
  return filteredComments.value.slice(startIndex.value, endIndex.value)
})

// Méthodes
function formatDate(date: string) {
  return new Date(date).toLocaleDateString('fr-FR', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

async function toggleStatus(comment: Comment) {
  try {
    const response = await fetch(`/api/v1/admin/comments/${comment.id}/toggle`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ status: !comment.isActive })
    })
    
    if (response.ok) {
      comment.isActive = !comment.isActive
      showToast.value = true
      toastTitle.value = 'Succès'
      toastMessage.value = comment.isActive 
        ? 'Commentaire activé avec succès' 
        : 'Commentaire désactivé avec succès'
      setTimeout(() => { showToast.value = false }, 3000)
    }
  } catch (error) {
  }
}

function editComment(comment: Comment) {
  editingComment.value = { ...comment }
}

async function saveEdit() {
  if (!editingComment.value) return
  
  isSaving.value = true
  try {
    const response = await fetch(`/api/v1/admin/comments/${editingComment.value.id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        comment: editingComment.value.comment,
        isActive: editingComment.value.isActive
      })
    })
    
    if (response.ok) {
      const index = comments.value.findIndex(c => c.id === editingComment.value!.id)
      if (index !== -1) {
        comments.value[index] = { ...editingComment.value }
      }
      editingComment.value = null
      showToast.value = true
      toastTitle.value = 'Succès'
      toastMessage.value = 'Commentaire modifié avec succès'
      setTimeout(() => { showToast.value = false }, 3000)
    }
  } catch (error) {
  } finally {
    isSaving.value = false
  }
}

async function deleteComment(comment: Comment) {
  if (!confirm('Êtes-vous sûr de vouloir supprimer ce commentaire ?')) return
  
  try {
    const response = await fetch(`/api/v1/admin/comments/${comment.id}`, {
      method: 'DELETE'
    })
    
    if (response.ok) {
      comments.value = comments.value.filter(c => c.id !== comment.id)
      showToast.value = true
      toastTitle.value = 'Succès'
      toastMessage.value = 'Commentaire supprimé avec succès'
      setTimeout(() => { showToast.value = false }, 3000)
    }
  } catch (error) {
  }
}

// Réinitialiser la pagination quand les filtres changent
onMounted(() => {
  currentPage.value = 1
})
</script>
