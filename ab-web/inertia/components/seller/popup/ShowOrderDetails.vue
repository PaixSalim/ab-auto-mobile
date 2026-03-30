<script setup lang="ts">
import type { SellerOrderType } from '~/types/order'

defineProps<{
  order: SellerOrderType
}>()
defineEmits(['close'])

const formatPrice = (price: number) => {
  return new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: 'XOF',
  }).format(price)
}
</script>

<template>
  <div
    class="fixed inset-0 bg-black bg-opacity-60 flex items-center justify-center p-2 sm:p-4 z-50 backdrop-blur-sm"
  >
    <div class="bg-white rounded-xl w-full mx-1 max-w-2xl max-h-[90vh] overflow-y-auto shadow-xl">
      <!-- Modal Header -->
      <div class="flex justify-between items-center p-4 sm:p-6 border-b border-gray-200">
        <h2 class="text-lg sm:text-xl font-bold text-gray-900">
          Commande #{{ order.id }}
        </h2>
        <button
          @click="$emit('close')"
          class="text-gray-400 hover:text-gray-600 transition-colors duration-200"
        >
          <div class="i-mdi-close text-xl sm:text-2xl"></div>
        </button>
      </div>

      <!-- Order Content -->
      <div class="p-4 sm:p-6 space-y-4 sm:space-y-6">
        <div :key="order.id" class="bg-gray-50 rounded-xl p-4 sm:p-5 shadow-sm">
          <div class="flex flex-col sm:flex-row sm:gap-5">
            <img
              v-if="order.product.medias && order.product.medias.length > 0"
              :src="order.product.medias[0].url"
              :alt="order.product.name"
              class="w-full sm:w-24 h-40 sm:h-24 rounded-xl object-cover shadow-md mb-4 sm:mb-0"
            />
            <div
              v-else
              class="w-full sm:w-24 h-40 sm:h-24 rounded-xl bg-gray-200 flex items-center justify-center mb-4 sm:mb-0"
            >
              <div class="i-mdi-image text-gray-400 text-3xl"></div>
            </div>

            <div class="flex-1 space-y-3">
              <h3 class="text-base md:text-lg font-semibold text-gray-900">
                {{ order.product.name }}
              </h3>

              <div class="space-y-2">
                <!-- Responsive grid layout for info items -->
                <div class="grid grid-cols-1 gap-2">
                  <div class="flex items-center">
                    <span class="text-gray-600 text-sm md:text-base w-24 sm:w-32">Quantité:</span>
                    <span class="text-sm md:text-base text-gray-900 font-medium">{{ order.quantity }}</span>
                  </div>

                  <div class="flex items-center">
                    <span class="text-gray-600 text-sm md:text-base w-24 sm:w-32">Prix unitaire:</span>
                    <span class="text-sm md:text-base text-gray-900 font-medium">{{ formatPrice(order.product.price) }}</span>
                  </div>

                  <div class="flex items-center">
                    <span class="text-gray-600 text-sm md:text-base w-24 sm:w-32">Total:</span>
                    <span class="text-sm md:text-base text-primary font-bold">{{ formatPrice(order.product.price * order.quantity) }}</span>
                  </div>
                </div>

                <div class="pt-2 border-t border-gray-200 mt-2">
                  <h4 class="text-sm font-medium text-gray-700 mb-2">Informations client</h4>

                  <div class="grid grid-cols-1 gap-2">
                    <div class="flex items-center">
                      <span class="text-gray-600 text-sm md:text-base w-24 sm:w-32">Nom:</span>
                      <span class="text-sm md:text-base text-gray-900">{{ order.customerName }}</span>
                    </div>

                    <div class="flex items-center">
                      <span class="text-gray-600 text-sm md:text-base w-24 sm:w-32">Téléphone:</span>
                      <span class="text-sm md:text-base text-primary">
                        <a
                          class="flex items-center hover:text-primary-light transition-colors duration-200"
                          :href="`https://api.whatsapp.com/send?phone=${order.phoneNumber}&text=Bonjour,`"
                          target="_blank"
                          rel="noopener noreferrer"
                        >
                          <div class="w-5 h-5 sm:w-7 sm:h-7 i-line-md-phone-call-loop mr-1"></div>
                          <span>+{{ order.phoneNumber }}</span>
                        </a>
                      </span>
                    </div>

                    <div v-if="order.city" class="flex items-center">
                      <span class="text-gray-600 text-sm md:text-base w-24 sm:w-32">Ville:</span>
                      <span class="text-sm md:text-base text-gray-900">{{ order.city }}</span>
                    </div>
                  </div>
                </div>

                <div v-if="order.address" class="pt-2 border-t border-gray-200 mt-2">
                  <h4 class="text-sm font-medium text-gray-700 mb-2">Adresse de livraison</h4>
                  <p class="text-sm text-gray-900">{{ order.address }}</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Modal Footer -->
      <div class="px-4 sm:px-6 pb-4 sm:pb-6 flex justify-end">
        <button
          @click="$emit('close')"
          class="bg-gray-100 hover:bg-gray-200 text-gray-800 px-3 py-2 sm:px-4 sm:py-2 text-sm sm:text-base rounded-lg transition-colors duration-200"
        >
          Fermer
        </button>
      </div>
    </div>
  </div>
</template>

