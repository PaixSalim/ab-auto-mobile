<script setup lang="ts">
import { ref } from 'vue'
import { router } from '@inertiajs/vue3'

const props = defineProps<{
  show: boolean
  title: string
  message: string
}>()

const openPopup = ref(props.show)

const closePopup = () => {
  openPopup.value = false
}

const goToCart = () => {
  router.visit('/cart')
}
</script>

<template>
  <div
    v-if="openPopup"
    class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50"
  >
    <div class="bg-#2a2b36 rounded-lg p-6 max-w-sm w-full space-y-4">
      <div class="flex items-center gap-4">
        <div
          class="w-12 h-12 rounded-full bg-#ff4d00 bg-opacity-20 flex items-center justify-center"
        >
          <div class="i-mdi-check text-#ff4d00 text-2xl"></div>
        </div>
        <div>
          <h3 class="font-bold text-white text-lg">{{ title }}</h3>
          <p class="text-gray-400">{{ message }}</p>
        </div>
      </div>
      <div class="flex gap-3">
        <button
          @click="closePopup"
          class="text-gray flex-1 px-4 py-2 border border-gray-600 rounded-lg hover:bg-#232430 transition-colors"
        >
          Continuer
        </button>
        <button
          @click="goToCart"
          class="text-white flex-1 px-4 py-2 bg-primary rounded-lg hover:bg-opacity-90 transition-colors"
        >
          Voir le panier
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped></style>
