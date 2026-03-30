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
    <div class="bg-white dark:bg-slate-900 rounded-[2rem] p-8 max-w-md w-full space-y-6 shadow-2xl border border-slate-200 dark:border-slate-800">
      <div class="flex items-center gap-4">
        <div
          class="w-14 h-14 rounded-full bg-emerald-100 dark:bg-emerald-900/30 flex items-center justify-center"
        >
          <div class="i-mdi-check text-emerald-600 dark:text-emerald-400 text-2xl"></div>
        </div>
        <div>
          <h3 class="font-bold text-slate-800 dark:text-white text-xl">{{ title }}</h3>
          <p class="text-slate-600 dark:text-slate-400">{{ message }}</p>
        </div>
      </div>
      <div class="flex gap-3">
        <button
          @click="closePopup"
          class="flex-1 px-6 py-3 border border-slate-200 dark:border-slate-700 rounded-xl text-slate-700 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors font-medium"
        >
          Continuer
        </button>
        <button
          @click="goToCart"
          class="flex-1 px-6 py-3 bg-primary text-white rounded-xl hover:bg-primary-dark transition-colors font-medium shadow-lg shadow-primary/20"
        >
          Voir le panier
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;900&display=swap');

.font-sans {
  font-family: 'Inter', sans-serif;
}
</style>
