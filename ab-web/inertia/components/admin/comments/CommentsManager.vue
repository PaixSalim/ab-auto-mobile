<template>
  <div class="p-6">
    <div class="flex justify-between items-center mb-6">
      <h1 class="text-2xl font-bold text-black">Gestion des Commentaires</h1>
      <div class="flex gap-2">
        <button
          @click="refreshComments"
          class="flex items-center gap-2 px-4 py-2 bg-primary rounded-lg  hover:bg-background-secondary transition-colors"
        >
          <div class="i-mdi-refresh text-lg"></div>
          Actualiser
        </button>
      </div>
    </div>

    <!-- Filtres -->
    <div class="bg-background-admin p-4 rounded-lg shadow mb-6">
      <div class="flex flex-wrap gap-4">
        <div class="flex-1 min-w-[200px]">
          <label class="block text-sm font-medium  dark:text-gray-300 mb-1">Recherche</label>
          <div class="relative">
            <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <div class="i-mdi-magnify text-gray-400"></div>
            </div>
            <input
              v-model="filters.search"
              type="text"
              placeholder="Rechercher par utilisateur ou contenu..."
              class="w-full pl-10 pr-3 py-2 rounded-md shadow-sm focus:outline-none focus:ring-primary focus:border-primary bg-background-secondary "
            />
          </div>
        </div>
        <div class="w-[200px]">
          <label class="block text-sm font-medium  dark:text-gray-300 mb-1">Statut</label>
          <select
            v-model="filters.status"
            class="w-full px-3 py-2 rounded-md shadow-sm focus:outline-none focus:ring-primary focus:border-primary bg-background-secondary text-white"
          >
            <option value="all">Tous</option>
            <option value="active">Actifs</option>
            <option value="inactive">Inactifs</option>
          </select>
        </div>
        <div class="w-[200px]">
          <label class="block text-sm font-medium   mb-1">Produit</label>
          <select
            v-model="filters.productId"
            class="w-full px-3 py-2 bg-background-secondary rounded-md shadow-sm focus:outline-none focus:ring-primary focus:border-primary  text-white"
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
    <div class="bg-background-secondary rounded-lg shadow overflow-hidden">
      <!-- État de chargement -->
      <div v-if="loading" class="p-8">
        <div class="flex justify-center">
          <div class="i-mdi-loading animate-spin text-4xl text-primary"></div>
        </div>
        <p class="text-center mt-4 text-gray-500 dark:text-gray-400">Chargement des commentaires...</p>
      </div>

      <!-- Message si aucun commentaire -->
      <div v-else-if="filteredComments.length === 0" class="p-8 text-center">
        <div class="i-mdi-comment-off text-6xl mx-auto mb-4  text-gray-600"></div>
        <h3 class="text-xl font-medium text-gray-300 mb-2">Aucun commentaire trouvé</h3>
        <p class="text-gray-400">
          {{ hasFilters ? 'Essayez de modifier vos filtres pour voir plus de résultats.' : 'Aucun commentaire n\'a été ajouté pour le moment.' }}
        </p>
      </div>

      <!-- Tableau des commentaires -->
      <table v-else class="min-w-full divide-y divide-gray-700">
        <thead class="bg-background-secondary">
        <tr>
          <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">
            Utilisateur
          </th>
          <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">
            Commentaire
          </th>
          <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">
            Produit
          </th>
          <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">
            Statut
          </th>
          <th scope="col" class="px-6 py-3 text-right text-xs font-medium text-gray-300 uppercase tracking-wider">
            Actions
          </th>
        </tr>
        </thead>
        <tbody class="bg-background-admin divide-y divide-gray-700">
        <tr v-for="comment in filteredComments" :key="comment.id" class="hover:bg-background-secondary">
          <td class="px-6 py-4 whitespace-nowrap">
            <div class="flex items-center">
              <div class="flex-shrink-0 h-10 w-10 bg-gray-600 rounded-full flex items-center justify-center">
                <div class="i-mdi-account text-xl text-gray-400"></div>
              </div>
              <div class="ml-4">
                <div class="text-sm font-medium ">{{ comment.user }}</div>
                <div class="text-sm text-gray-400">IP: {{ comment.ip }}</div>
              </div>
            </div>
          </td>
          <td class="px-6 py-4">
            <div class="text-sm text-white line-clamp-2">{{ comment.comment }}</div>
          </td>
          <td class="px-6 py-4 whitespace-nowrap">
            <div class="text-sm ">
              {{ getProductName(comment.productId) }}
            </div>
          </td>
          <td class="px-6 py-4 whitespace-nowrap">
              <span
                class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full"
                :class="comment.isActive
                  ? 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200'
                  : 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200'"
              >
                {{ comment.isActive ? 'Actif' : 'Inactif' }}
              </span>
          </td>
          <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
            <div class="flex justify-end space-x-2">
              <button
                @click="viewComment(comment)"
                class="text-gray-400 hover:text-white"
                title="Voir les détails"
              >
                <div class="i-mdi-eye text-xl"></div>
              </button>
              <button
                @click="editComment(comment)"
                class="text-blue-400 hover:text-blue-300"
                title="Modifier"
              >
                <div class="i-mdi-pencil text-xl"></div>
              </button>
              <button
                @click="toggleCommentStatus(comment)"
                :class="comment.isActive
                    ? 'text-orange-400 hover:text-orange-300'
                    : 'text-green-400 hover:text-green-300'"
                :title="comment.isActive ? 'Désactiver' : 'Activer'"
              >
                <div :class="comment.isActive ? 'i-mdi-cancel text-xl' : 'i-mdi-check-circle text-xl'"></div>
              </button>
              <button
                @click="confirmDelete(comment)"
                class="text-red-400 hover:text-red-300"
                title="Supprimer"
              >
                <div class="i-mdi-delete text-xl"></div>
              </button>
            </div>
          </td>
        </tr>
        </tbody>
      </table>

      <!-- Pagination -->
      <div v-if="!loading && filteredComments.length > 0" class="bg-background-admin px-4 py-3 flex items-center justify-between border-t border-gray-700 sm:px-6">
        <div class="hidden sm:flex-1 sm:flex sm:items-center sm:justify-between">
          <div>
            <p class="text-sm text-gray-300">
              Affichage de <span class="font-medium">{{ paginationStart }}</span> à <span class="font-medium">{{ paginationEnd }}</span> sur <span class="font-medium">{{ totalComments }}</span> commentaires
            </p>
          </div>
          <div>
            <nav class="relative z-0 inline-flex rounded-md shadow-sm -space-x-px" aria-label="Pagination">
              <button
                @click="currentPage > 1 && (currentPage--)"
                :disabled="currentPage === 1"
                class="relative inline-flex items-center px-2 py-2 rounded-l-md border border-gray-600 bg-gray-700 text-sm font-medium text-gray-300 hover:bg-gray-600 disabled:opacity-50"
              >
                <span class="sr-only">Précédent</span>
                <div class="i-mdi-chevron-left text-xl"></div>
              </button>

              <template v-for="page in totalPages" :key="page">
                <button
                  v-if="shouldShowPage(page)"
                  @click="currentPage = page"
                  :class="[
                    'relative inline-flex items-center px-4 py-2 border text-sm font-medium',
                    currentPage === page
                      ? 'z-10 bg-primary border-primary text-white'
                      : 'bg-gray-700 border-gray-600 text-gray-300 hover:bg-gray-600'
                  ]"
                >
                  {{ page }}
                </button>
                <span
                  v-else-if="page === ellipsis.left || page === ellipsis.right"
                  class="relative inline-flex items-center px-4 py-2 border  text-gray-300"
                >
                  ...
                </span>
              </template>

              <button
                @click="currentPage < totalPages && (currentPage++)"
                :disabled="currentPage === totalPages"
                class="relative inline-flex items-center px-2 py-2 rounded-r-md border border-gray-600 bg-gray-700 text-sm font-medium text-gray-300 hover:bg-gray-600 disabled:opacity-50"
              >
                <span class="sr-only">Suivant</span>
                <div class="i-mdi-chevron-right text-xl"></div>
              </button>
            </nav>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de visualisation -->
    <div v-if="viewModal.show" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-background-admin rounded-lg shadow-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
        <div class="p-6">
          <div class="flex justify-between items-center mb-4">
            <h2 class="text-xl font-bold">Détails du commentaire</h2>
            <button @click="viewModal.show = false" class="text-gray-500 hover:text-gray-200">
              <div class="i-mdi-close text-xl"></div>
            </button>
          </div>

          <div class="space-y-4">
            <div>
              <h3 class="text-sm font-medium text-gray-400">Utilisateur</h3>
              <p class="mt-1 text-sm text-white">{{ viewModal.comment?.user }}</p>
            </div>

            <div>
              <h3 class="text-sm font-medium text-gray-400">Adresse IP</h3>
              <p class="mt-1 text-sm text-white">{{ viewModal.comment?.ip }}</p>
            </div>

            <div>
              <h3 class="text-sm font-medium text-gray-400">Produit</h3>
              <p class="mt-1 text-sm text-white">{{ getProductName(viewModal.comment?.productId) }}</p>
            </div>

            <div>
              <h3 class="text-sm font-medium text-gray-400">Statut</h3>
              <p class="mt-1">
                <span
                  class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full"
                  :class="viewModal.comment?.isActive
                    ? 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200'
                    : 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200'"
                >
                  {{ viewModal.comment?.isActive ? 'Actif' : 'Inactif' }}
                </span>
              </p>
            </div>

            <div>
              <h3 class="text-sm font-medium text-gray-400">Commentaire</h3>
              <div class="mt-1 p-4 bg-background-secondary rounded-md">
                <p class="text-sm text-white whitespace-pre-wrap">{{ viewModal.comment?.comment }}</p>
              </div>
            </div>
          </div>

          <div class="mt-6 flex justify-end space-x-3">
            <button
              @click="viewModal.show = false"
              class="px-4 py-2 bg-primary text-white rounded-md hover:bg-gray-300 dark:hover:bg-gray-600 focus:outline-none"
            >
              Fermer
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal d'édition -->
    <div v-if="editModal.show" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-background-admin rounded-lg shadow-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
        <div class="p-6">
          <div class="flex justify-between items-center mb-4">
            <h2 class="text-xl font-bold">Modifier le commentaire</h2>
            <button @click="editModal.show = false" class="text-gray-00 hover:text-gray-200">
              <div class="i-mdi-close text-xl"></div>
            </button>
          </div>

          <form @submit.prevent="saveComment">
            <div class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-300">Utilisateur</label>
                <input
                  v-model="editModal.comment.user"
                  type="text"
                  class="mt-1 block w-full px-3 py-2 border  bg-background-secondary border-gray-600 rounded-md shadow-sm focus:outline-none focus:ring-primary focus:border-primary"
                  required
                />
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-300">Produit</label>
                <input
                  :value="getProductName(editModal.comment.productId)"
                  class="mt-1 block w-full px-3 py-2 border border-gray-600 bg-background-secondary rounded-md shadow-sm focus:outline-none focus:ring-primary focus:border-primary "
                  disabled
                />
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-300">Statut</label>
                <div class="mt-1 flex items-center space-x-4">
                  <label class="inline-flex items-center">
                    <input
                      v-model="editModal.comment.isActive"
                      type="radio"
                      :value="true"
                      class="form-radio h-4 w-4 text-primary"
                    />
                    <span class="ml-2 text-sm text-gray-300">Actif</span>
                  </label>
                  <label class="inline-flex items-center">
                    <input
                      v-model="editModal.comment.isActive"
                      type="radio"
                      :value="false"
                      class="form-radio h-4 w-4 text-primary"
                    />
                    <span class="ml-2 text-sm text-gray-300">Inactif</span>
                  </label>
                </div>
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-300">Commentaire</label>
                <textarea
                  v-model="editModal.comment.comment"
                  rows="4"
                  class="mt-1 block w-full px-3 py-2 bg-background-secondary border border-gray-500 rounded-md shadow-sm focus:outline-none focus:ring-primary focus:border-primary "
                  required
                ></textarea>
              </div>
            </div>

            <div class="mt-6 flex justify-end space-x-3">
              <button
                type="button"
                @click="editModal.show = false"
                class="px-4 py-2 bg-gray-200 dark:bg-gray-700 text-gray-800 dark:text-white rounded-md hover:bg-gray-300 dark:hover:bg-gray-600 focus:outline-none"
              >
                Annuler
              </button>
              <button
                type="submit"
                class="px-4 py-2 bg-primary text-white rounded-md hover:bg-primary-dark focus:outline-none"
              >
                Enregistrer
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>

    <!-- Modal de confirmation de suppression -->
    <div v-if="deleteModal.show" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-background-secondary rounded-lg shadow-xl max-w-md w-full">
        <div class="p-6">
          <div class="flex items-center mb-4">
            <div class="flex-shrink-0 bg-red-100 dark:bg-red-900 rounded-full p-2">
              <div class="i-mdi-alert text-2xl text-red-600 dark:text-red-300"></div>
            </div>
            <h2 class="ml-3 text-xl font-bold ">Confirmer la suppression</h2>
          </div>

          <p class="text-sm text-gray-400">
            Êtes-vous sûr de vouloir supprimer ce commentaire ? Cette action est irréversible.
          </p>

          <div class="mt-6 flex justify-end space-x-3">
            <button
              @click="deleteModal.show = false"
              class="px-4 py-2 bg-gray-200 dark:bg-gray-700 text-gray-800 dark:text-white rounded-md hover:bg-gray-300 dark:hover:bg-gray-600 focus:outline-none"
            >
              Annuler
            </button>
            <button
              @click="deleteComment"
              class="px-4 py-2 bg-red-600 text-white rounded-md hover:bg-red-700 focus:outline-none"
            >
              Supprimer
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Notification toast -->
    <div
      v-if="notification.show"
      class="fixed bottom-4 right-4 px-4 py-3 rounded-lg shadow-lg z-50 flex items-center"
      :class="[
        notification.type === 'success' ? 'bg-green-500 text-white' : '',
        notification.type === 'error' ? 'bg-red-500 text-white' : '',
        notification.type === 'info' ? 'bg-blue-500 text-white' : '',
      ]"
    >
      <div
        :class="[
          notification.type === 'success' ? 'i-mdi-check-circle' : '',
          notification.type === 'error' ? 'i-mdi-alert-circle' : '',
          notification.type === 'info' ? 'i-mdi-information' : '',
          'text-xl mr-2'
        ]"
      ></div>
      <p>{{ notification.message }}</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import {CommentResponse} from '#dto/comments_interface'
import { usePage, router } from '@inertiajs/vue3'
import { ProductDto } from '#dto/products_interface'

const share = usePage()
// État - les données viennent déjà des props du serveur
const comments = ref<CommentResponse[]>(Array.isArray(share.props.comments) ? share.props.comments : [])
const products = ref<ProductDto[]>(Array.isArray(share.props.products) ? share.props.products : [])
const loading = ref(false) // Pas de chargement nécessaire, les données sont déjà là
const currentPage = ref(1)
const itemsPerPage = ref(10)

// Sync local state with props when they update (from polling or redirects)
watch(() => share.props.comments, (newComments) => {
  if (Array.isArray(newComments)) {
    comments.value = newComments
  }
}, { deep: true })

// Filtres
const filters = ref({
  search: '',
  status: 'all',
  productId: ''
})

// Modales
const viewModal = ref({
  show: false,
  comment: null as CommentRequest | null
})

const editModal = ref({
  show: false,
  comment: {} as CommentResponse
})

const deleteModal = ref({
  show: false,
  commentId: null as number | null
})

// Notification
const notification = ref({
  show: false,
  message: '',
  type: 'info' as 'success' | 'error' | 'info'
})

// Pagination
const ellipsis = {
  left: -1,
  right: -2
}

// Computed
const hasFilters = computed(() => {
  return filters.value.search !== '' ||
    filters.value.status !== 'all' ||
    filters.value.productId !== ''
})

const filteredComments = computed(() => {
  let result = [...comments.value]

  // Filtre par recherche
  if (filters.value.search) {
    const searchTerm = filters.value.search.toLowerCase()
    result = result.filter(comment =>
      comment.user.toLowerCase().includes(searchTerm) ||
      comment.comment.toLowerCase().includes(searchTerm)
    )
  }

  // Filtre par statut
  if (filters.value.status !== 'all') {
    const isActive = filters.value.status === 'active'
    result = result.filter(comment => comment.isActive === isActive)
  }

  // Filtre par produit
  if (filters.value.productId) {
    const productId = Number(filters.value.productId)
    result = result.filter(comment => comment.productId === productId)
  }

  return result
})

const paginatedComments = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return filteredComments.value.slice(start, end)
})

const totalComments = computed(() => filteredComments.value.length)

const totalPages = computed(() => Math.max(1, Math.ceil(totalComments.value / itemsPerPage.value)))

const paginationStart = computed(() => {
  if (totalComments.value === 0) return 0
  return (currentPage.value - 1) * itemsPerPage.value + 1
})

const paginationEnd = computed(() => {
  return Math.min(currentPage.value * itemsPerPage.value, totalComments.value)
})

// Méthodes
const fetchData = async () => {
  // Les données viennent déjà des props du serveur, pas besoin de chargement
  // Juste au cas où, on s'assure que loading est false
  loading.value = false
}

const refreshComments = () => {
  fetchData()
  showNotification('Commentaires actualisés', 'success')
}

const getProductName = (productId: number | undefined) => {
  if (!productId) return 'Produit inconnu'
  const product = products.value.find(p => p.id === productId)
  return product ? product.name : 'Produit inconnu'
}

const viewComment = (comment: CommentResponse) => {
  viewModal.value.comment = comment
  viewModal.value.show = true
}

const editComment = (comment: CommentResponse) => {
  editModal.value.comment = { ...comment }
  editModal.value.show = true
}

const saveComment = () => {
  try {
    const index = comments.value.findIndex(c => c.id === editModal.value.comment.id)
    if (index !== -1) {
      router.put(`/dashboard/comments/update/`, { id: editModal.value.comment.id, comment: editModal.value.comment.comment,
      user: editModal.value.comment.user, isActive: editModal.value.comment.isActive }, { preserveState: true , onSuccess: () => {
          comments.value[index] = { ...editModal.value.comment }
          showNotification('Commentaire modifié avec succès', 'success')
          editModal.value.show = false
        }, onError: () => {
          showNotification('Erreur lors de la modification du commentaire', 'error')}
      })
    }
  } catch (error) {

  }
}

const toggleCommentStatus = (comment: CommentRequest) => {
  try {
    router.post('/admin/comments/toggle-status', { commentId: comment.id, status: !comment.isActive }, {
      onSuccess: () => {
        showNotification(
          `Commentaire ${!comment.isActive ? 'activé' : 'désactivé'} avec succès`,
          'success'
        )
      },
      onError: () => {
        showNotification('Erreur lors du changement de statut du commentaire', 'error')
      }
    })
  } catch (error) {
    showNotification('Erreur lors du changement de statut du commentaire', 'error')
  }
}

const confirmDelete = (comment: CommentResponse) => {
  deleteModal.value.commentId = comment.id
  deleteModal.value.show = true
}

const deleteComment = () => {
  try {
    if (deleteModal.value.commentId) {
      router.delete(`/admin/comments/${deleteModal.value.commentId}`, {
        onSuccess: () => {
          showNotification('Commentaire supprimé avec succès', 'success')
          deleteModal.value.show = false
          deleteModal.value.commentId = null
        },
        onError: () => {
          showNotification('Erreur lors de la suppression du commentaire', 'error')
        }
      })
    }
  } catch (error) {
    showNotification('Erreur lors de la suppression du commentaire', 'error')
  }
}

const showNotification = (message: string, type: 'success' | 'error' | 'info' = 'info') => {
  notification.value = {
    show: true,
    message,
    type
  }

  setTimeout(() => {
    notification.value.show = false
  }, 3000)
}

const shouldShowPage = (page: number) => {
  // Toujours afficher la première et la dernière page
  if (page === 1 || page === totalPages.value) return true

  // Afficher les pages autour de la page courante
  if (Math.abs(page - currentPage.value) <= 1) return true

  // Afficher les ellipsis
  if (page === ellipsis.left && currentPage.value > 3) return true
  if (page === ellipsis.right && currentPage.value < totalPages.value - 2) return true

  return false
}

// Surveiller les changements de filtres pour réinitialiser la pagination
watch([() => filters.value.search, () => filters.value.status, () => filters.value.productId], () => {
  currentPage.value = 1
})

// Initialisation
onMounted(fetchData)
</script>

<style scoped>
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.animate-spin {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}
</style>
