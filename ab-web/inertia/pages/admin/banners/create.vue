<template>
  <Layout>
    <div class="px-6 py-8">
      <div class="flex justify-between items-center mb-6">
        <h3 class="text-primary font-bold text-3xl">Créer une Bannière</h3>
        <Link
          href="/dashboard/banners"
          class="bg-gray-500 hover:bg-gray-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline flex items-center gap-2"
        >
          <span class="i-mdi-arrow-left text-xl"></span>
          Retour
        </Link>
      </div>

      <!-- Messages Flash -->
      <div v-if="$page.props.flash?.notification" class="mb-4 p-4 rounded" :class="{
        'bg-green-100 border border-green-400 text-green-700': $page.props.flash.notification.type === 'success',
        'bg-red-100 border border-red-400 text-red-700': $page.props.flash.notification.type === 'error'
      }">
        {{ $page.props.flash.notification.message }}
      </div>

      <div class="bg-white shadow-md rounded-lg p-6">
        <form @submit.prevent="submitForm" enctype="multipart/form-data">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <!-- Titre -->
            <div class="col-span-2">
              <label class="block text-gray-700 text-sm font-bold mb-2" for="title">
                Titre <span class="text-red-500">*</span>
              </label>
              <input
                v-model="form.title"
                class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
                id="title"
                type="text"
                placeholder="Entrez le titre de la bannière"
                required
              />
            </div>

            <!-- Description -->
            <div class="col-span-2">
              <label class="block text-gray-700 text-sm font-bold mb-2" for="description">
                Description <span class="text-red-500">*</span>
              </label>
              <textarea
                v-model="form.description"
                class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
                id="description"
                rows="3"
                placeholder="Entrez la description de la bannière"
                required
              ></textarea>
            </div>

            <!-- Lien -->
            <div>
              <label class="block text-gray-700 text-sm font-bold mb-2" for="link">
                Lien
              </label>
              <input
                v-model="form.link"
                class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
                id="link"
                type="text"
                placeholder="Entrez le lien (optionnel)"
              />
            </div>

            <!-- Image -->
            <div>
              <label class="block text-gray-700 text-sm font-bold mb-2" for="image">
                Image
              </label>
              <input
                @change="handleImageChange"
                class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
                id="image"
                type="file"
                accept="image/*"
              />
              <p class="text-gray-600 text-xs mt-1">
                Formats acceptés: JPG, JPEG, PNG, GIF (max 5MB)
              </p>
            </div>
          </div>

          <!-- Aperçu de l'image -->
          <div v-if="imagePreview" class="mt-6">
            <label class="block text-gray-700 text-sm font-bold mb-2">Aperçu de l'image</label>
            <img :src="imagePreview" alt="Aperçu" class="max-w-full h-48 object-cover rounded border" />
          </div>

          <div class="mt-8 flex justify-end gap-4">
            <Link
              href="/dashboard/banners"
              class="bg-gray-500 hover:bg-gray-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
            >
              Annuler
            </Link>
            <button
              type="submit"
              :disabled="isSubmitting"
              class="bg-blue-500 hover:bg-blue-700 disabled:bg-blue-300 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline flex items-center gap-2"
            >
              <span v-if="isSubmitting" class="i-mdi-loading animate-spin"></span>
              <span v-else class="i-mdi-plus"></span>
              {{ isSubmitting ? 'Création...' : 'Créer' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </Layout>
</template>

<script setup lang="ts">
import { Link, router, usePage } from '@inertiajs/vue3'
import { ref, reactive } from 'vue'

const page = usePage()
const isSubmitting = ref(false)
const imagePreview = ref<string | null>(null)

const form = reactive({
  title: '',
  description: '',
  link: '',
  image: null as File | null
})

const handleImageChange = (event: Event) => {
  const target = event.target as HTMLInputElement
  if (target.files && target.files[0]) {
    form.image = target.files[0]
    const reader = new FileReader()
    reader.onload = (e) => {
      imagePreview.value = e.target?.result as string
    }
    reader.readAsDataURL(form.image)
  }
}

const submitForm = () => {
  isSubmitting.value = true
  
  const formData = new FormData()
  formData.append('title', form.title)
  formData.append('description', form.description)
  formData.append('link', form.link)
  if (form.image) {
    formData.append('image', form.image)
  }

  router.post('/dashboard/banners/create', formData, {
    onSuccess: () => {
      isSubmitting.value = false
    },
    onError: (errors) => {
      isSubmitting.value = false
    },
    onFinish: () => {
      isSubmitting.value = false
    }
  })
}
</script>
