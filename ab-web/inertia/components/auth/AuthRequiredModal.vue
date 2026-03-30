<template>
  <Teleport to="body">
    <div v-if="modelValue" class="fixed inset-0 z-50 flex items-center justify-center p-4">
      <!-- Overlay -->
      <div
        class="absolute inset-0 bg-black transition-opacity duration-300"
        :class="modelValue ? 'bg-opacity-50' : 'bg-opacity-0'"
        @click="closeModal"
      ></div>

      <!-- Modal -->
      <div
        class="bg-white rounded-lg shadow-xl w-full max-w-md relative z-10 transition-all duration-300 transform"
        :class="modelValue ? 'scale-100 opacity-100' : 'scale-95 opacity-0'"
      >
        <!-- En-tête -->
        <div class="flex justify-between items-center p-6 border-b">
          <h3 class="text-xl font-semibold text-gray-900">Connexion requise</h3>
          <button
            @click="closeModal"
            class="text-gray-400 hover:text-gray-600 transition-colors"
            aria-label="Fermer"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
            </svg>
          </button>
        </div>

        <!-- Corps -->
        <div class="p-6">
          <!-- Message -->
          <div class="text-center mb-6">
            <div class="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <svg class="w-8 h-8 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
              </svg>
            </div>
            <h4 class="text-lg font-semibold text-gray-900 mb-2">
              {{ action === 'order' ? 'Connectez-vous pour commander' : 'Connectez-vous pour commenter' }}
            </h4>
            <p class="text-gray-600">
              {{ action === 'order' 
                ? 'Pour passer une commande, vous devez être connecté à votre compte.' 
                : 'Pour laisser un commentaire, vous devez être connecté à votre compte.' 
              }}
            </p>
          </div>

          <!-- Options -->
          <div class="space-y-3">
            <!-- Se connecter -->
            <button
              @click="goToLogin"
              class="w-full py-3 bg-primary hover:bg-primary-hover text-white rounded-lg transition-colors font-medium"
            >
              Se connecter
            </button>

            <!-- Créer un compte -->
            <button
              @click="goToRegister"
              class="w-full py-3 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-lg transition-colors font-medium"
            >
              Créer un compte
            </button>

            <!-- Continuer sans connexion (optionnel) -->
            <div v-if="allowGuest" class="text-center pt-3 border-t">
              <button
                @click="continueAsGuest"
                class="text-sm text-gray-500 hover:text-gray-700 transition-colors"
              >
                Continuer sans connexion
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script setup lang="ts">
import { router } from '@inertiajs/vue3'

const props = defineProps<{
  modelValue: boolean
  action: 'order' | 'comment'
  allowGuest?: boolean
}>()

const emit = defineEmits<{
  'update:modelValue': [value: boolean]
  'close': []
  'continue-as-guest': []
}>()

const closeModal = () => {
  emit('update:modelValue', false)
  emit('close')
}

const goToLogin = () => {
  closeModal()
  router.get('/auth/login')
}

const goToRegister = () => {
  closeModal()
  router.get('/auth/register')
}

const continueAsGuest = () => {
  closeModal()
  emit('continue-as-guest')
}
</script>
