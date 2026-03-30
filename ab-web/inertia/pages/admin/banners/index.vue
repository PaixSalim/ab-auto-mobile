<template>
  <Layout>
    <div class="px-6 py-8">
      <div class="flex justify-between items-center mb-6">
        <h3 class="text-primary font-bold text-3xl">Gestion des Bannières</h3>
        <button
          @click="openCreateModal"
          class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline flex items-center gap-2"
        >
          <span class="i-mdi-plus text-xl"></span>
          Ajouter une bannière
        </button>
      </div>

      <!-- Messages Flash -->
      <div v-if="flash?.notification" class="mb-4 p-4 rounded" :class="{
        'bg-green-100 border border-green-400 text-green-700': flash.notification.type === 'success',
        'bg-red-100 border border-red-400 text-red-700': flash.notification.type === 'error'
      }">
        {{ flash.notification.message }}
      </div>

      <div class="bg-white shadow-md rounded my-6">
        <table class="min-w-full leading-normal">
          <thead>
            <tr>
              <th class="px-5 py-3 border-b-2 border-gray-200 bg-gray-100 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                Titre
              </th>
              <th class="px-5 py-3 border-b-2 border-gray-200 bg-gray-100 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                Description
              </th>
              <th class="px-5 py-3 border-b-2 border-gray-200 bg-gray-100 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                Image
              </th>
              <th class="px-5 py-3 border-b-2 border-gray-200 bg-gray-100 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                Lien
              </th>
              <th class="px-5 py-3 border-b-2 border-gray-200 bg-gray-100 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                Date de création
              </th>
              <th class="px-5 py-3 border-b-2 border-gray-200 bg-gray-100 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                Actions
              </th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="banner in banners" :key="banner.id" class="hover:bg-gray-50">
              <td class="px-5 py-5 border-b border-gray-200 bg-white text-sm font-bold text-gray-800">
                {{ banner.title }}
              </td>
              <td class="px-5 py-5 border-b border-gray-200 bg-white text-sm text-gray-600">
                {{ banner.description.substring(0, 100) }}{{ banner.description.length > 100 ? '...' : '' }}
              </td>
              <td class="px-5 py-5 border-b border-gray-200 bg-white text-sm">
                <div class="flex items-center gap-3">
                  <img 
                    :src="getBannerImageUrl(banner)" 
                    :alt="banner.title"
                    class="w-16 h-12 object-cover rounded border border-gray-200"
                    @error="handleImageError"
                  />
                  <span class="text-xs text-gray-500">{{ getFileName(banner.image) }}</span>
                </div>
              </td>
              <td class="px-5 py-5 border-b border-gray-200 bg-white text-sm">
                <a 
                  v-if="banner.link && banner.link !== '#'" 
                  :href="banner.link" 
                  target="_blank"
                  class="text-blue-600 hover:text-blue-800 underline"
                >
                  {{ banner.link }}
                </a>
                <span v-else class="text-gray-400">Aucun</span>
              </td>
              <td class="px-5 py-5 border-b border-gray-200 bg-white text-sm text-gray-600">
                {{ formatDate(banner.createdAt) }}
              </td>
              <td class="px-5 py-5 border-b border-gray-200 bg-white text-sm">
                <div class="flex items-center gap-2">
                  <button
                    @click="openEditModal(banner)"
                    class="bg-yellow-500 hover:bg-yellow-700 text-white font-bold py-1 px-3 rounded text-sm flex items-center gap-1"
                  >
                    <span class="i-mdi-pencil text-sm"></span>
                    Modifier
                  </button>
                  <button
                    @click="deleteBanner(banner)"
                    class="bg-red-500 hover:bg-red-700 text-white font-bold py-1 px-3 rounded text-sm flex items-center gap-1"
                  >
                    <span class="i-mdi-delete text-sm"></span>
                    Supprimer
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>

        <div v-if="!banners || banners.length === 0" class="text-center py-8 text-gray-500">
          Aucune bannière trouvée
        </div>
      </div>
    </div>

    <!-- Modal de création/édition -->
    <div v-if="showModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        <h3 class="text-xl font-bold mb-4">
          {{ editingBanner ? 'Modifier la bannière' : 'Ajouter une bannière' }}
        </h3>
        
        <form @submit.prevent="submitBanner">
          <div class="mb-4">
            <label class="block text-gray-700 text-sm font-bold mb-2" for="title">
              Titre *
            </label>
            <input
              id="title"
              v-model="formData.title"
              type="text"
              class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
              required
            />
          </div>

          <div class="mb-4">
            <label class="block text-gray-700 text-sm font-bold mb-2" for="description">
              Description *
            </label>
            <textarea
              id="description"
              v-model="formData.description"
              class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline h-32"
              required
            ></textarea>
          </div>

          <div class="mb-4">
            <label class="block text-gray-700 text-sm font-bold mb-2" for="link">
              Lien
            </label>
            <input
              id="link"
              v-model="formData.link"
              type="url"
              placeholder="https://example.com"
              class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
            />
          </div>

          <div class="mb-4">
            <label class="block text-gray-700 text-sm font-bold mb-2" for="image">
              Image
            </label>
            <input
              id="image"
              type="file"
              @change="handleFileChange"
              accept="image/*"
              class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
            />
            <p class="text-xs text-gray-500 mt-1">
              Formats acceptés: JPG, JPEG, PNG, GIF (max 5MB)
            </p>
          </div>

          <!-- Aperçu de l'image -->
          <div v-if="imagePreview || (editingBanner && editingBanner.image)" class="mb-4">
            <label class="block text-gray-700 text-sm font-bold mb-2">
              Aperçu
            </label>
            <img 
              :src="imagePreview || getBannerImageUrl(editingBanner)" 
              alt="Aperçu"
              class="w-full h-48 object-cover rounded border border-gray-200"
            />
          </div>

          <div class="flex justify-end gap-2">
            <button
              type="button"
              @click="closeModal"
              class="bg-gray-500 hover:bg-gray-700 text-white font-bold py-2 px-4 rounded"
            >
              Annuler
            </button>
            <button
              type="submit"
              class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
            >
              {{ editingBanner ? 'Modifier' : 'Créer' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </Layout>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { router, usePage } from '@inertiajs/vue3'
import Layout from '../../../components/admin/Layout.vue'

const props = defineProps<{
  banners: any[]
  auth?: any
  flash?: any
}>()

const showNotification = ref(false)
const notificationMessage = ref('')
const notificationType = ref<'success' | 'error'>('success')

// Variables pour les modals
const showModal = ref(false)
const editingBanner = ref<any>(null)
const selectedFile = ref<File | null>(null)
const imagePreview = ref<string | null>(null)

const formData = ref({
  title: '',
  description: '',
  link: '',
  image: ''
})

const openCreateModal = () => {
  editingBanner.value = null
  selectedFile.value = null
  imagePreview.value = null
  formData.value = {
    title: '',
    description: '',
    link: '',
    image: ''
  }
  showModal.value = true
}

const openEditModal = (banner: any) => {
  editingBanner.value = banner
  selectedFile.value = null
  imagePreview.value = null
  formData.value = {
    title: banner.title,
    description: banner.description,
    link: banner.link,
    image: banner.image
  }
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  editingBanner.value = null
  selectedFile.value = null
  imagePreview.value = null
}

const handleFileChange = (event: Event) => {
  const target = event.target as HTMLInputElement
  const file = target.files?.[0]
  
  if (file) {
    selectedFile.value = file
    
    // Créer un aperçu
    const reader = new FileReader()
    reader.onload = (e) => {
      imagePreview.value = e.target?.result as string
    }
    reader.readAsDataURL(file)
  }
}

const submitBanner = () => {
  const url = editingBanner.value 
    ? `/dashboard/banners/edit/${editingBanner.value.id}`
    : '/dashboard/banners/create'

  // Utiliser FormData pour envoyer l'image
  const formDataToSend = new FormData()
  formDataToSend.append('title', formData.value.title)
  formDataToSend.append('description', formData.value.description)
  formDataToSend.append('link', formData.value.link)
  
  if (selectedFile.value) {
    formDataToSend.append('image', selectedFile.value)
  }

  fetch(url, {
    method: 'POST',
    body: formDataToSend,
    headers: {
      'Accept': 'application/json',
    }
  })
  .then(response => {
    if (response.ok) {
      closeModal()
      router.visit('/dashboard/banners')
    } else {
      return response.text().then(errorText => {
        alert('Erreur lors de la création/modification de la bannière: ' + errorText)
      })
    }
  })
  .catch(error => {
    alert('Erreur réseau lors de la création/modification de la bannière')
  })
}

const deleteBanner = (banner: any) => {
  if (confirm(`Êtes-vous sûr de vouloir supprimer la bannière "${banner.title}" ?`)) {
    fetch(`/dashboard/banners/delete/${banner.id}`, {
      method: 'POST',
      headers: {
        'Accept': 'application/json',
      }
    })
    .then(response => {
      if (response.ok) {
        router.visit('/dashboard/banners')
      } else {
        alert('Erreur lors de la suppression de la bannière')
      }
    })
    .catch(error => {
      alert('Erreur réseau lors de la suppression de la bannière')
    })
  }
}

const getBannerImageUrl = (banner: any) => {
  // Les URLs sont déjà formatées par le controller, donc on retourne directement l'image
  return banner.image || '/uploads/banners/default-banner.jpg'
}

const getFileName = (path: string) => {
  if (!path) return 'default-banner.jpg'
  return path.split('/').pop() || 'default-banner.jpg'
}

const formatDate = (dateString: string) => {
  const date = new Date(dateString)
  return date.toLocaleDateString('fr-FR', {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const handleImageError = (event: any) => {
  event.target.src = '/uploads/banners/default-banner.jpg'
}

onMounted(() => {
  // Afficher les notifications flash
  if (props.flash?.success) {
    showNotification.value = true
    notificationMessage.value = props.flash.success
    notificationType.value = 'success'
    setTimeout(() => {
      showNotification.value = false
    }, 3000)
  }
})
</script>
