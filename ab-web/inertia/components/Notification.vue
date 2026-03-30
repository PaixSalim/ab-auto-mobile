<template>
  <Transition
    enter-active-class="transition ease-out duration-300"
    enter-from-class="translate-y-2 opacity-0"
    enter-to-class="translate-y-0 opacity-100"
    leave-active-class="transition ease-in duration-200"
    leave-from-class="translate-y-0 opacity-100"
    leave-to-class="translate-y-2 opacity-0"
  >
    <div
      v-if="show"
      :class="[
        'fixed top-4 right-4 z-50 max-w-md w-full shadow-lg rounded-lg p-4 flex items-center gap-3',
        typeClasses
      ]"
    >
      <div :class="iconClass"></div>
      <p class="flex-1 text-sm font-medium">{{ message }}</p>
      <button @click="close" class="text-current opacity-70 hover:opacity-100">
        <div class="i-mdi-close text-xl"></div>
      </button>
    </div>
  </Transition>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import { usePage } from '@inertiajs/vue3'

const page = usePage()
const show = ref(false)
const message = ref('')
const type = ref<'success' | 'error' | 'info' | 'warning'>('success')

const typeClasses = computed(() => {
  switch (type.value) {
    case 'success':
      return 'bg-green-50 text-green-800 border border-green-200'
    case 'error':
      return 'bg-red-50 text-red-800 border border-red-200'
    case 'warning':
      return 'bg-yellow-50 text-yellow-800 border border-yellow-200'
    case 'info':
      return 'bg-blue-50 text-blue-800 border border-blue-200'
    default:
      return 'bg-gray-50 text-gray-800 border border-gray-200'
  }
})

const iconClass = computed(() => {
  switch (type.value) {
    case 'success':
      return 'i-mdi-check-circle text-2xl text-green-600'
    case 'error':
      return 'i-mdi-alert-circle text-2xl text-red-600'
    case 'warning':
      return 'i-mdi-alert text-2xl text-yellow-600'
    case 'info':
      return 'i-mdi-information text-2xl text-blue-600'
    default:
      return 'i-mdi-information text-2xl'
  }
})

const close = () => {
  show.value = false
}

const displayNotification = (notification: any) => {
  if (notification) {
    message.value = notification.message
    type.value = notification.type || 'success'
    show.value = true

    setTimeout(() => {
      show.value = false
    }, 5000)
  }
}

watch(() => page.props.notification, (notification) => {
  displayNotification(notification)
}, { immediate: true })

onMounted(() => {
  if (page.props.notification) {
    displayNotification(page.props.notification)
  }
})
</script>
