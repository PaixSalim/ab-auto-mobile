<script setup lang="ts">
import { ref, onMounted } from 'vue'

interface Toast {
  id: string
  type: 'success' | 'error' | 'warning' | 'info'
  title: string
  message: string
  duration?: number
}

const toasts = ref<Toast[]>([])

// Écouter les événements de toast
onMounted(() => {
  window.addEventListener('toast:show', (event: any) => {
    const toast: Toast = {
      id: Date.now().toString(),
      type: event.detail.type || 'info',
      title: event.detail.title || '',
      message: event.detail.message || '',
      duration: event.detail.duration || 4000
    }
    
    toasts.value.push(toast)
    
    // Auto-suppression
    setTimeout(() => {
      removeToast(toast.id)
    }, toast.duration)
  })
})

const removeToast = (id: string) => {
  const index = toasts.value.findIndex(toast => toast.id === id)
  if (index > -1) {
    toasts.value.splice(index, 1)
  }
}

const getIcon = (type: string) => {
  switch (type) {
    case 'success':
      return 'i-mdi-check-circle'
    case 'error':
      return 'i-mdi-close-circle'
    case 'warning':
      return 'i-mdi-alert-circle'
    case 'info':
      return 'i-mdi-information'
    default:
      return 'i-mdi-information'
  }
}

const getBgColor = (type: string) => {
  switch (type) {
    case 'success':
      return 'bg-green-600'
    case 'error':
      return 'bg-red-600'
    case 'warning':
      return 'bg-yellow-600'
    case 'info':
      return 'bg-blue-600'
    default:
      return 'bg-gray-600'
  }
}
</script>

<template>
  <div class="fixed top-4 right-4 z-50 space-y-2">
    <div
      v-for="toast in toasts"
      :key="toast.id"
      :class="[
        'flex items-start gap-3 p-4 rounded-lg shadow-lg min-w-[300px] max-w-md',
        'bg-gray-800 border border-gray-700',
        'transform transition-all duration-300 ease-in-out'
      ]"
    >
      <div :class="['flex-shrink-0 w-6 h-6', getBgColor(toast.type), 'rounded-full flex items-center justify-center']">
        <div :class="[getIcon(toast.type), 'text-white text-sm']"></div>
      </div>
      
      <div class="flex-1 min-w-0">
        <h4 v-if="toast.title" class="text-white font-medium text-sm mb-1">
          {{ toast.title }}
        </h4>
        <p class="text-gray-300 text-sm">
          {{ toast.message }}
        </p>
      </div>
      
      <button
        @click="removeToast(toast.id)"
        class="flex-shrink-0 text-gray-400 hover:text-white transition-colors"
      >
        <div class="i-mdi-close text-sm"></div>
      </button>
    </div>
  </div>
</template>
