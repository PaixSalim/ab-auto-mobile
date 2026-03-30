<template>
  <div class="bg-background-secondary rounded-lg shadow overflow-hidden">
    <!-- État de chargement -->
    <div v-if="loading" class="p-8">
      <div class="flex justify-center">
        <div class="i-mdi-loading animate-spin text-4xl text-primary"></div>
      </div>
      <p class="text-center mt-4 text-gray-500 dark:text-gray-400">Chargement...</p>
    </div>

    <!-- Message si aucun élément -->
    <div v-else-if="filteredItems.length === 0" class="p-8 text-center">
      <div class="i-mdi-inbox text-6xl mx-auto mb-4 text-gray-600"></div>
      <h3 class="text-xl font-medium text-gray-300 mb-2">Aucun élément trouvé</h3>
      <p class="text-gray-400">
        {{ hasFilters ? 'Essayez de modifier vos filtres pour voir plus de résultats.' : emptyMessage }}
      </p>
    </div>

    <!-- Tableau des éléments -->
    <table v-else class="min-w-full divide-y divide-gray-700">
      <thead class="bg-background-secondary">
        <tr>
          <th
            v-for="header in headers"
            :key="header.key"
            scope="col"
            class="px-6 py-3 text-left text-xs font-medium text-white uppercase tracking-wider"
            :class="header.textClass"
          >
            {{ header.label }}
          </th>
        </tr>
      </thead>
      <tbody class="bg-background-admin divide-y divide-gray-700">
        <tr v-for="item in paginatedItems" :key="getItemKey(item)" class="hover:bg-background-secondary">
          <td
            v-for="header in headers"
            :key="header.key"
            class="px-6 py-4 whitespace-nowrap text-white"
            :class="header.cellClass"
          >
            <slot :name="`cell-${header.key}`" :item="item" :header="header">
              {{ getItemValue(item, header.key) }}
            </slot>
          </td>
        </tr>
      </tbody>
    </table>

    <!-- Pagination -->
    <Pagination
      v-model:currentPage="currentPage"
      :total-items="filteredItems.length"
      :items-per-page="itemsPerPage"
      :item-name="itemName"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import Pagination from './Pagination.vue'

interface TableHeader {
  key: string
  label: string
  textClass?: string
  cellClass?: string
}

interface Props {
  items: any[]
  headers: TableHeader[]
  loading?: boolean
  itemsPerPage?: number
  itemName?: string
  emptyMessage?: string
  filters?: Record<string, any>
  itemKey?: string | ((item: any) => string)
}

const props = withDefaults(defineProps<Props>(), {
  loading: false,
  itemsPerPage: 10,
  itemName: 'éléments',
  emptyMessage: 'Aucun élément n\'a été ajouté pour le moment.',
  filters: () => ({}),
  itemKey: 'id'
})

const currentPage = ref(1)

// Computed
const hasFilters = computed(() => {
  return Object.values(props.filters).some(value => 
    value !== '' && value !== null && value !== undefined && value !== 'all'
  )
})

const filteredItems = computed(() => {
  let result = [...props.items]

  // Appliquer les filtres si fournis
  Object.entries(props.filters).forEach(([key, value]) => {
    if (value !== '' && value !== null && value !== undefined && value !== 'all') {
      result = result.filter(item => {
        const itemValue = getNestedValue(item, key)
        if (typeof itemValue === 'string') {
          return itemValue.toLowerCase().includes(String(value).toLowerCase())
        }
        return itemValue === value
      })
    }
  })

  return result
})

const paginatedItems = computed(() => {
  const start = (currentPage.value - 1) * props.itemsPerPage
  const end = start + props.itemsPerPage
  return filteredItems.value.slice(start, end)
})

// Méthodes
const getItemKey = (item: any) => {
  if (typeof props.itemKey === 'function') {
    return props.itemKey(item)
  }
  return getNestedValue(item, props.itemKey)
}

const getItemValue = (item: any, key: string) => {
  return getNestedValue(item, key)
}

const getNestedValue = (obj: any, path: string) => {
  return path.split('.').reduce((current, key) => current?.[key], obj)
}

// Réinitialiser la page courante quand les filtres changent
watch(() => props.filters, () => {
  currentPage.value = 1
}, { deep: true })
</script>

<style scoped>
.animate-spin {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}
</style>
