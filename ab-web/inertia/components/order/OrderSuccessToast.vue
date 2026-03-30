<template>
  <Transition name="toast">
    <div
      v-if="show"
      class="fixed bottom-4 right-4 bg-state-success text-white bg-green-6 px-4 mx-2 py-1 rounded-lg shadow-lg flex items-center gap-3 z-50 max-w-md"
    >
      <CheckCircleIcon class="w-5 h-5 flex-shrink-0" />
      <div class="flex-1">
        <p class="font-medium">{{ title }}</p>
        <p class="text-sm opacity-90">{{ message }}</p>
      </div>
      <button
        @click="$emit('close')"
        class="ml-2 text-white hover:bg-white hover:bg-opacity-20 rounded-full p-1"
        aria-label="Fermer"
      >
        <XIcon class="w-4 h-4" />
      </button>
    </div>
  </Transition>
</template>

<script setup lang="ts">
import { CheckCircleIcon, XIcon } from 'lucide-vue-next';

defineProps({
  show: {
    type: Boolean,
    default: false
  },
  title: {
    type: String,
    default: 'Succès!'
  },
  message: {
    type: String,
    default: 'Opération effectuée avec succès.'
  }
});

defineEmits(['close']);
</script>

<style scoped>
.toast-enter-active,
.toast-leave-active {
  transition: all 0.3s ease;
}

.toast-enter-from {
  transform: translateY(30px);
  opacity: 0;
}

.toast-leave-to {
  transform: translateX(100%);
  opacity: 0;
}
</style>
