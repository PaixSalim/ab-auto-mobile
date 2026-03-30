<script setup lang="ts">
import { watch, nextTick } from 'vue'
import { usePage } from '@inertiajs/vue3'
import Toast from '~/components/admin/Toast.vue'

const page = usePage()

function emitToast(detail: { type?: string; title?: string; message: string }) {
  window.dispatchEvent(
    new CustomEvent('toast:show', {
      detail: {
        type: detail.type || 'info',
        title: detail.title || '',
        message: detail.message,
      },
    }),
  )
}

function emitFromProps() {
  const p = page.props as Record<string, unknown>

  const flash = p.flash as { type?: string; title?: string; message?: string } | undefined
  if (flash && typeof flash.message === 'string' && flash.message) {
    emitToast({
      type: flash.type,
      title: flash.title,
      message: flash.message,
    })
    return
  }

  if (typeof p.error === 'string' && p.error) {
    emitToast({ type: 'error', message: p.error })
    return
  }

  if (typeof p.success === 'string' && p.success) {
    emitToast({ type: 'success', message: p.success })
    return
  }

  const n = p.notification as { type?: string; message?: string } | undefined
  if (n && typeof n.message === 'string' && n.message) {
    emitToast({ type: n.type || 'success', message: n.message })
  }
}

watch(
  () => ({
    url: page.url,
    flash: (page.props as any).flash,
    success: (page.props as any).success,
    error: (page.props as any).error,
    notification: (page.props as any).notification,
  }),
  () => nextTick(() => emitFromProps()),
  { immediate: true },
)
</script>

<template>
  <Toast />
</template>
