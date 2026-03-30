<template>
  <div class="min-h-screen">
    <div class="container mx-auto py-6">
      <!-- Fil d'Ariane -->
      <nav class="flex items-center space-x-2 text-sm px-4 py-3 bg-white rounded-lg shadow-sm mb-6">
        <router-link 
          to="/" 
         @click="router.get('/')"  class="text-gray-500 hover:text-primary transition-colors duration-200 flex items-center"
        >
          <svg class="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
            <path d="M10.707 2.293a1 1 0 00-1.414 0l-7 7a1 1 0 001.414 1.414L4 8.414V17a1 1 0 102 0V8.414l.293.293a1 1 0 00-1.414-1.414l-7 7z"/>
          </svg>
          
          Accueil
        </router-link>
        
        <svg class="w-4 h-4 text-gray-400" fill="currentColor" viewBox="0 0 20 20">
          <path fill-rule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clip-rule="evenodd"/>
        </svg>
        
        <span class="text-gray-600 font-medium" @click="router.get('/catalogue')">{{ product.category?.name || 'Catégorie' }}</span>
        
        <svg class="w-4 h-4 text-gray-400" fill="currentColor" viewBox="0 0 20 20">
          <path fill-rule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clip-rule="evenodd"/>
        </svg>
        
        <router-link 
          to="/catalogue" 
          class="text-gray-500 hover:text-primary transition-colors duration-200 flex items-center"
        >
          <svg class="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
            <path d="M7 3a1 1 0 000 2h6a1 1 0 100-2H7zM4 7a1 1 0 011-1h10a1 1 0 110 2H5a1 1 0 01-1-1zM2 11a2 2 0 012-2h12a2 2 0 012 2v4a2 2 0 01-2 2H4a2 2 0 01-2-2v-4z"/>
          </svg>
          Catalogue
        </router-link>
        
        <svg class="w-4 h-4 text-gray-400" fill="currentColor" viewBox="0 0 20 20">
          <path fill-rule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clip-rule="evenodd"/>
        </svg>
        
        <span class="text-primary font-semibold">{{ product.name }}</span>
      </nav>

      <div class="bg-gray-100 rounded-lg shadow-sm overflow-hidden p-4 md:p-6">
        <div class="flex flex-col lg:flex-row gap-8">
          <div class="lg:w-2/5">
            <div class="relative mb-4 rounded-lg overflow-hidden">
              <div>
                <!-- Video -->
                <div v-if="selectedMedia && selectedMedia.type === MediaType.VIDEO" class="aspect-video w-full">
                  <iframe
                    :src="getYouTubeEmbedUrl(selectedMedia.url)"
                    class="w-full h-full"
                    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                    allowfullscreen
                  ></iframe>
                </div>
                <!-- Image -->
                <div v-else-if="selectedMedia" @click="showLightboxHandler(selectedMediaIndex)" class="relative group">
                  <img
                    :src="selectedMedia.url"
                    :alt="`${product.name} - Vue`"
                    class="w-full h-70 object-contain bg-gray-200 cursor-zoom-in"
                  />
                  <div class="absolute inset-0 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
                    <div class="bg-black bg-opacity-50 rounded-full p-2">
                      <div class="i-mdi-magnify text-2xl text-white"></div>
                    </div>
                  </div>
                </div>
              </div>
              <span
                v-if="product.discount"
                class="absolute top-4 left-4 bg-state-error text-white px-3 py-1 rounded-md"
              >
      </span>
            </div>
            <div class="grid grid-cols-4 gap-2">
              <div
                v-for="(media, index) in product.medias"
                @click="selectedMedia = media"
                :key="index"
                class="cursor-pointer rounded-md overflow-hidden border-2 transition-all"
                :class="selectedMedia === media ? 'border-primary' : 'border-transparent'"
              >
                <div v-if="media.type === MediaType.VIDEO" class="aspect-video w-full">
                  <div class="w-full h-full bg-#2a2b36 flex items-center justify-center">
                    <div class="i-mdi-play text-2xl text-primary"></div>
                  </div>
                </div>
                <img
                  v-else
                  :src="media.url"
                  :alt="`${product.name} - Vue ${index + 1}`"
                  class="w-full aspect-video object-cover rounded-xl"
                />
              </div>
            </div>

            <!-- Vue Easy Lightbox -->
            <vue-easy-lightbox
              :visible="lightboxVisible"
              :imgs="lightboxImages"
              :index="lightboxIndex"
              @hide="lightboxVisible = false"
              :moveDisabled="false"
              :enableZoom="true"
              :zoomScale="3"
            >
              <template v-slot:toolbar="{ toolbarMethods }">
                <div class="toolbar-custom">
                  <button @click="toolbarMethods.zoomIn" class="toolbar-btn">
                    <div class="i-mdi-plus text-xl text-white"></div>
                  </button>
                  <button @click="toolbarMethods.zoomOut" class="toolbar-btn">
                    <div class="i-mdi-minus text-xl text-white"></div>
                  </button>
                  <button @click="toolbarMethods.rotate" class="toolbar-btn">
                    <div class="i-mdi-rotate-right text-xl text-white"></div>
                  </button>
                  <button @click="lightboxVisible = false" class="toolbar-btn">
                    <div class="i-mdi-close text-xl text-white"></div>
                  </button>
                </div>
              </template>
            </vue-easy-lightbox>
          </div>

          <div class="lg:w-3/5">
            <div class="flex justify-between items-start">
              <div>
                <h1 class="text-xl md:text-3xl font-bold text-text-title mb-2">
                  {{ product.name }}
                </h1>
              </div>
            </div>

            <div class="mb-6">
              <div v-if="product.cta === ''" class="flex items-center gap-3 mb-2">
                <span  class="text-xl text-primary md:text-3xl font-bold"
                  >{{ formatPrice(getRealPrice(product.price, product.discount)) }} Fcfa</span
                >
                <span
                  v-if="product.discount > 0"
                  class="text-sm font-medium border text-primary border-primary rounded-full px-1 text-gray-500"
                >
                  Prix promo
                </span>
              </div>
              <div v-else>
                <span  class="text-xl text-primary md:text-3xl font-bold"
                >{{ product.cta }}</span
                >
              </div>
            </div>

            <!-- Sélection de l'état -->
            <div class="mb-6">
              <h3 class="font-medium text-text-title mb-3">État du produit</h3>
              <div class="flex gap-3">
                <button
                  @click="selectedCondition = 'new'"
                  class="px-4 py-2 rounded-md border transition-colors"
                  :class="
                    selectedCondition === 'new'
                      ? 'bg-primary text-white border-primary'
                      : 'bg-white text-text-body border-background-tertiary'
                  "
                >
                  Neuf
                  <span v-if="selectedCondition === 'new'" class="ml-2"></span>
                </button>
                <button
                  @click="selectedCondition = 'used'"
                  class="px-4 py-2 rounded-md border transition-colors"
                  :class="
                    selectedCondition === 'used'
                      ? 'bg-primary text-white border-primary'
                      : 'bg-white text-text-body border-background-tertiary'
                  "
                >
                  Occasion
                  <span v-if="selectedCondition === 'used'" class="ml-2">(Prix variable)</span>
                </button>
              </div>
            </div>

            <!-- Quantité -->
            <!-- <div class="mb-6">
              <h3 class="font-medium text-text-title mb-3">Quantité</h3>
              <div class="flex items-center">
                <button
                  @click="quantity > 1 && quantity--"
                  class="w-10 h-10 flex items-center justify-center border border-background-tertiary rounded-l-md"
                  :disabled="quantity <= 1"
                  :class="{ 'opacity-50': quantity <= 1 }"
                >
                  <MinusIcon class="w-4 h-4" />
                </button>
                <input
                  type="number"
                  v-model.number="quantity"
                  min="1"
                  class="w-16 h-10 border-y border-background-tertiary text-center"
                />
                <button
                  @click="quantity < 100 && quantity++"
                  class="w-10 h-10 flex items-center justify-center border border-background-tertiary rounded-r-md"
                >
                  <PlusIcon class="w-4 h-4" />
                </button>
              </div>
            </div> -->

            <!-- Actions -->
            <div class="flex flex-col sm:flex-row gap-3 mb-6">
              <button
                @click="callCommercial"
                class="flex gap-2 justify-center items-center py-3 px-4 border border-primary text-primary hover:bg-primary-light rounded-md transition-colors"
              >
                <div class="i-line-md-phone-call-loop w-5 h-5" />
                Contacter le vendeur
              </button>

              <button
                @click="sharePage"
                class="flex items-center justify-center gap-2 py-3 px-4 border border-background-tertiary text-text-secondary hover:text-primary rounded-md transition-colors"
              >
                <div class="i-mdi-ios-share w-5 h-5" />
                Partager
              </button>
            </div>

            <!-- Informations supplémentaires -->
            <div class="border-t border-background-tertiary pt-6">
              <div class="grid grid-cols-2 gap-4">
                <div>
                  <p class="text-text-secondary mb-1">Marque</p>
                  <p class="font-medium">{{ product.brand.name }}</p>
                </div>
                <div>
                  <p class="text-text-secondary mb-1">Catégorie</p>
                  <p class="font-medium">{{ product.category.name }}</p>
                </div>
                <div>
                  <p class="text-text-secondary mb-1">Livraison estimée</p>
                  <p class="font-medium">contact le vendeur pour les informations</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="mt-8">
        <div class="border-b border-background-tertiary">
          <div class="flex overflow-x-auto">
            <button
              v-for="tab in tabs"
              :key="tab.id"
              @click="activeTab = tab.id"
              class="px-6 py-3 font-medium whitespace-nowrap"
              :class="
                activeTab === tab.id
                  ? 'text-primary border-b-2 border-primary'
                  : 'text-text-secondary hover:text-text-body'
              "
            >
              {{ tab.name }}
            </button>
          </div>
        </div>

        <div class="py-6">
          <!-- Description -->
          <div v-if="activeTab === 'description'" class="bg-white rounded-lg shadow-sm p-6">
            <h2 class="text-xl font-semibold text-text-title mb-4">Description du produit</h2>
            <div class="prose text-text-body">
              <p>{{ product.description }}</p>
              <h3 class="text-lg font-medium text-text-title mt-6 mb-3">Caractéristiques</h3>
              <ul class="list-disc pl-5 space-y-2">
                <li v-for="(feature, index) in product.features" :key="index">
                  {{ feature }}
                </li>
              </ul>
            </div>
            <div class="bg-green-50 border border-green-200 rounded-lg p-4">
                <div class="flex items-center gap-3">
                  <div class="i-mdi-shield-check w-8 h-8 text-green-600"></div>
                  <div>
                    <h4 class="font-semibold text-green-900 mb-1">Conseil de sécurité</h4>
                    <p class="text-sm text-green-800">
                      Eviter d'envoyer des paiements anticipés
                    </p>
                    <p class="text-sm text-green-800">
                      Rencontrez le vendeur dans un lieu public sécurisé
                    </p>
                    <p class="text-sm text-green-800">
                      Inspectez ce que vous allez acheter pour vous assurer que c'est ce dont vous avez besoin avant de finaliser l'achat
                    </p>
                    <p class="text-sm text-green-800">
                      Vérifiez tous les documents et ne payez que si vous êtes satisfait
                    </p>
                  </div>
                </div>
              </div>
          </div>

          <div v-if="activeTab === 'shipping'" class="bg-white rounded-lg shadow-sm p-6">
            <h2 class="text-xl font-semibold text-text-title mb-4">Informations de livraison</h2>
            <div class="space-y-6">
              <div class="flex items-start gap-4 p-4 border border-background-tertiary rounded-lg">
                <StoreIcon class="w-8 h-8 text-primary" />
                <div>
                  <h3 class="font-medium text-text-title mb-1">Contactez le vendeur</h3>
                  <p class="text-text-body mb-2">Pour plus d'informations sur la livraison, veuillez contacter directement le vendeur.</p>
                  <p class="text-text-secondary text-sm">Disponibilite et modalites sur demande</p>
                </div>
              </div>
            </div>
            <div class="bg-green-50 border border-green-200 rounded-lg p-4">
                <div class="flex items-center gap-3">
                  <div class="i-mdi-shield-check w-8 h-8 text-green-600"></div>
                  <div>
                    <h4 class="font-semibold text-green-900 mb-1">Conseil de sécurité</h4>
                    <p class="text-sm text-green-800">
                      Eviter d'envoyer des paiements anticipés
                    </p>
                    <p class="text-sm text-green-800">
                      Rencontrez le vendeur dans un lieu public sécurisé
                    </p>
                    <p class="text-sm text-green-800">
                      Inspectez ce que vous allez acheter pour vous assurer que c'est ce dont vous avez besoin avant de finaliser l'achat
                    </p>
                    <p class="text-sm text-green-800">
                      Vérifiez tous les documents et ne payez que si vous êtes satisfait
                    </p>
                  </div>
                </div>
              </div>
          </div>

          <div v-if="activeTab === 'seller'" class="bg-white rounded-lg shadow-sm p-6">
            <h2 class="text-xl font-semibold text-text-title mb-4">Informations du vendeur</h2>
            <div v-if="product.seller" class="space-y-6">
              <!-- En-tête vendeur -->
              <div class="flex items-start gap-4">
                <div class="w-16 h-16 bg-gradient-to-br from-primary to-primary-dark rounded-full flex items-center justify-center text-white font-bold text-xl shadow-lg">
                  {{ product.seller.fullName?.charAt(0).toUpperCase() || 'V' }}
                </div>
                <div class="flex-1">
                  <h3 class="font-semibold text-text-title text-xl">{{ product.seller.fullName || 'Vendeur' }}</h3>
                  <div class="flex items-center gap-2 mt-1">
                    <span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800">
                      <div class="i-mdi-check-circle w-3 h-3 mr-1"></div>
                      Vendeur vérifié
                    </span>
                  </div>
                  <p class="text-text-secondary text-sm mt-2">Vendeur professionnel</p>
                </div>
              </div>
              
              <!-- Coordonnées complètes -->
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div class="flex items-center gap-3 p-4 bg-gray-50 rounded-lg border border-gray-200">
                  <div class="i-mdi-phone w-6 h-6 text-primary"></div>
                  <div>
                    <p class="text-sm font-medium text-text-secondary">Téléphone</p>
                    <p class="font-semibold text-text-title">{{ product.seller.phone || 'Non disponible' }}</p>
                  </div>
                </div>
                
                <div class="flex items-center gap-3 p-4 bg-gray-50 rounded-lg border border-gray-200">
                  <div class="i-mdi-email w-6 h-6 text-primary"></div>
                  <div>
                    <p class="text-sm font-medium text-text-secondary">Email</p>
                    <p class="font-semibold text-text-title text-sm">{{ product.seller.email }}</p>
                  </div>
                </div>

                <div class="flex items-center gap-3 p-4 bg-gray-50 rounded-lg border border-gray-200">
                  <div class="i-mdi-map-marker w-6 h-6 text-primary"></div>
                  <div>
                    <p class="text-sm font-medium text-text-secondary">Ville</p>
                    <p class="font-semibold text-text-title">{{ product.seller.city || 'Non spécifiée' }}</p>
                  </div>
                </div>

                <div class="flex items-center gap-3 p-4 bg-gray-50 rounded-lg border border-gray-200">
                  <div class="i-mdi-store w-6 h-6 text-primary"></div>
                  <div>
                    <p class="text-sm font-medium text-text-secondary">Type de compte</p>
                    <p class="font-semibold text-text-title">Vendeur professionnel</p>
                  </div>
                </div>
              </div>

              <!-- Statistiques du vendeur -->
              <!-- <div class="bg-gradient-to-r from-blue-50 to-indigo-50 border border-blue-200 rounded-lg p-4">
                <div class="flex items-center gap-2 mb-3">
                  <div class="i-mdi-chart-line w-5 h-5 text-blue-600"></div>
                  <h4 class="font-semibold text-blue-900">Performance du vendeur</h4>
                </div>
                <div class="grid grid-cols-3 gap-4 text-center">
                  <div>
                    <p class="text-2xl font-bold text-blue-900">156</p>
                    <p class="text-sm text-blue-700">Produits vendus</p>
                  </div>
                  <div>
                    <p class="text-2xl font-bold text-blue-900">4.8</p>
                    <p class="text-sm text-blue-700">Note moyenne</p>
                  </div>
                  <div>
                    <p class="text-2xl font-bold text-blue-900">2h</p>
                    <p class="text-sm text-blue-700">Temps de réponse</p>
                  </div>
                </div>
              </div> -->
              
              <!-- Actions de contact -->
              <div class="flex flex-col sm:flex-row gap-3">
                <button
                  @click="callCommercial"
                  class="flex-1 flex items-center justify-center gap-2 py-3 px-4 bg-primary hover:bg-primary-hover text-white rounded-lg transition-colors"
                >
                  <div class="i-line-md-phone-call-loop w-5 h-5" />
                  Contacter par WhatsApp
                </button>
                <button
                  @click="sendMessage"
                  class="flex-1 flex items-center justify-center gap-2 py-3 px-4 border border-primary text-primary hover:bg-primary-light rounded-lg transition-colors"
                >
                  <div class="i-mdi-message w-5 h-5" />
                  Envoyer un message
                </button>
              </div>

              <!-- Badge de confiance -->
              <div class="bg-green-50 border border-green-200 rounded-lg p-4">
                <div class="flex items-center gap-3">
                  <div class="i-mdi-shield-check w-8 h-8 text-green-600"></div>
                  <div>
                    <h4 class="font-semibold text-green-900 mb-1">Conseil de sécurité</h4>
                    <p class="text-sm text-green-800">
                      Eviter d'envoyer des paiements anticipés
                    </p>
                    <p class="text-sm text-green-800">
                      Rencontrez le vendeur dans un lieu public sécurisé
                    </p>
                    <p class="text-sm text-green-800">
                      Inspectez ce que vous allez acheter pour vous assurer que c'est ce dont vous avez besoin avant de finaliser l'achat
                    </p>
                    <p class="text-sm text-green-800">
                      Vérifiez tous les documents et ne payez que si vous êtes satisfait
                    </p>
                  </div>
                </div>
              </div>
            </div>
            
            <div v-else class="text-center py-8">
              <div class="i-mdi-store w-16 h-16 text-gray-400 mx-auto mb-4"></div>
              <h3 class="text-lg font-medium text-text-secondary mb-2">Vendeur non disponible</h3>
              <p class="text-text-body">Les informations du vendeur ne sont pas temporairement disponibles.</p>
            </div>
          </div>
        </div>
      </div>

      <OrderModal
        v-model="showOrderModal"
        :product="product"
        :quantity="quantity"
        :selected-condition="selectedCondition"
        @order-submitted="handleOrderSubmitted"
      />

      <AuthRequiredModal
        v-model="showAuthModal"
        :action="authAction"
        @continue-as-guest="handleGuestAction"
      />

      <OrderSuccessToast
        :show="showOrderConfirmation"
        title="Félicitations "
        message="Commande passée avec succès"
      />

      <OrderSuccessToast
        :show="showCopyLink"
        @close="showCopyLink = false"
        title="Lien copié "
        message="Le lien du produit a été copié dans le presse papier"
      />

      <SimilarProducts :similar-products="similarProducts" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { MinusIcon, PlusIcon, StoreIcon } from 'lucide-vue-next'
import SimilarProducts from '~/components/product/sections/SimilarProducts.vue'
import { router } from '@inertiajs/vue3'
import OrderModal from '~/components/product/OrderModal.vue'
import OrderSuccessToast from '~/components/order/OrderSuccessToast.vue'
import AuthRequiredModal from '~/components/auth/AuthRequiredModal.vue'
import { GetProductDto, MediaDto, MediaType } from '#dto/products_interface'
import { getRealPrice } from '~/composables/use_price'
import { useAuth } from '~/composables/useAuth'
import { formatPrice } from '~/composables/format_price'
import { getYouTubeEmbedUrl } from '~/composables/get_youtube_embed'
import VueEasyLightbox from 'vue-easy-lightbox';
const props = defineProps<{
  product: GetProductDto
  similarProducts: GetProductDto[]
}>()
const selectedMedia = ref<MediaDto | null>(props.product.medias?.[0] || null)
const selectedCondition = ref('new')
const quantity = ref(1)
const { user } = useAuth()
const activeTab = ref('description')
const showOrderModal = ref(false)
const showOrderConfirmation = ref(false)
const showCopyLink = ref(false)
const showAuthModal = ref(false)
const authAction = ref<'order' | 'comment' | 'contact'>('order')

const tabs = [
  { id: 'description', name: 'Description' },
  { id: 'shipping', name: 'Livraison' },
  { id: 'seller', name: 'Vendeur' },
]

const handleGuestAction = () => {
  if (authAction.value === 'order') {
    showOrderModal.value = true
  } else if (authAction.value === 'comment') {
    // Les commentaires nécessitent une authentification
    showAuthModal.value = true
  }
  // Pas d'action pour 'contact' - nécessite l'authentification
}

const handleOrderSubmitted = () => {
  showOrderConfirmation.value = true

  setTimeout(() => {
    showOrderConfirmation.value = false
  }, 1000)
}

const addToCart = () => {
  if (!user.value) {
    showAuthModal.value = true
    authAction.value = 'order'
  } else {
    showOrderModal.value = true
  }
}

const callCommercial = () => {
  if (!user.value) {
    showAuthModal.value = true
    authAction.value = 'contact'
  } else {
    // Utiliser le téléphone du vendeur, ou fallback sur le contact par défaut
    const sellerPhone = props.product.seller?.phone
    const defaultPhone = '22607513333'
    const phone = sellerPhone || defaultPhone
    
    window.location.href = `https://api.whatsapp.com/send?phone=${phone}` 
  }
}

const sendMessage = () => {
  // Ouvrir le client mail par défaut avec le vendeur pré-rempli
  const sellerEmail = props.product.seller?.email
  const subject = `Question concernant: ${props.product.name}` 
  const body = `Bonjour,\n\nJe suis intéressé(e) par votre produit "${props.product.name}".\n\nPourriez-vous me donner plus d'informations ?\n\nCordialement.` 
  
  window.location.href = `mailto:${sellerEmail}?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(body)}` 
}

const sharePage = async () => {
  const currentUrl = window.location.href

  try {
    if (navigator.share) {
      await navigator.share({
        title: document.title,
        url: currentUrl,
      })
      showCopyLink.value = true
      setTimeout(() => {
        showCopyLink.value = false
      }, 3000)
    } else if (navigator.clipboard) {
      try {
        await navigator.clipboard.writeText(currentUrl)
        showCopyLink.value = true
        setTimeout(() => {
          showCopyLink.value = false
        }, 3000)
      } catch (err) {
      }
    } else {
      // Solution de secours : utilise un champ caché pour copier manuellement l'URL
      const textarea = document.createElement('textarea')
      textarea.value = currentUrl
      document.body.appendChild(textarea)
      textarea.select()
      document.execCommand('copy')
      document.body.removeChild(textarea)
      showCopyLink.value = true
      setTimeout(() => {
        showCopyLink.value = false
      }, 3000)
    }
  } catch (error) {
  }
}

// Pour le zoom
// Variables pour le lightbox
const lightboxVisible = ref(false);
const lightboxIndex = ref(0);

// Filtrer uniquement les images pour le lightbox
const lightboxImages = computed(() => {
  return props.product.medias
    .filter(media => media.type !== MediaType.VIDEO)
    .map(media => ({
      src: media.url,
      title: props.product.name
    }));
});

// Index de l'image sélectionnée dans le tableau filtré
const selectedMediaIndex = computed(() => {
  if (!selectedMedia.value || selectedMedia.value.type === MediaType.VIDEO) return 0;
  return props.product.medias
    .filter(media => media.type !== MediaType.VIDEO)
    .findIndex(media => selectedMedia.value && media.url === selectedMedia.value.url);
});

// Afficher le lightbox
const showLightboxHandler = (index: number) => {
  lightboxIndex.value = index >= 0 ? index : 0;
  lightboxVisible.value = true;
};
</script>
<style scoped>
.toolbar-custom {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 1rem;
  padding: 0.5rem;
}

.toolbar-btn {
  background-color: rgba(0, 0, 0, 0.5);
  border-radius: 9999px;
  padding: 0.5rem;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background-color 0.2s;
}

.toolbar-btn:hover {
  background-color: rgba(0, 0, 0, 0.7);
}
</style>
