<template>
  <Layout title="Gestion des Catégories">
    <Notification />
    <div class="px-6 py-8">
      <div class="flex justify-between items-center mb-8">
        <div>
          <h1 class="text-3xl font-bold text-title mb-1">Catégories</h1>
          <p class="text-description text-sm">Organisez vos produits par familles et sous-familles</p>
        </div>
        <button
          @click="openCreateModal"
          class="bg-primary hover:bg-primary-dark text-white font-bold py-2.5 px-6 rounded-xl shadow-lg shadow-primary/20 transition-all flex items-center gap-2 group"
        >
          <div class="i-mdi-plus-circle text-xl group-hover:scale-110 transition-transform"></div>
          Nouvelle catégorie
        </button>
      </div>

      <PaginatedList
        :items="allCategories"
        :headers="categoryHeaders"
        :items-per-page="10"
        item-name="catégories"
        empty-message="Aucune catégorie trouvée."
      >
        <template #cell-name="{ item }">
          <div class="font-bold text-title flex items-center gap-2">
            <div v-if="item.parentId" class="i-mdi-subdirectory-arrow-right text-slate-500 translate-y-0.5"></div>
            {{ item.name }}
          </div>
        </template>
        
        <template #cell-image="{ item }">
          <div class="flex items-center gap-3">
            <div class="relative group">
              <div class="absolute -inset-1 bg-gradient-to-br from-primary/20 to-transparent rounded-xl opacity-0 group-hover:opacity-100 transition-opacity"></div>
              <img 
                :src="getCategoryImageUrl(item)" 
                :alt="item.name"
                class="w-12 h-12 rounded-xl object-cover border border-slate-800 shadow-inner relative z-10"
                @error="handleImageError"
              />
            </div>
          </div>
        </template>

        <template #cell-subCategories="{ item }">
          <div v-if="!item.parentId" class="flex items-center gap-2">
            <span v-if="item.subCategories?.length" class="inline-flex items-center gap-1 px-2.5 py-0.5 bg-primary/10 text-primary text-[10px] uppercase font-black rounded-lg border border-primary/20 tracking-wider">
              <div class="i-mdi-layers-triple-outline text-xs"></div>
              {{ item.subCategories.length }} Sous-catégories
            </span>
            <span v-else class="text-[10px] text-description uppercase font-bold tracking-widest opacity-40 italic">Parent uniquement</span>
          </div>
          <div v-else class="text-[10px] text-description uppercase font-bold tracking-widest opacity-40">Enfant de #{{ item.parentId }}</div>
        </template>

        <template #cell-actions="{ item }">
          <div class="flex items-center gap-4">
            <button
              @click="editCategory(item)"
              class="text-blue-400 hover:text-blue-300 flex items-center gap-1.5 transition-colors group"
              title="Modifier"
            >
              <div class="i-mdi-pencil text-lg group-hover:scale-110 transition-transform"></div>
              <span class="text-xs font-bold uppercase tracking-wider">Modifier</span>
            </button>
            <button
              @click="deleteCategory(item.id)"
              class="text-red-400 hover:text-red-300 flex items-center gap-1.5 transition-colors group"
              title="Supprimer"
            >
              <div class="i-mdi-delete text-lg group-hover:scale-110 transition-transform"></div>
              <span class="text-xs font-bold uppercase tracking-wider">Supprimer</span>
            </button>
          </div>
        </template>
      </PaginatedList>

      <!-- Modal Créer/Modifier Catégorie -->
      <div v-if="showCreateModal" class="fixed inset-0 bg-slate-950/80 backdrop-blur-sm flex items-center justify-center z-50 p-4">
        <div class="bg-background-secondary border border-slate-800 rounded-2xl shadow-2xl w-full max-w-lg overflow-hidden transform transition-all max-h-[90vh] flex flex-col">
          <div class="p-6 border-b border-slate-800 flex justify-between items-center bg-slate-900/50">
            <h2 class="text-xl font-bold text-title">{{ editingCategory ? 'Modifier la catégorie' : 'Créer une catégorie' }}</h2>
            <button @click="closeModal" class="text-slate-400 hover:text-white transition-colors">
              <div class="i-mdi-close text-2xl"></div>
            </button>
          </div>
          
          <form @submit.prevent="submitCategory" class="p-8 space-y-6 overflow-y-auto">
            <div>
              <label class="block text-sm font-bold text-description uppercase tracking-widest mb-2">Nom de la catégorie *</label>
              <input
                v-model="formData.name"
                type="text"
                class="w-full bg-slate-950 border border-slate-800 rounded-xl px-4 py-3 text-title focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all"
                placeholder="Ex: Pièces Moteur"
                required
              />
            </div>

            <div>
              <label class="block text-sm font-bold text-description uppercase tracking-widest mb-2">Visuel de catégorie</label>
              <div class="space-y-4">
                <!-- Preview and Upload -->
                <div class="flex items-center gap-6 p-4 bg-slate-950 rounded-xl border border-slate-800 border-dashed">
                  <div class="relative w-24 h-24 shrink-0 overflow-hidden rounded-xl border border-slate-800 bg-slate-900 flex items-center justify-center">
                    <img v-if="previewUrl || (formData.url && !selectedFile)" :src="previewUrl || formData.url" class="w-full h-full object-cover" />
                    <div v-else class="i-mdi-image-plus text-3xl text-slate-700"></div>
                  </div>
                  <div class="flex-1 space-y-3">
                    <input
                      type="file"
                      id="cat-image"
                      accept="image/*"
                      @change="handleFileChange"
                      class="hidden"
                    />
                    <label for="cat-image" class="inline-flex items-center gap-2 px-4 py-2 bg-slate-800 hover:bg-slate-700 text-title text-xs font-bold rounded-lg cursor-pointer transition-colors uppercase tracking-widest border border-slate-700">
                      <div class="i-mdi-upload text-sm"></div>
                      Sélectionner une image
                    </label>
                    <p class="text-[10px] text-description italic tracking-tight">JPG, PNG ou GIF. Max 2MB recommandé.</p>
                    <button v-if="selectedFile" type="button" @click="removeSelectedFile" class="text-[10px] text-red-500 hover:text-red-400 font-bold uppercase underline">Annuler la sélection</button>
                  </div>
                </div>

                <div class="pt-2">
                  <label class="block text-[10px] font-bold text-description uppercase tracking-[0.2em] mb-2 opacity-50">Ou via URL externe</label>
                  <input
                    v-model="formData.url"
                    type="text"
                    placeholder="https://example.com/image.jpg"
                    class="w-full bg-slate-950 border border-slate-800 rounded-xl px-4 py-2 text-xs text-title focus:outline-none focus:ring-1 focus:ring-primary transition-all italic"
                  />
                </div>
              </div>
            </div>

            <div>
              <label class="block text-sm font-bold text-description uppercase tracking-widest mb-2">Structure de navigation</label>
              <div class="relative">
                <select
                  v-model="formData.parentId"
                  class="w-full bg-slate-950 border border-slate-800 rounded-xl px-4 py-3 text-title focus:outline-none focus:ring-2 focus:ring-primary appearance-none cursor-pointer"
                >
                  <option value="">Aucune (Catégorie principale)</option>
                  <option v-for="cat in categories.filter(c => !c.parentId && c.id !== editingCategory?.id)" :key="cat.id" :value="cat.id.toString()">
                    Dans {{ cat.name }}
                  </option>
                </select>
                <div class="i-mdi-chevron-down absolute right-4 top-1/2 -translate-y-1/2 text-slate-600 pointer-events-none"></div>
              </div>
            </div>

            <div class="flex gap-4 pt-4 border-t border-slate-800">
              <button
                type="button"
                @click="closeModal"
                class="flex-1 bg-slate-800 text-title px-6 py-3.5 rounded-xl hover:bg-slate-700 transition-colors font-bold uppercase tracking-widest text-xs"
              >
                Annuler
              </button>
              <button
                type="submit"
                class="flex-1 bg-primary text-white px-6 py-3.5 rounded-xl hover:bg-primary-dark transition-all font-bold shadow-lg shadow-primary/20 uppercase tracking-widest text-xs"
              >
                {{ editingCategory ? 'Enregistrer les modifications' : 'Créer la catégorie' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </Layout>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { router } from '@inertiajs/vue3'
import Layout from '~/components/admin/Layout.vue'
import PaginatedList from '~/components/admin/PaginatedList.vue'
import Notification from '../../../components/Notification.vue'

interface Category {
  id: number
  name: string
  url: string
  parentId: number | null
  subCategories?: Category[]
}

const props = defineProps<{
  categories: Category[]
}>()

// Définition des en-têtes pour le tableau
const categoryHeaders = [
  { key: 'name', label: 'Nom' },
  { key: 'image', label: 'Image' },
  { key: 'subCategories', label: 'Sous-catégories' },
  { key: 'actions', label: 'Actions' }
]

// Aplatir les catégories et sous-catégories pour la pagination
const allCategories = computed(() => {
  const flattened: Category[] = []
  
  props.categories.forEach(category => {
    // Ajouter la catégorie principale
    flattened.push(category)
    
    // Ajouter les sous-catégories
    if (category.subCategories) {
      category.subCategories.forEach(subCategory => {
        flattened.push(subCategory)
      })
    }
  })
  
  return flattened
})

const showCreateModal = ref(false)
const editingCategory = ref<Category | null>(null)
const selectedFile = ref<File | null>(null)
const previewUrl = ref<string>('')
const formData = ref({
  name: '',
  url: '',
  parentId: ''
})

const openCreateModal = () => {
  editingCategory.value = null
  formData.value = { name: '', url: '', parentId: '' }
  selectedFile.value = null
  previewUrl.value = ''
  showCreateModal.value = true
}

const editCategory = (category: Category) => {
  editingCategory.value = category
  formData.value = {
    name: category.name,
    url: category.url,
    parentId: category.parentId?.toString() || ''
  }
  selectedFile.value = null
  previewUrl.value = ''
  showCreateModal.value = true
}

const closeModal = () => {
  showCreateModal.value = false
  editingCategory.value = null
  formData.value = { name: '', url: '', parentId: '' }
  selectedFile.value = null
  previewUrl.value = ''
}

const handleFileChange = (event: Event) => {
  const target = event.target as HTMLInputElement
  const file = target.files?.[0]
  
  if (file) {
    // Vérifier la taille (max 5MB)
    if (file.size > 5 * 1024 * 1024) {
      alert('L\'image ne doit pas dépasser 5MB')
      target.value = ''
      return
    }
    
    // Vérifier le type
    if (!file.type.startsWith('image/')) {
      alert('Veuillez sélectionner une image valide')
      target.value = ''
      return
    }
    
    selectedFile.value = file
    
    // Créer une preview
    const reader = new FileReader()
    reader.onload = (e) => {
      previewUrl.value = e.target?.result as string
    }
    reader.readAsDataURL(file)
  }
}

const removeSelectedFile = () => {
  selectedFile.value = null
  previewUrl.value = ''
  // Réinitialiser l'input file
  const fileInput = document.querySelector('input[type="file"]') as HTMLInputElement
  if (fileInput) {
    fileInput.value = ''
  }
}

const submitCategory = () => {
  const url = editingCategory.value 
    ? `/dashboard/categories/edit/${editingCategory.value.id}`
    : '/dashboard/categories/create'

  // Utiliser FormData pour envoyer l'image
  const formDataToSend = new FormData()
  
  // Ajouter les champs du formulaire
  formDataToSend.append('name', formData.value.name)
  formDataToSend.append('parentId', formData.value.parentId || '')
  
  // Ajouter l'URL seulement si elle est fournie et qu'il n'y a pas de nouvelle image
  if (formData.value.url && !selectedFile.value) {
    formDataToSend.append('url', formData.value.url)
  }
  
  // Ajouter l'image si elle est sélectionnée
  if (selectedFile.value) {
    formDataToSend.append('image', selectedFile.value)
  } else {
  }

  router.post(url, formDataToSend, {
    onSuccess: () => {
      closeModal()
      router.reload()
    },
    onError: (errors) => {
    }
  })
}

const deleteCategory = (id: number) => {
  if (confirm('Êtes-vous sûr de vouloir supprimer cette catégorie ?')) {
    router.delete(`/dashboard/categories/delete/${id}`)
  }
}

const getCategoryImageUrl = (category: Category) => {
  // Si l'URL de la catégorie existe, l'utiliser
  if (category.url) {
    // Pour les fichiers locaux, s'assurer que l'URL est correcte
    if (category.url.startsWith('/uploads/')) {
      return category.url
    }
    // Pour les URLs externes, les remplacer par l'image par défaut locale
    if (category.url.startsWith('http')) {
      return '/uploads/categories/default-category.jpg'
    }
    // Sinon, considérer que c'est un chemin local
    return category.url.startsWith('/') ? category.url : '/' + category.url
  }
  // Sinon, utiliser une image par défaut locale
  return '/uploads/categories/default-category.jpg'
}

const handleImageError = (event: Event) => {
  const img = event.target as HTMLImageElement
  const fallback = '/uploads/categories/default-category.jpg'
  if (!img.src.endsWith(fallback)) {
    img.src = fallback
  }
}
</script>
