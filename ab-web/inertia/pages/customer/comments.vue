<script setup lang="ts">
import { ref } from 'vue'

interface Comment {
  id: number
  comment: string
  isActive: boolean
  createdAt: string
  product: {
    id: number
    name: string
    slug: string
    image?: string
  }
}

const props = withDefaults(
  defineProps<{
    comments: Comment[]
  }>(),
  { comments: () => [] },
)

const selectedComment = ref<Comment | null>(null)
const showDetails = ref(false)

function viewComment(comment: Comment) {
  selectedComment.value = comment
  showDetails.value = true
}

function closeDetails() {
  showDetails.value = false
  selectedComment.value = null
}

function getStatusColor(isActive: boolean) {
  return isActive 
    ? 'bg-green-100 text-green-800' 
    : 'bg-yellow-100 text-yellow-800'
}

function getStatusText(isActive: boolean) {
  return isActive ? 'Publié' : 'En attente de modération'
}

function formatDate(dateString: string) {
  return new Date(dateString).toLocaleDateString('fr-FR', {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

function truncateText(text: string, maxLength: number = 150) {
  return text.length > maxLength ? text.substring(0, maxLength) + '...' : text
}
</script>

<template>
  <div class="max-w-6xl mx-auto p-6">
    <div class="mb-8">
      <div class="flex items-center gap-4 mb-4">
        <a href="/" class="inline-flex items-center text-gray-600 hover:text-gray-900 transition-colors">
          <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
          </svg>
          Retour à l'accueil
        </a>
      </div>
      <h1 class="text-3xl font-bold text-gray-900 mb-2">Mes Commentaires</h1>
      <p class="text-gray-600">Consultez tous vos commentaires et leur statut</p>
    </div>

    <div v-if="comments.length === 0" class="text-center py-12">
      <div class="text-gray-400 mb-4">
        <svg class="w-24 h-24 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
        </svg>
      </div>
      <h3 class="text-xl font-semibold text-gray-900 mb-2">Aucun commentaire</h3>
      <p class="text-gray-600 mb-6">Vous n'avez pas encore laissé de commentaire</p>
      <a href="/catalogue" class="inline-flex items-center px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors">
        <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z" />
        </svg>
        Parcourir les produits
      </a>
    </div>

    <div v-else class="space-y-4">
      <div v-for="comment in comments" :key="comment.id" class="bg-white rounded-lg shadow-sm border border-gray-200 p-6 hover:shadow-md transition-shadow">
        <div class="flex items-start justify-between">
          <div class="flex-1">
            <div class="flex items-center gap-4 mb-3">
              <span class="text-sm font-medium text-gray-500">Commentaire #{{ comment.id }}</span>
              <span :class="['px-2 py-1 rounded-full text-xs font-medium', getStatusColor(comment.isActive)]">
                {{ getStatusText(comment.isActive) }}
              </span>
            </div>
            
            <h3 class="text-lg font-semibold text-gray-900 mb-2">{{ comment.product.name }}</h3>
            
            <div class="text-gray-700 mb-3">
              <p>{{ truncateText(comment.comment) }}</p>
            </div>

            <div class="flex items-center justify-between text-sm text-gray-600">
              <div>
                <span class="font-medium">Date:</span> {{ formatDate(comment.createdAt) }}
              </div>
              <div class="flex gap-3">
                <a 
                  :href="`/catalogue/product/${comment.product.slug}`"
                  class="text-blue-600 hover:text-blue-800 font-medium"
                >
                  Voir le produit
                </a>
                <button
                  @click="viewComment(comment)"
                  class="text-gray-600 hover:text-gray-800 font-medium"
                >
                  Voir plus
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal détails -->
    <div v-if="showDetails && selectedComment" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div class="bg-white rounded-lg max-w-2xl w-full p-6">
        <div class="flex justify-between items-center mb-4">
          <h2 class="text-xl font-bold">Détails du commentaire</h2>
          <button @click="closeDetails" class="text-gray-400 hover:text-gray-600">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        <div class="space-y-4">
          <div>
            <h3 class="font-semibold text-gray-900 mb-2">{{ selectedComment.product.name }}</h3>
            <div class="bg-gray-50 rounded-lg p-4">
              <p class="text-gray-700 whitespace-pre-wrap">{{ selectedComment.comment }}</p>
            </div>
          </div>

          <div class="border-t pt-4">
            <div class="flex justify-between items-center">
              <span class="text-sm text-gray-500">Commentaire #{{ selectedComment.id }}</span>
              <span :class="['px-2 py-1 rounded-full text-xs font-medium', getStatusColor(selectedComment.isActive)]">
                {{ getStatusText(selectedComment.isActive) }}
              </span>
            </div>
            <p class="text-xs text-gray-500 mt-1">{{ formatDate(selectedComment.createdAt) }}</p>
            
            <div v-if="!selectedComment.isActive" class="mt-3 p-3 bg-yellow-50 border border-yellow-200 rounded-lg">
              <p class="text-sm text-yellow-800">
                <svg class="w-4 h-4 inline mr-1" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
                </svg>
                Ce commentaire est en attente de validation par un administrateur
              </p>
            </div>
          </div>
        </div>

        <div class="mt-6 flex gap-3">
          <a 
            :href="`/catalogue/product/${selectedComment.product.slug}`"
            class="flex-1 bg-blue-600 text-white text-center py-2 rounded-lg hover:bg-blue-700 transition-colors"
          >
            Voir le produit
          </a>
          <button
            @click="closeDetails"
            class="flex-1 bg-gray-200 text-gray-800 py-2 rounded-lg hover:bg-gray-300 transition-colors"
          >
            Fermer
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
