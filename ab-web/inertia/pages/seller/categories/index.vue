<template>
  <Layout>
    <div class="p-6">
      <div class="flex justify-between items-center mb-6">
        <h1 class="text-3xl font-bold text-title">Gestion des Catégories</h1>
        <button
          @click="openCreateModal()"
          class="bg-primary text-white px-6 py-2 rounded-lg hover:bg-primary/90 flex items-center gap-2"
        >
          <span class="i-mdi-plus text-xl"></span>
          Nouvelle catégorie
        </button>
      </div>

      <div class="bg-background-admin rounded-lg shadow-md p-6">
        <div v-if="categories.length === 0" class="text-center py-12">
          <p class="text-description text-lg">Aucune catégorie pour le moment</p>
        </div>

        <div v-else class="space-y-4">
          <div
            v-for="category in categories"
            :key="category.id"
            class="border border-gray-200 rounded-lg p-4"
          >
            <div class="flex justify-between items-center">
              <div class="flex-1">
                <h3 class="text-xl font-semibold text-title">{{ category.name }}</h3>
                <p class="text-sm text-description">URL: {{ category.url }}</p>
              </div>
              <div class="flex gap-2">
                <button
                  @click="openCreateModal(category.id)"
                  class="bg-green-500 text-white px-4 py-2 rounded hover:bg-green-600 flex items-center gap-2"
                >
                  <span class="i-mdi-plus"></span>
                  Sous-catégorie
                </button>
                <button
                  @click="editCategory(category)"
                  class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600 flex items-center gap-2"
                >
                  <span class="i-mdi-pencil"></span>
                  Modifier
                </button>
                <button
                  @click="deleteCategory(category.id)"
                  class="bg-red-500 text-white px-4 py-2 rounded hover:bg-red-600 flex items-center gap-2"
                >
                  <span class="i-mdi-delete"></span>
                  Supprimer
                </button>
              </div>
            </div>

            <!-- Sous-catégories -->
            <div v-if="category.subCategories && category.subCategories.length > 0" class="mt-4 ml-8 space-y-2">
              <div
                v-for="subCategory in category.subCategories"
                :key="subCategory.id"
                class="border-l-4 border-primary pl-4 py-2 bg-gray-50 rounded"
              >
                <div class="flex justify-between items-center">
                  <div>
                    <h4 class="font-semibold text-title">{{ subCategory.name }}</h4>
                    <p class="text-sm text-description">URL: {{ subCategory.url }}</p>
                  </div>
                  <div class="flex gap-2">
                    <button
                      @click="editCategory(subCategory)"
                      class="bg-blue-500 text-white px-3 py-1 rounded hover:bg-blue-600 text-sm"
                    >
                      Modifier
                    </button>
                    <button
                      @click="deleteCategory(subCategory.id)"
                      class="bg-red-500 text-white px-3 py-1 rounded hover:bg-red-600 text-sm"
                    >
                      Supprimer
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Modal Créer/Modifier -->
      <div v-if="showModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div class="bg-white rounded-lg p-6 w-full max-w-md">
          <h2 class="text-2xl font-bold mb-4">{{ editingCategory ? 'Modifier' : 'Créer' }} une catégorie</h2>
          
          <form @submit.prevent="submitCategory">
            <div class="mb-4">
              <label class="block text-sm font-medium mb-2">Nom</label>
              <input
                v-model="formData.name"
                type="text"
                class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                required
              />
            </div>

            <div class="mb-4">
              <label class="block text-sm font-medium mb-2">URL</label>
              <input
                v-model="formData.url"
                type="text"
                class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                required
              />
            </div>

            <div class="flex gap-2">
              <button
                type="submit"
                class="flex-1 bg-primary text-white px-4 py-2 rounded-lg hover:bg-primary/90"
              >
                {{ editingCategory ? 'Modifier' : 'Créer' }}
              </button>
              <button
                type="button"
                @click="closeModal"
                class="flex-1 bg-gray-300 text-gray-700 px-4 py-2 rounded-lg hover:bg-gray-400"
              >
                Annuler
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </Layout>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { router } from '@inertiajs/vue3'
import Layout from '~/components/seller/Layout.vue'

interface Category {
  id: number
  name: string
  url: string
  parentId?: number | null
  subCategories?: Category[]
}

const props = defineProps<{
  categories: Category[]
}>()

const showModal = ref(false)
const editingCategory = ref<Category | null>(null)
const parentIdForNew = ref<number | null>(null)
const formData = ref({
  name: '',
  url: '',
})

function openCreateModal(parentId?: number) {
  editingCategory.value = null
  parentIdForNew.value = parentId || null
  formData.value = { name: '', url: '' }
  showModal.value = true
}

function editCategory(category: Category) {
  editingCategory.value = category
  formData.value = {
    name: category.name,
    url: category.url,
  }
  showModal.value = true
}

function closeModal() {
  showModal.value = false
  editingCategory.value = null
  parentIdForNew.value = null
}

function submitCategory() {
  const data = {
    ...formData.value,
    parentId: parentIdForNew.value,
  }

  if (editingCategory.value) {
    router.put('/seller/categories/edit', {
      id: editingCategory.value.id,
      ...data,
    }, {
      onSuccess: () => closeModal(),
    })
  } else {
    router.post('/seller/categories/create', data, {
      onSuccess: () => closeModal(),
    })
  }
}

function deleteCategory(id: number) {
  if (confirm('Êtes-vous sûr de vouloir supprimer cette catégorie ?')) {
    router.delete(`/seller/categories/delete/${id}`)
  }
}
</script>
