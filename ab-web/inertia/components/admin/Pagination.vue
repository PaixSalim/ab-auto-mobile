<template>
  <div v-if="showPagination" class="bg-background-admin px-4 py-3 flex items-center justify-between border-t border-gray-700 sm:px-6">
    <div class="hidden sm:flex-1 sm:flex sm:items-center sm:justify-between">
      <div>
        <p class="text-sm text-gray-300">
          Affichage de <span class="font-medium">{{ paginationStart }}</span> à <span class="font-medium">{{ paginationEnd }}</span> sur <span class="font-medium">{{ totalItems }}</span>
          {{ itemName }}
        </p>
      </div>
      <div>
        <nav class="relative z-0 inline-flex rounded-md shadow-sm -space-x-px" aria-label="Pagination">
          <button
            @click="currentPage > 1 && (currentPage--)"
            :disabled="currentPage === 1"
            class="relative inline-flex items-center px-2 py-2 rounded-l-md border border-gray-600 bg-gray-700 text-sm font-medium text-gray-300 hover:bg-gray-600 disabled:opacity-50"
          >
            <span class="sr-only">Précédent</span>
            <div class="i-mdi-chevron-left text-xl"></div>
          </button>

          <template v-for="page in totalPages" :key="page">
            <button
              v-if="shouldShowPage(page)"
              @click="currentPage = page"
              :class="[
                'relative inline-flex items-center px-4 py-2 border text-sm font-medium',
                currentPage === page
                  ? 'z-10 bg-primary border-primary text-white'
                  : 'bg-gray-700 border-gray-600 text-gray-300 hover:bg-gray-600'
              ]"
            >
              {{ page }}
            </button>
            <span
              v-else-if="page === ellipsis.left || page === ellipsis.right"
              class="relative inline-flex items-center px-4 py-2 border text-gray-300"
            >
              ...
            </span>
          </template>

          <button
            @click="currentPage < totalPages && (currentPage++)"
            :disabled="currentPage === totalPages"
            class="relative inline-flex items-center px-2 py-2 rounded-r-md border border-gray-600 bg-gray-700 text-sm font-medium text-gray-300 hover:bg-gray-600 disabled:opacity-50"
          >
            <span class="sr-only">Suivant</span>
            <div class="i-mdi-chevron-right text-xl"></div>
          </button>
        </nav>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

interface Props {
  currentPage: number
  totalItems: number
  itemsPerPage: number
  itemName?: string
}

const props = withDefaults(defineProps<Props>(), {
  itemName: 'éléments'
})

const emit = defineEmits<{
  'update:currentPage': [value: number]
}>()

const ellipsis = {
  left: -1,
  right: -2
}

const totalPages = computed(() => Math.max(1, Math.ceil(props.totalItems / props.itemsPerPage)))

const paginationStart = computed(() => {
  if (props.totalItems === 0) return 0
  return (props.currentPage - 1) * props.itemsPerPage + 1
})

const paginationEnd = computed(() => {
  return Math.min(props.currentPage * props.itemsPerPage, props.totalItems)
})

const showPagination = computed(() => props.totalItems > 0)

const currentPage = computed({
  get: () => props.currentPage,
  set: (value: number) => emit('update:currentPage', value)
})

const shouldShowPage = (page: number) => {
  // Toujours afficher la première et la dernière page
  if (page === 1 || page === totalPages.value) return true

  // Afficher les pages autour de la page courante
  if (Math.abs(page - props.currentPage) <= 1) return true

  // Afficher les ellipsis
  if (page === ellipsis.left && props.currentPage > 3) return true
  if (page === ellipsis.right && props.currentPage < totalPages.value - 2) return true

  return false
}
</script>
