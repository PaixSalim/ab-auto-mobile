<template>
  <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4" @click.self="closeModal">
    <div class="bg-white rounded-xl shadow-2xl max-w-6xl w-full max-h-[90vh] overflow-y-auto">
      <!-- Header -->
      <div class="bg-gradient-to-r from-gray-800 to-gray-900 px-6 py-4 rounded-t-xl border-b">
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-3">
            <div class="w-8 h-8 bg-primary rounded-lg flex items-center justify-center">
              <div class="i-mdi-package text-white text-lg"></div>
            </div>
            <div>
              <h1 class="text-2xl font-bold text-white">Détails du Produit #{{ product.id }}</h1>
              <p class="text-gray-400 text-sm mt-1">{{ product.name }}</p>
            </div>
          </div>
          <button 
            type="button"
            @click="closeModal" 
            class="text-gray-400 hover:text-white transition-colors p-2 rounded-lg hover:bg-gray-800 cursor-pointer"
          >
            <div class="i-mdi-close text-xl"></div>
          </button>
        </div>
      </div>

      <!-- Main Content -->
      <div class="p-6">
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <!-- Colonne gauche : Images/Vidéo -->
          <div>
            <!-- Product Images/Video Carousel -->
            <div class="bg-gray-800 rounded-xl overflow-hidden shadow-xl">
              <div
                class="relative"
                @mouseenter="stopAutoPlay"
                @mouseleave="startAutoPlay"
              >
                <div
                  class="flex transition-transform duration-500 ease-in-out"
                  :style="{ transform: `translateX(-${currentSlide * 100}%)` }"
                >
                  <div v-for="(media, index) in product.medias" :key="index" class="w-full flex-shrink-0">
                    <!-- Video -->
                    <div v-if="media.type === 'video'" class="aspect-video w-full bg-black">
                      <iframe
                        :src="getYouTubeEmbedUrl(media.url)"
                        class="w-full h-full"
                        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                        allowfullscreen
                      ></iframe>
                      <div class="absolute bottom-2 left-2 bg-black bg-opacity-75 text-white px-2 py-1 rounded text-xs">
                        <div class="i-mdi-play mr-1"></div>
                        Vidéo YouTube
                      </div>
                    </div>
                    <!-- Image -->
                    <div v-else class="relative group">
                      <img
                        :src="media.url"
                        :alt="`${product.name} - Vue ${index + 1}`"
                        class="w-full aspect-video object-cover"
                      />
                      <div class="absolute inset-0 bg-black bg-opacity-0 group-hover:bg-opacity-30 transition-all duration-300 flex items-center justify-center">
                        <div class="i-mdi-magnify text-white text-2xl"></div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Thumbnail Navigation -->
              <div class="flex gap-2 mt-4 overflow-x-auto px-4">
                <button
                  v-for="(media, index) in product.medias"
                  :key="index"
                  @click="goToSlide(index)"
                  class="w-16 h-16 rounded-lg overflow-hidden border-2 flex-shrink-0 transition-all duration-200"
                  :class="currentSlide === index ? 'border-primary bg-primary/20' : 'border-gray-600 hover:border-gray-400'"
                >
                  <img
                    v-if="media.type === 'image'"
                    :src="media.url"
                    :alt="`Thumbnail ${index + 1}`"
                    class="w-full h-full object-cover"
                  />
                  <div v-else class="w-full h-full bg-gray-700 flex items-center justify-center">
                    <div class="i-mdi-play text-white text-xl"></div>
                  </div>
                </button>
              </div>
            </div>
          </div>

          <!-- Colonne droite : Informations du produit -->
          <div class="space-y-4">
            <!-- Informations principales -->
            <div class="bg-gray-50 rounded-xl p-6 shadow-lg">
              <h2 class="text-xl font-bold text-gray-800 mb-4 flex items-center gap-2">
                <div class="w-6 h-6 bg-primary rounded-full flex items-center justify-center">
                  <div class="i-mdi-information text-white text-sm"></div>
                </div>
                Informations du Produit
              </h2>
              
              <div class="space-y-4">
                <!-- Nom et statut -->
                <div>
                  <h3 class="text-lg font-semibold text-gray-800">{{ product.name }}</h3>
                  <div class="flex items-center gap-2 mt-1">
                    <span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium" :class="getStatusColor(product.validationStatus || 'pending')">
                      <div class="i-mdi-check-circle w-3 h-3 mr-1"></div>
                      {{ getStatusText(product.validationStatus || 'pending') }}
                    </span>
                  </div>
                </div>

                <!-- Prix et remise -->
                <div class="flex items-center justify-between">
                  <div>
                    <p class="text-sm text-gray-600 mb-1">Prix de vente</p>
                    <div class="flex items-center gap-3">
                      <span class="text-2xl font-bold text-primary">{{ (product.price * (1 - product.discount / 100)).toFixed(2) }} Fcfa</span>
                      <span v-if="product.discount > 0" class="text-gray-400 line-through text-lg">{{ product.price }} Fcfa</span>
                    </div>
                  </div>
                  <div v-if="product.discount > 0" class="bg-red-600 text-white px-2 py-1 rounded-full text-sm font-medium">
                    -{{ product.discount }}%
                  </div>
                </div>

                <!-- Catégorie et marque -->
                <div class="grid grid-cols-2 gap-4">
                  <div>
                    <p class="text-sm text-gray-600 mb-1">Catégorie</p>
                    <p class="text-gray-800 font-medium">{{ product.category?.name || 'Non spécifiée' }}</p>
                  </div>
                  <div>
                    <p class="text-sm text-gray-600 mb-1">Marque</p>
                    <p class="text-gray-800 font-medium">{{ product.brand?.name || 'Non spécifiée' }}</p>
                  </div>
                </div>

                <!-- État et garantie -->
                <div class="grid grid-cols-2 gap-4">
                  <div>
                    <p class="text-sm text-gray-600 mb-1">État</p>
                    <p class="text-gray-800 font-medium">{{ product.state || 'Non spécifié' }}</p>
                  </div>
                  <div>
                    <p class="text-sm text-gray-600 mb-1">Garantie</p>
                    <p class="text-gray-800 font-medium">{{ product.warranty || 'Non spécifiée' }}</p>
                  </div>
                </div>

                <!-- CTA -->
                <div v-if="product.cta && product.cta !== 'NONE'">
                  <p class="text-sm text-gray-600 mb-1">Call to action</p>
                  <div class="bg-blue-600 text-white px-3 py-2 rounded-lg">
                    <p class="text-white font-medium">{{ product.cta }}</p>
                  </div>
                </div>
              </div>
            </div>

            <!-- Description et caractéristiques -->
            <div class="bg-gray-50 rounded-xl p-6 shadow-lg">
              <h2 class="text-xl font-bold text-gray-800 mb-4 flex items-center gap-2">
                <div class="w-6 h-6 bg-primary rounded-full flex items-center justify-center">
                  <div class="i-mdi-text text-white text-sm"></div>
                </div>
                Description et Caractéristiques
              </h2>
              
              <div class="space-y-4">
                <!-- Description -->
                <div>
                  <p class="text-sm text-gray-600 mb-2">Description</p>
                  <div class="bg-gray-100 rounded-lg p-4">
                    <p class="text-gray-700 leading-relaxed">{{ product.description || 'Aucune description disponible' }}</p>
                  </div>
                </div>

                <!-- Caractéristiques -->
                <div>
                  <p class="text-sm text-gray-600 mb-2">Caractéristiques</p>
                  <div v-if="product.features && product.features.length > 0" class="bg-gray-100 rounded-lg p-4">
                    <ul class="space-y-2">
                      <li v-for="(feature, index) in product.features" :key="index" class="flex items-start gap-2">
                        <div class="w-5 h-5 bg-primary rounded-full flex items-center justify-center flex-shrink-0 mt-0.5">
                          <div class="i-mdi-check text-white text-xs"></div>
                        </div>
                        <span class="text-gray-700">{{ feature }}</span>
                      </li>
                    </ul>
                  </div>
                  <div v-else class="bg-gray-100 rounded-lg p-4 text-center text-gray-500">
                    <p>Aucune caractéristique spécifiée</p>
                  </div>
                </div>
              </div>
            </div>

            <!-- Informations du vendeur -->
            <div v-if="product.seller" class="bg-gray-50 rounded-xl p-6 shadow-lg">
              <h2 class="text-xl font-bold text-gray-800 mb-4 flex items-center gap-2">
                <div class="w-6 h-6 bg-green-600 rounded-full flex items-center justify-center">
                  <div class="i-mdi-account text-white text-sm"></div>
                </div>
                Informations du Vendeur
              </h2>
              
              <div class="space-y-4">
                <!-- En-tête vendeur -->
                <div class="flex items-start gap-4">
                  <div class="w-16 h-16 bg-gradient-to-br from-green-600 to-green-700 rounded-full flex items-center justify-center text-white font-bold text-xl shadow-lg">
                    {{ product.seller.fullName?.charAt(0).toUpperCase() || 'V' }}
                  </div>
                  <div class="flex-1">
                    <h3 class="font-semibold text-gray-800 text-xl">{{ product.seller.fullName || 'Vendeur' }}</h3>
                    <div class="flex items-center gap-2 mt-1">
                      <span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800">
                        <div class="i-mdi-check-circle w-3 h-3 mr-1"></div>
                        Vendeur vérifié
                      </span>
                    </div>
                    <p class="text-gray-500 text-sm mt-2">Vendeur professionnel</p>
                  </div>
                </div>

                <!-- Coordonnées -->
                <div class="grid grid-cols-1 gap-4">
                  <div class="flex items-center gap-3 p-4 bg-gray-100 rounded-lg border border-gray-200">
                    <div class="i-mdi-phone w-6 h-6 text-green-600"></div>
                    <div>
                      <p class="text-sm text-gray-600 mb-1">Téléphone</p>
                      <p class="text-gray-800 font-semibold">{{ product.seller.phone || 'Non disponible' }}</p>
                    </div>
                  </div>
                  
                  <div class="flex items-center gap-3 p-4 bg-gray-100 rounded-lg border border-gray-200">
                    <div class="i-mdi-email w-6 h-6 text-green-600"></div>
                    <div>
                      <p class="text-sm text-gray-600 mb-1">Email</p>
                      <p class="text-gray-800 font-semibold text-sm">{{ product.seller.email }}</p>
                    </div>
                  </div>

                  <div class="flex items-center gap-3 p-4 bg-gray-100 rounded-lg border border-gray-200">
                    <div class="i-mdi-map-marker w-6 h-6 text-green-600"></div>
                    <div>
                      <p class="text-sm text-gray-600 mb-1">Ville</p>
                      <p class="text-gray-800 font-semibold">{{ product.seller.city || 'Non spécifiée' }}</p>
                    </div>
                  </div>
                </div>

                <!-- Actions de contact -->
                <!-- <div class="flex gap-3">
                  <button class="flex-1 bg-green-600 hover:bg-green-700 text-white rounded-lg transition-colors">
                    <div class="i-mdi-phone w-5 h-5"></div>
                    Contacter
                  </button>
                  <button class="flex-1 bg-gray-200 hover:bg-gray-300 text-gray-800 rounded-lg transition-colors">
                    <div class="i-mdi-message w-5 h-5"></div>
                    Message
                  </button>
                </div> -->

                <!-- Badge de confiance -->
                <!-- <div class="bg-green-50 border border-green-200 rounded-lg p-4">
                  <div class="flex items-center gap-3">
                    <div class="i-mdi-shield-check w-8 h-8 text-green-600"></div>
                    <div>
                      <h4 class="font-semibold text-green-800 mb-1">Vendeur de confiance</h4>
                      <p class="text-sm text-green-700">
                        Ce vendeur a été vérifié par notre équipe et bénéficie d'un excellent taux de satisfaction.
                      </p>
                    </div>
                  </div>
                </div>  -->
              </div>
            </div>

            <!-- Raison de rejet si existante -->
            <div v-if="product.rejectionReason" class="bg-red-50 border border-red-200 rounded-xl p-6 shadow-lg">
              <h2 class="text-xl font-bold text-red-800 mb-4 flex items-center gap-2">
                <div class="w-6 h-6 bg-red-600 rounded-full flex items-center justify-center">
                  <div class="i-mdi-alert text-white text-sm"></div>
                </div>
                Raison du Rejet
              </h2>
              <div class="bg-red-100 rounded-lg p-4">
                <p class="text-red-800 mb-2">Ce produit a été rejeté pour la raison suivante :</p>
                <p class="text-red-700 font-medium bg-white rounded p-3">{{ product.rejectionReason }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

</template>

<script setup lang="ts">
import { ref } from 'vue'
import { GetProductDto } from '#dto/products_interface'
import { getYouTubeEmbedUrl } from '~/composables/get_youtube_embed'

// Types pour le vendeur
interface Seller {
  id: number
  fullName: string | null
  email: string
  phone: string | null
  city?: string | null | undefined
  isValidated?: boolean
}

const props = defineProps<{
  product: GetProductDto
}>()

const emit = defineEmits(['close'])

const currentSlide = ref(0)
const autoPlayInterval = ref<number | null>(null)

const closeModal = () => {
  emit('close')
}

// Fonctions utilitaires
const getStatusColor = (status: string) => {
  switch (status) {
    case 'approved':
      return 'bg-green-100 text-green-800'
    case 'pending':
      return 'bg-yellow-100 text-yellow-800'
    case 'rejected':
      return 'bg-red-100 text-red-800'
    default:
      return 'bg-gray-100 text-gray-800'
  }
}

const getStatusText = (status: string) => {
  switch (status) {
    case 'approved':
      return 'Approuvé'
    case 'pending':
      return 'En attente de validation'
    case 'rejected':
      return 'Rejeté'
    default:
      return status
  }
}

const goToSlide = (index: number) => {
  currentSlide.value = index
  resetAutoPlay()
}

const startAutoPlay = () => {
  if (!autoPlayInterval.value) {
    autoPlayInterval.value = setInterval(() => {
      currentSlide.value = (currentSlide.value + 1) % props.product.medias.length
    }, 3000)
  }
}

const stopAutoPlay = () => {
  if (autoPlayInterval.value) {
    clearInterval(autoPlayInterval.value)
    autoPlayInterval.value = null
  }
}

const resetAutoPlay = () => {
  stopAutoPlay()
  startAutoPlay()
}
</script>

<style scoped>
::-webkit-scrollbar {
  display: none;
}

@media (min-width: 768px) {
  .max-w-7xl {
    max-width: 80rem;
  }
}
</style>
