<template>
  <Layout>
    <Notification />
    <div class="p-6">
      <!-- Header -->
      <div class="mb-6">
        <h1 class="text-2xl font-bold text-gray-900 mb-2">Gestion des Promotions</h1>
        <p class="text-gray-600">Créez et gérez les promotions sur les produits</p>
      </div>

      <!-- Actions -->
      <div class="flex justify-between items-center mb-6">
        <div class="flex gap-3">
          <button
            @click="showCreateModal = true"
            class="bg-primary hover:bg-primary-hover text-white px-4 py-2 rounded-lg transition-colors flex items-center gap-2"
          >
            <div class="i-mdi-plus w-5 h-5"></div>
            Nouvelle Promotion
          </button>
        </div>
        
        <!-- Stats -->
        <div class="flex gap-6 text-sm">
          <div class="bg-blue-50 text-blue-700 px-3 py-1 rounded-full">
            Total: {{ promos.length }}
          </div>
          <div class="bg-green-50 text-green-700 px-3 py-1 rounded-full">
            Actives: {{ activePromos }}
          </div>
        </div>
      </div>

      <!-- Légende des actions -->
      <div class="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6">
        <h4 class="text-sm font-semibold text-blue-900 mb-2">Actions disponibles</h4>
        <div class="flex flex-wrap gap-4 text-xs text-blue-700">
          <div class="flex items-center gap-1">
            <div class="i-mdi-pencil w-4 h-4"></div>
            <span>Modifier la promotion</span>
          </div>
          <div class="flex items-center gap-1">
            <div class="i-mdi-play w-4 h-4"></div>
            <span>Activer la promotion</span>
          </div>
          <div class="flex items-center gap-1">
            <div class="i-mdi-pause w-4 h-4"></div>
            <span>Désactiver la promotion</span>
          </div>
          <div class="flex items-center gap-1">
            <div class="i-mdi-delete w-4 h-4"></div>
            <span>Supprimer la promotion</span>
          </div>
        </div>
      </div>

      <!-- Table des promotions -->
      <div class="bg-white rounded-lg shadow-sm overflow-hidden">
        <div class="overflow-x-auto">
          <table class="w-full">
            <thead class="bg-gray-50 border-b">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Image</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Produit</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Réduction</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Date début</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Date fin</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Statut</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <tr v-for="promo in promos" :key="promo.id" class="hover:bg-gray-50 transition-colors">
                <td class="px-6 py-4">
                  <img 
                    :src="getPromotionImageUrl(promo)" 
                    :alt="promo.promoLabel || 'Promotion'" 
                    class="w-16 h-16 rounded-lg object-cover border border-gray-200"
                    @error="handleImageError"
                  />
                </td>
                <td class="px-6 py-4">
                  <div class="flex items-center gap-3">
                    <img v-if="promo.product?.medias?.[0]" 
                         :src="promo.product.medias[0].url" 
                         :alt="promo.product.name" 
                         class="w-12 h-12 rounded-lg object-cover">
                    <div>
                      <p class="font-medium text-gray-900">{{ promo.product?.name }}</p>
                      <p class="text-sm text-gray-500">ID: {{ promo.product?.id }}</p>
                    </div>
                  </div>
                </td>
                <td class="px-6 py-4">
                  <span class="bg-red-100 text-red-800 px-2 py-1 rounded-full text-sm font-medium">
                    -{{ promo.discountPercent }}%
                  </span>
                </td>
                <td class="px-6 py-4 text-sm text-gray-900">
                  {{ formatDate(promo.promoStartDate) }}
                </td>
                <td class="px-6 py-4 text-sm text-gray-900">
                  {{ formatDate(promo.promoEndDate) }}
                </td>
                <td class="px-6 py-4">
                  <span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium"
                        :class="isPromotionActive(promo) 
                          ? 'bg-green-100 text-green-800' 
                          : 'bg-gray-100 text-gray-800'">
                    {{ isPromotionActive(promo) ? 'Active' : 'Inactive' }}
                  </span>
                </td>
                <td class="px-6 py-4">
                  <div class="flex gap-2">
                    <button
                      @click="editPromotion(promo)"
                      class="text-blue-600 hover:text-blue-800 transition-colors"
                      title="Modifier"
                    >
                      <div class="i-mdi-pencil w-4 h-4"></div>
                    </button>
                    <button
                      @click="togglePromotionStatus(promo)"
                      :class="[
                        'transition-colors',
                        isPromotionActive(promo) 
                          ? 'text-orange-600 hover:text-orange-800' 
                          : 'text-green-600 hover:text-green-800'
                      ]"
                      :title="isPromotionActive(promo) ? 'Désactiver' : 'Activer'"
                    >
                      <div :class="[
                        'w-4 h-4',
                        isPromotionActive(promo) ? 'i-mdi-pause' : 'i-mdi-play'
                      ]"></div>
                    </button>
                    <button
                      @click="deletePromotion(promo)"
                      class="text-red-600 hover:text-red-800 transition-colors"
                      title="Supprimer"
                    >
                      <div class="i-mdi-delete w-4 h-4"></div>
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Empty State -->
      <div v-if="promos.length === 0" class="text-center py-12">
        <div class="i-mdi-tag-outline text-6xl text-gray-400 mb-4"></div>
        <h3 class="text-lg font-medium text-gray-900 mb-2">Aucune promotion</h3>
        <p class="text-gray-600">Commencez par créer votre première promotion</p>
        <button
          @click="showCreateModal = true"
          class="bg-primary hover:bg-primary-hover text-white px-6 py-3 rounded-lg transition-colors mt-4"
        >
          Créer une promotion
        </button>
      </div>
    </div>

    <!-- Modal de création -->
    <PromotionModal
      v-if="showCreateModal"
      v-model="showCreateModal"
      @promotion-created="handlePromotionCreated"
    />

    <!-- Modal d'édition -->
    <PromotionModal
      v-if="editingPromo"
      v-model="showEditModal"
      :promotion="editingPromo"
      @promotion-updated="handlePromotionUpdated"
    />
  </Layout>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import Layout from '~/components/admin/Layout.vue'
import Notification from '../../../components/Notification.vue'
import { router } from '@inertiajs/vue3'

const props = defineProps<{
  promos: any[]
}>()  

const showCreateModal = ref(false)
const showEditModal = ref(false)
const editingPromo = ref<any>(null)

const activePromos = computed(() => {
  return props.promos.filter(promo => isPromotionActive(promo)).length
})

const isPromotionActive = (promo: any) => {
  const now = new Date()
  const startDate = promo.promoStartDate ? new Date(promo.promoStartDate) : new Date(0)
  const endDate = promo.promoEndDate ? new Date(promo.promoEndDate) : new Date(0)
  return now >= startDate && now <= endDate
}

const formatDate = (date: any) => {
  if (!date) return '—'
  return new Date(date).toLocaleDateString('fr-FR', { day: '2-digit', month: '2-digit', year: 'numeric' })
}

const editPromotion = (promo: any) => {
  editingPromo.value = promo
  showEditModal.value = true
}

const togglePromotionStatus = async (promo: any) => {
  const isActive = isPromotionActive(promo)
  const action = isActive ? 'désactiver' : 'activer'
  
  if (confirm(`Êtes-vous sûr de vouloir ${action} cette promotion ?`)) {
    try {
      const now = new Date()
      let newStartDate: string
      let newEndDate: string
      
      if (isActive) {
        newEndDate = new Date(now.getTime() - 24 * 60 * 60 * 1000).toISOString().substring(0, 10)
        newStartDate = promo.promoStartDate ? new Date(promo.promoStartDate).toISOString().substring(0, 10) : now.toISOString().substring(0, 10)
      } else {
        newStartDate = now.toISOString().substring(0, 10)
        newEndDate = new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000).toISOString().substring(0, 10)
      }
      
      const response = await fetch(`/dashboard/promotions/edit/${promo.id}`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || ''
        },
        body: JSON.stringify({
          id: promo.id,
          productId: promo.productId,
          promoLabel: promo.promoLabel,
          discountPercent: promo.discountPercent,
          promoStartDate: newStartDate,
          promoEndDate: newEndDate
        })
      })
      
      if (!response.ok) {
        throw new Error(`Erreur lors de l'${action} de la promotion`)
      }
      
      // Afficher la notification de succès
      window.dispatchEvent(new CustomEvent('toast:show', {
        detail: {
          type: 'success',
          title: `Promotion ${action}e`,
          message: `La promotion a été ${action}e avec succès`
        }
      }))
      
      // Rafraîchir la page
      window.location.reload()
    } catch (error) {
      // Afficher la notification d'erreur
      window.dispatchEvent(new CustomEvent('toast:show', {
        detail: {
          type: 'error',
          title: 'Erreur',
          message: `Une erreur est survenue lors de l'${action} de la promotion`
        }
      }))
    }
  }
}

const deletePromotion = async (promo: any) => {
  if (confirm(`Êtes-vous sûr de vouloir supprimer cette promotion ?`)) {
    try {
      const response = await fetch(`/dashboard/promotions/delete/${promo.id}`, {
        method: 'DELETE',
        headers: {
          'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || ''
        }
      })
      
      if (!response.ok) {
        throw new Error('Erreur lors de la suppression')
      }
      
      // Afficher la notification de succès
      window.dispatchEvent(new CustomEvent('toast:show', {
        detail: {
          type: 'success',
          title: 'Promotion supprimée',
          message: 'La promotion a été supprimée avec succès'
        }
      }))
      
      // Rafraîchir la page
      window.location.reload()
    } catch (error) {
      // Afficher la notification d'erreur
      window.dispatchEvent(new CustomEvent('toast:show', {
        detail: {
          type: 'error',
          title: 'Erreur',
          message: 'Une erreur est survenue lors de la suppression de la promotion'
        }
      }))
    }
  }
}

const handlePromotionCreated = () => {
  showCreateModal.value = false
  router.reload()
}

const handlePromotionUpdated = () => {
  showEditModal.value = false
  editingPromo.value = null
  router.reload()
}

const getPromotionImageUrl = (promo: any) => {
  // Si l'URL de la promotion existe, l'utiliser
  if (promo.url) {
    // Pour les fichiers locaux, s'assurer que l'URL est correcte
    if (promo.url.startsWith('/uploads/')) {
      return promo.url
    }
    // Pour les URLs externes (R2 ou autres)
    return promo.url
  }
  // Sinon, utiliser une image par défaut LOCALE
  return '/uploads/products/default-product.jpg'
}

const handleImageError = (event: Event) => {
  const img = event.target as HTMLImageElement
  // Fallback vers une image par défaut LOCALE en cas d'erreur
  img.src = '/uploads/products/default-product.jpg'
}

// Polling désactivé pour éviter des rechargements excessifs
// usePoll(1000)
</script>
