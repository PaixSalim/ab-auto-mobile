<template>
  <Transition
    enter-active-class="transition duration-300 ease-out"
    enter-from-class="transform scale-95 opacity-0"
    enter-to-class="transform scale-100 opacity-100"
    leave-active-class="transition duration-200 ease-in"
    leave-from-class="transform scale-100 opacity-100"
    leave-to-class="transform scale-95 opacity-0"
  >
    <div v-if="isVisible" class="fixed inset-0 flex items-center justify-center z-50">
      <div class="absolute inset-0 bg-black bg-opacity-50" @click="close"></div>
      <div class="bg-background-admin rounded-lg p-8 max-w-md w-full mx-4 relative">
        <div class="text-center">
          <div class="mx-auto flex items-center justify-center h-12 w-12 rounded-full bg-background-secondary mb-4">
            <div class="i-mdi-check text-2xl text-primary"></div>
          </div>
          <h3 class="text-lg leading-6 font-medium mb-2">Commande placée avec succès !</h3>
          <div class="mt-2">
            <p class="text-sm text-gray-400">
             Vous recevrez un e-mail dès qu'elle sera approuvée par notre équipe commerciale.
              Vous pourrez alors procéder au paiement pour finaliser votre commande.
            </p>
          </div>
          <div class="mt-5">
            <button
              @click="close"
              class="inline-flex justify-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-primary hover:bg-primary-dark focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary"
            >
              Fermer
            </button>
          </div>
        </div>
      </div>
    </div>
  </Transition>
</template>

<script setup lang="ts">
import { onMounted, onUnmounted } from 'vue'

const props = defineProps<{
  isVisible: boolean
}>()

const emit = defineEmits(['close'])

const close = () => {
  emit('close')
}

// Fermer le popup avec la touche Echap
const handleKeydown = (event: KeyboardEvent) => {
  if (event.key === 'Escape' && props.isVisible) {
    close()
  }
}

onMounted(() => {
  document.addEventListener('keydown', handleKeydown)
})

onUnmounted(() => {
  document.removeEventListener('keydown', handleKeydown)
})
</script>
