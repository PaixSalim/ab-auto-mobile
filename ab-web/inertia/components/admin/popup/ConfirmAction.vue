<template>
  <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
    <div class="bg-#232430 rounded-xl w-full max-w-md p-6">
      <h2 class="text-2xl font-semibold mb-6 text-center">Avertissement</h2>
      <p class="text-gray-400 mb-6 text-center">
        {{ message }}
      </p>
      <div class="flex justify-between gap-4">
        <button
          @click="$emit('close')"
          class="bg-gray-600 hover:bg-opacity-90 text-white font-bold py-2 w-full px-4 rounded-lg transition-colors"
        >
          Annuler
        </button>
        <button
          @click="$emit('action')"
          class="bg-#ff4d00 hover:bg-opacity-90 text-white font-bold py-2 px-4 rounded-lg transition-colors w-full"
        >
          {{ action }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  message: string
  action: string
}>()
defineEmits(['close', 'action'])
</script>
