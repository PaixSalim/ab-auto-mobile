<template>
  <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
    <div class="bg-white rounded-xl w-full max-w-md p-6">
      <h2 class="text-2xl font-semibold mb-6 text-center text-gray-900">Confirmation</h2>
      <p class="text-gray-600 mb-6 text-center">
        {{ message }}
      </p>
      <div class="flex justify-between gap-4">
        <button
          @click="$emit('close')"
          class="bg-gray-200 hover:bg-gray-300 text-gray-800 font-bold py-2 w-full px-4 rounded-lg transition-colors"
        >
          Annuler
        </button>
        <button
          @click="$emit('action')"
          class="bg-primary hover:bg-primary/90 text-white font-bold py-2 px-4 rounded-lg transition-colors w-full"
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
