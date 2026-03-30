<template>
  <Teleport to="body">
    <div v-if="modelValue" class="fixed inset-0 z-50 flex items-center justify-center p-4">
      <!-- Overlay avec animation -->
      <div
        class="absolute inset-0 bg-black transition-opacity duration-300"
        :class="modelValue ? 'bg-opacity-50' : 'bg-opacity-0'"
        @click="closeModal"
      ></div>

      <!-- Modal avec animation -->
      <div
        class="bg-white rounded-lg shadow-xl w-full max-w-lg relative z-10 transition-all duration-300 transform max-h-[90vh] flex flex-col"
        :class="modelValue ? 'scale-100 opacity-100' : 'scale-95 opacity-0'"
        ref="modalRef"
      >
        <!-- En-tête -->
        <div class="flex justify-between items-center p-5 border-b border-background-tertiary flex-shrink-0">
          <h3 class="text-xl font-semibold text-text-title">Finaliser votre commande</h3>
          <button
            @click="closeModal"
            class="text-text-secondary hover:text-text-title transition-colors"
            aria-label="Fermer"
          >
            <XIcon class="w-5 h-5" />
          </button>
        </div>

        <!-- Corps du modal avec scroll -->
        <div class="p-5 flex-1 overflow-y-auto">
          <p class="text-text-body mb-5">
            Veuillez renseigner vos coordonnées pour que nous puissions vous contacter et confirmer votre commande.
          </p>

          <form @submit.prevent="submitOrder" class="space-y-4">
            <!-- Récapitulatif de la commande -->
            <div class="border p-4 rounded-md mb-4">
              <div class="flex items-center gap-3 mb-3">
                <div class="w-16 h-16 bg-background-tertiary rounded-md overflow-hidden">
                  <img
                    :src="product.medias[0].url"
                    :alt="product.name"
                    class="w-full h-full object-cover"
                  />
                </div>
                <div>
                  <h4 class="font-medium text-text-title">{{ product.name }}</h4>
                  <p class="text-sm text-text-secondary">
                    {{ selectedCondition === 'new' ? 'Neuf' : 'Occasion' }} • Quantité: {{ quantity }}
                  </p>
                </div>
              </div>
              
              <!-- Informations du vendeur -->
              <div v-if="product.seller" class="bg-gray-50 p-3 rounded-md mb-3">
                <div class="flex items-center gap-2 mb-2">
                  <div class="i-mdi-store w-4 h-4 text-primary"></div>
                  <span class="text-sm font-medium text-text-title">Vendu par:</span>
                </div>
                <div class="text-sm text-text-body">
                  <p class="font-medium">{{ product.seller.fullName || 'Vendeur' }}</p>
                  <div class="flex items-center gap-4 mt-1 text-xs text-text-secondary">
                    <span v-if="product.seller.phone">📞 {{ product.seller.phone }}</span>
                    <span>✉️ {{ product.seller.email }}</span>
                  </div>
                </div>
              </div>
              
              <div class="flex justify-between items-center pt-3 border-t border-background-tertiary">
                <span class="text-text-secondary">Total:</span>
                <span class="text-lg font-bold text-text-title">{{ formatPrice(totalPrice) }} Fcfa</span>
              </div>
            </div>

            <div>
              <label for="name" class="block text-sm font-medium text-text-title mb-1">
                Nom de l'entreprise <span class="text-state-error">*</span>
              </label>
              <input
                type="text"
                id="name"
                v-model="formData.name"
                class="w-full p-3 border border-background-tertiary rounded-md focus:outline-none focus:border-primary"
                :class="{'border-state-error': errors.customerName}"
                placeholder="Entrez le nom de votre entreprise"
                :readonly="!!user"
              />
              <p v-if="errors.customerName" class="text-primary mt-1 text-sm">{{ errors.customerName }}</p>
              <p v-else-if="user" class="mt-1 text-xs text-text-secondary">
                Prérempli avec vos informations
              </p>
            </div>

            <div>
              <label for="city" class="block text-sm font-medium text-text-title mb-1">
                Ville/Quartier <span class="text-state-error">*</span>
              </label>
              <input
                type="text"
                id="city"
                v-model="formData.city"
                class="w-full p-3 border border-background-tertiary rounded-md focus:outline-none focus:border-primary"
                :class="{'border-state-error': errors.city}"
                placeholder="Entrez votre ville"
              />
              <p v-if="errors.city" class="text-primary mt-1 text-sm">{{ errors.city }}</p>
              <p v-else class="mt-1 text-xs text-text-secondary">
                Entrez votre ville de livraison
              </p>
            </div>

            <div>
              <label for="whatsapp" class="block text-sm font-medium text-text-title mb-1">
                Numéro WhatsApp <span class="text-state-error">*</span>
              </label>
              <div class="relative">
                <div class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none">
                  <span class="text-text-secondary">+</span>
                </div>
                <input
                  type="tel"
                  id="whatsapp"
                  v-model="formData.whatsapp"
                  class="w-full p-3 pl-8 border border-background-tertiary rounded-md focus:outline-none focus:border-primary"
                  :class="{'border-state-error': errors.phoneNumber}"
                  placeholder="Ex: 22670707070"
                />
              </div>
              <p v-if="errors.phoneNumber" class="text-primary mt-1 text-sm text-state-error">{{ errors.phoneNumber }}</p>
              <p v-else class="mt-1 text-xs text-text-secondary">
                Nous vous contacterons sur ce numéro pour confirmer votre commande
              </p>
            </div>

            <div class="flex flex-col sm:flex-row gap-3 pt-3">
              <!-- Les boutons sont déplacés vers le pied du modal -->
            </div>
          </form>
        </div>

        <!-- Pied du modal fixe -->
        <div class="border-t border-background-tertiary p-5 flex-shrink-0 bg-white">
          <div class="flex flex-col sm:flex-row gap-3">
            <button
              type="button"
              @click="closeModal"
              class="flex py-3 px-4 border border-gray-300 text-gray-700 rounded-md hover:bg-gray-50 transition-colors flex items-center justify-center gap-2"
            >
              Annuler
            </button>
            <button
              type="submit"
              @click="submitOrder"
              class="flex py-3 px-4 bg-primary hover:bg-primary-hover text-white rounded-md transition-colors flex items-center justify-center gap-2"
              :disabled="isSubmitting"
            >
              <div v-if="isSubmitting" class="i-line-md-loading-twotone-loop w-5 h-5"></div>
              <div v-else class="i-line-md-chevron-down-square w-5 h-5" />
              {{ isSubmitting ? 'Envoi en cours...' : 'Confirmer la commande' }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script setup lang="ts">
import { ref, watch, onMounted, onBeforeUnmount, computed } from 'vue';
import { XIcon } from 'lucide-vue-next';
import { GetProductDto } from '#dto/products_interface'
import { router } from '@inertiajs/vue3'
import { formatPrice } from '~/composables/format_price'
import { usePageErrors } from '~/composables/use_page_errors'
import { useAuth } from '~/composables/useAuth'

const props = defineProps<{
  modelValue: boolean,
  product: GetProductDto,
  quantity: number,
  selectedCondition: string,
}>()

const emit = defineEmits(['update:modelValue', 'order-submitted']);

const modalRef = ref<HTMLElement | null>(null);
const isSubmitting = ref(false);
const { user } = useAuth();

// Préremplir avec les infos utilisateur si connecté
const formData = ref({
  name: user.value?.fullName || '',
  city: '',
  whatsapp: user.value?.phone || '',
})

// Mettre à jour le téléphone si l'utilisateur se connecte
watch(() => user.value, (newUser) => {
  if (newUser) {
    formData.value.name = newUser.fullName || ''
    formData.value.whatsapp = newUser.phone || ''
  }
}, { immediate: true });

const totalPrice = computed(() => {
  if (!props.product) return 0;

  let price = props.product.price;

 if (props.selectedCondition === 'used') {
    // Réduction de 30% pour les produits d'occasion sans prix spécifique
    price = Math.round(price * 0.7);
  }

  return price * props.quantity;
});

// Fermer le modal
const closeModal = () => {
  emit('update:modelValue', false);
};

const errors = usePageErrors();


// Soumettre la commande
const submitOrder = async () => {

  isSubmitting.value = true;

  try {
    router.post('/api/v1/order', {
      customerName: formData.value.name,
      city: formData.value.city,
      phoneNumber: formData.value.whatsapp,
      productId: props.product.id,
      quantity: props.quantity,
      userId: user.value?.id || null,
    }, {
      onSuccess: () => {
        emit('order-submitted')
        closeModal()
      }
    } )





  } catch (error) {
  } finally {
    isSubmitting.value = false;
  }
};

// Gérer la touche Echap pour fermer le modal
const handleEscKey = (event: any) => {
  if (event.key === 'Escape' && props.modelValue) {
    closeModal();
  }
};

watch(() => props.modelValue, (newVal) => {
  if (newVal) {
    document.body.style.overflow = 'hidden';
    setTimeout(() => {
      const firstInput = modalRef.value?.querySelector('input') as HTMLInputElement | null;
      if (firstInput) firstInput.focus();
    }, 100);
  } else {
    document.body.style.overflow = '';
  }
});

onMounted(() => {
  document.addEventListener('keydown', handleEscKey);
});

onBeforeUnmount(() => {
  document.removeEventListener('keydown', handleEscKey);
  document.body.style.overflow = ''; // Restaurer le défilement au démontage
});
</script>
