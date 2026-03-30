<template>
  <Layout title="Gestion des Marques">
    <div class="px-6 py-8">
      <div class="flex justify-between items-center mb-8">
        <div>
          <h3 class="text-title font-bold text-3xl mb-1">Gestion des Marques</h3>
          <p class="text-description text-sm">Gérez les marques de produits disponibles sur la plateforme</p>
        </div>
        <button
          @click="openCreateModal"
          class="bg-primary hover:bg-primary-dark text-white font-bold py-2.5 px-6 rounded-xl shadow-lg shadow-primary/20 transition-all flex items-center gap-2 group"
        >
          <div class="i-mdi-plus text-xl group-hover:scale-110 transition-transform"></div>
          Ajouter une marque
        </button>
      </div>

      <PaginatedList
        :items="brands"
        :headers="brandHeaders"
        :items-per-page="10"
        item-name="marques"
        empty-message="Aucune marque trouvée."
      >
        <template #cell-name="{ item }">
          <div class="font-bold text-title">{{ item.name }}</div>
        </template>
        
        <template #cell-image="{ item }">
          <div class="py-1">
            <img 
              :src="getBrandImageUrl(item)" 
              :alt="item.name"
              class="w-12 h-12 rounded-xl object-cover border border-slate-700/50 bg-slate-800"
              @error="handleImageError"
            />
          </div>
        </template>

        <template #cell-category="{ item }">
          <div class="text-xs font-bold text-description italic">
            {{ item.category?.name || 'Non spécifiée' }}
          </div>
        </template>

        <template #cell-productsCount="{ item }">
          <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-primary/10 text-primary border border-primary/20">
            {{ item._count?.products || 0 }} produit(s)
          </span>
        </template>

        <template #cell-actions="{ item }">
          <div class="flex items-center gap-4">
            <button
              @click="editBrand(item)"
              class="text-blue-400 hover:text-blue-300 flex items-center gap-1.5 transition-colors group"
              title="Modifier"
            >
              <div class="i-mdi-pencil text-lg group-hover:scale-110 transition-transform"></div>
              <span class="text-xs font-bold uppercase tracking-wider">Modifier</span>
            </button>
            <button
              @click="deleteBrand(item.id)"
              class="text-red-400 hover:text-red-300 flex items-center gap-1.5 transition-colors group"
              title="Supprimer"
            >
              <div class="i-mdi-delete text-lg group-hover:scale-110 transition-transform"></div>
              <span class="text-xs font-bold uppercase tracking-wider">Supprimer</span>
            </button>
          </div>
        </template>
      </PaginatedList>

      <!-- Modal Créer/Modifier Marque -->
      <div v-if="showCreateModal" class="fixed inset-0 bg-slate-950/80 backdrop-blur-sm flex items-center justify-center z-50 p-4">
        <div class="bg-background-secondary border border-slate-800 rounded-2xl shadow-2xl w-full max-w-md overflow-hidden transform transition-all">
          <div class="p-6 border-b border-slate-800 flex justify-between items-center bg-slate-900/50">
            <h2 class="text-xl font-bold text-title">{{ editingBrand ? 'Modifier' : 'Créer' }} une marque</h2>
            <button @click="closeModal" class="text-slate-400 hover:text-white transition-colors">
              <div class="i-mdi-close text-2xl"></div>
            </button>
          </div>
          
          <form @submit.prevent="submitBrand" class="p-6 space-y-5">
            <!-- Nom -->
            <div>
              <label class="block text-sm font-bold text-description uppercase tracking-widest mb-2">Nom de la marque *</label>
              <input
                v-model="formData.name"
                type="text"
                class="w-full bg-slate-950 border border-slate-800 rounded-xl px-4 py-3 text-title focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all placeholder:text-slate-600"
                placeholder="Ex: Toyota, Samsung..."
                required
              />
            </div>

            <!-- Upload Image -->
            <div>
              <label class="block text-sm font-bold text-description uppercase tracking-widest mb-2">Logo de la marque</label>
              <div class="space-y-3">
                <!-- Preview -->
                <div v-if="(formData.url && !formData.url.startsWith('http')) || selectedFile" class="flex items-center gap-3 p-3 bg-slate-950 rounded-xl border border-slate-800">
                  <img 
                    :src="previewUrl || formData.url" 
                    :alt="formData.name"
                    class="w-14 h-14 rounded-lg object-cover border border-slate-800 bg-slate-900"
                  />
                  <div class="flex-1 min-w-0">
                    <p class="text-sm font-medium text-title truncate">{{ selectedFile ? selectedFile.name : 'Logo actuel' }}</p>
                    <button 
                      v-if="selectedFile"
                      type="button"
                      @click="removeSelectedFile"
                      class="text-xs text-red-400 hover:text-red-300 transition-colors mt-1 font-bold uppercase tracking-wider"
                    >
                      Supprimer
                    </button>
                  </div>
                </div>
                
                <!-- File Input -->
                <div class="relative group">
                  <input
                    type="file"
                    accept="image/*"
                    @change="handleFileChange"
                    class="absolute inset-0 w-full h-full opacity-0 cursor-pointer z-10"
                  />
                  <div class="border-2 border-dashed border-slate-700 group-hover:border-primary/50 group-hover:bg-primary/5 rounded-xl p-5 transition-all text-center">
                    <div class="i-mdi-cloud-upload text-3xl text-slate-500 group-hover:text-primary mx-auto mb-2"></div>
                    <p class="text-sm text-slate-400 font-medium">Cliquez ou glissez un logo ici</p>
                    <p class="text-[10px] text-slate-500 mt-1 uppercase font-bold tracking-wider">JPG, PNG, WebP • Max 5MB</p>
                  </div>
                </div>
              </div>
            </div>

            <!-- Catégorie -->
            <div>
              <label class="block text-sm font-bold text-description uppercase tracking-widest mb-2">Catégorie *</label>
              <div class="relative">
                <select
                  v-model="formData.categoryId"
                  class="w-full bg-slate-950 border border-slate-800 rounded-xl px-4 py-3 text-title focus:outline-none focus:ring-2 focus:ring-primary appearance-none cursor-pointer"
                  required
                >
                  <option value="" disabled>Sélectionner une catégorie</option>
                  <option v-for="cat in categories" :key="cat.id" :value="cat.id.toString()">
                    {{ cat.name }}
                  </option>
                </select>
                <div class="i-mdi-chevron-down absolute right-4 top-1/2 -translate-y-1/2 text-slate-600 pointer-events-none"></div>
              </div>
              <p v-if="!formData.categoryId" class="mt-1.5 text-xs text-red-400 flex items-center gap-1">
                <span class="i-mdi-alert-circle"></span>
                Sélectionnez une catégorie pour continuer
              </p>
            </div>

            <div class="flex gap-3 pt-6 border-t border-slate-800">
              <button
                type="button"
                @click="closeModal"
                class="flex-1 bg-slate-800 text-title px-6 py-3.5 rounded-xl hover:bg-slate-700 transition-all font-bold uppercase tracking-wider text-sm"
              >
                Annuler
              </button>
              <button
                type="submit"
                :disabled="!formData.name || !formData.categoryId"
                class="flex-1 bg-gradient-to-r from-primary to-primary-dark text-white px-6 py-3.5 rounded-xl hover:from-primary hover:to-primary-dark transition-all font-bold uppercase tracking-wider text-sm shadow-lg shadow-primary/30 disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
              >
                <span v-if="!editingBrand" class="i-mdi-plus"></span>
                {{ editingBrand ? 'Enregistrer' : 'Créer la marque' }}
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
import Layout from '~/components/admin/Layout.vue'
import PaginatedList from '~/components/admin/PaginatedList.vue'

interface Brand {
  id: number
  name: string
  url: string
  _count?: {
    products: number
  }
}

const props = defineProps<{
  brands: Brand[]
  categories?: any[]
}>()

const brandHeaders = [
  { key: 'image', label: 'Aperçu' },
  { key: 'name', label: 'Nom' },
  { key: 'category', label: 'Famille' },
  { key: 'productsCount', label: 'Produits' },
  { key: 'actions', label: 'Actions', cellClass: 'text-right' }
]

const showCreateModal = ref(false)
const editingBrand = ref<Brand | null>(null)
const selectedFile = ref<File | null>(null)
const previewUrl = ref<string>('')
const formData = ref({
  name: '',
  url: '',
  categoryId: ''
})

const openCreateModal = () => {
  editingBrand.value = null
  formData.value = { name: '', url: '', categoryId: '' }
  selectedFile.value = null
  previewUrl.value = ''
  showCreateModal.value = true
}

const editBrand = (brand: any) => {
  editingBrand.value = brand
  formData.value = {
    name: brand.name,
    url: brand.url || '',
    categoryId: brand.categoryId?.toString() || ''
  }
  selectedFile.value = null
  previewUrl.value = ''
  showCreateModal.value = true
}

const closeModal = () => {
  showCreateModal.value = false
  editingBrand.value = null
  formData.value = { name: '', url: '', categoryId: '' }
  selectedFile.value = null
  previewUrl.value = ''
}

const handleFileChange = (event: Event) => {
  const target = event.target as HTMLInputElement
  const file = target.files?.[0]
  
  if (file) {
    if (file.size > 5 * 1024 * 1024) {
      alert('L\'image ne doit pas dépasser 5MB')
      target.value = ''
      return
    }
    
    if (!file.type.startsWith('image/')) {
      alert('Veuillez sélectionner une image valide')
      target.value = ''
      return
    }
    
    selectedFile.value = file
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
  const fileInput = document.querySelector('input[type="file"]') as HTMLInputElement
  if (fileInput) fileInput.value = ''
}

const submitBrand = () => {
  const url = editingBrand.value 
    ? `/dashboard/brands/edit/${editingBrand.value.id}`
    : '/dashboard/brands/create'

  // Utiliser FormData pour envoyer l'image
  const formDataToSend = new FormData()
  formDataToSend.append('name', formData.value.name)
  formDataToSend.append('categoryId', formData.value.categoryId)
  
  if (formData.value.url && !selectedFile.value) {
    formDataToSend.append('url', formData.value.url)
  }
  
  if (selectedFile.value) {
    formDataToSend.append('image', selectedFile.value)
  }

  // Utiliser fetch avec gestion de la redirection Inertia
  fetch(url, {
    method: 'POST',
    body: formDataToSend
  })
  .then(response => {
    // Le backend fait une redirection, donc on vérifie si c'est un succès
    if (response.ok || response.redirected) {
      closeModal()
      // Recharger la page pour afficher les données mises à jour
      window.location.href = '/dashboard/brands'
    } else {
      return response.text().then(errorText => {
        alert('Erreur lors de la création de la marque: ' + errorText)
      })
    }
  })
  .catch(error => {
    console.error('Erreur réseau:', error)
    alert('Erreur réseau lors de la création de la marque')
  })
}

const deleteBrand = (id: number) => {
  if (confirm('Êtes-vous sûr de vouloir supprimer cette marque ? Cette action est irréversible.')) {
    fetch(`/dashboard/brands/delete/${id}`, {
      method: 'DELETE'
    })
    .then(response => {
      if (response.ok || response.redirected) {
        // Recharger la page pour afficher les données mises à jour
        window.location.href = '/dashboard/brands'
      } else {
        alert('Erreur lors de la suppression de la marque')
      }
    })
    .catch(error => {
      console.error('Erreur réseau:', error)
      alert('Erreur réseau lors de la suppression de la marque')
    })
  }
}

const getBrandImageUrl = (brand: Brand) => {
  if (brand.url) {
    if (brand.url.startsWith('/uploads/')) return brand.url
    if (brand.url.startsWith('http')) return brand.url
    return brand.url.startsWith('/') ? brand.url : '/' + brand.url
  }
  return '/uploads/brands/default-brand.jpg'
}

const handleImageError = (event: Event) => {
  const img = event.target as HTMLImageElement
  img.src = '/uploads/brands/default-brand.jpg'
}
</script>
