<script setup lang="ts">
import { watch, nextTick } from 'vue'
import { usePage } from '@inertiajs/vue3'

const page = usePage()

// Version simplifiée sans erreurs
watch(
  () => page.url,
  () => {
    // Juste une watcher vide pour éviter les erreurs
  },
  { immediate: true }
)
</script>

<template>
  <!-- GlobalFlashToaster désactivé temporairement -->
</template>
