<template>
  <Transition name="fade">
    <div
      v-if="show"
      class="fixed inset-0 flex items-center justify-center px-4 py-6 pointer-events-none z-[9999]"
    >
      <div
        :class="[
          'max-w-sm w-full shadow-lg rounded-lg pointer-events-auto',
          type === PopupType.SUCCESS ? 'bg-green-500' : 'bg-red-500',
        ]"
      >
        <div class="rounded-lg shadow-xs overflow-hidden">
          <div class="p-4">
            <div class="flex items-start">
              <div class="flex-shrink-0 text-white">
                <CheckCircle v-if="type === PopupType.SUCCESS" class="h-7 w-7" aria-hidden="true" />
                <AlertCircle v-else class="h-7 w-7" aria-hidden="true" />
              </div>
              <div class="ml-3 w-0 flex-1 pt-0.5">
                <p class="text-sm leading-5 font-medium text-white">
                  {{ message }}
                </p>
              </div>
              <div class="ml-4 flex-shrink-0 flex">
                <button
                  type="button"
                  @click="$emit('close-callback')"
                  class="inline-flex text-white focus:outline-none focus:text-gray-300 transition ease-in-out duration-150"
                >
                  <X class="h-5 w-5" aria-hidden="true" />
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </Transition>
</template>

<script setup lang="ts">
import { CheckCircle, AlertCircle, X } from 'lucide-vue-next'
import { PopupType } from '#utils/popup_type_utils'

defineProps<{
  show: boolean
  type: PopupType
  message: string
}>()

defineEmits(['close-callback'])
</script>

<style scoped>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.5s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
