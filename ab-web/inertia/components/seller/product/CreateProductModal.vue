<script setup lang="ts">
import InputLabelAdmin from '~/components/admin/form/InputLabelAdmin.vue'
import InputDescription from '~/components/admin/form/InputDescription.vue'
import { ref } from 'vue'
import InputImageAdmin from '~/components/admin/form/InputImageAdmin.vue'
import { router } from '@inertiajs/vue3'
import ShowAddPopup from '~/components/admin/popup/showAddPopup.vue'
import { CTAType, ProductState } from '#dto/products_interface'
import { BrandsDto } from '#dto/brands_interface'
import InputFeature from '~/components/admin/form/InputFeature.vue'
import { CategoryDto } from '#dto/category_dto'
import { isValidImageFile } from '~/utils/imageUpload'

defineProps<{
  categories: CategoryDto[]
  brands: BrandsDto[]
}>()

const emit = defineEmits(['success', 'error', 'error-size'])
const showInit = ref<boolean>(false)

interface Form {
  name: string
  cta: CTAType
  categoryId: string
  state: ProductState
  brandId: string
  description: string
  price: number | null
  features: string[]
  video: string | null
  images: { file: File; type: 'image'; preview: string }[]
}

const form = ref<Form>({
  name: '',
  cta: CTAType.NONE,
  categoryId: '',
  state: ProductState.NEW,
  brandId: '',
  description: '',
  price: null,
  video: '',
  features: [],
  images: [],
})

const open = ref(false)

const submit = async () => {
  const formData = new FormData()
  
  // Add basic fields
  formData.append('name', form.value.name)
  formData.append('cta', form.value.cta)
  formData.append('categoryId', form.value.categoryId)
  formData.append('state', form.value.state)
  formData.append('brandId', form.value.brandId)
  formData.append('description', form.value.description)
  formData.append('price', (form.value.price || 0).toString())
  formData.append('video', form.value.video || '')
  
  // Add features
  form.value.features.forEach((feature, index) => {
    formData.append(`features[${index}]`, feature)
  })
  
  // Add images
  form.value.images.forEach((image, index) => {
    formData.append(`images[${index}]`, image.file)
  })

  try {
    await router.post('/seller/products/create', formData, {
      forceFormData: true,
      onSuccess: () => {
        emit('success')
        open.value = false
        resetForm()
      },
      onError: (errors) => {
        emit('error', errors)
      }
    })
  } catch (error) {
    emit('error', error)
  }
}

const resetForm = () => {
  form.value = {
    name: '',
    cta: CTAType.NONE,
    categoryId: '',
    state: ProductState.NEW,
    brandId: '',
    description: '',
    price: null,
    video: '',
    features: [],
    images: [],
  }
}

const closeModal = () => {
  open.value = false
  resetForm()
}

const addImage = (files: File[]): void => {
  files.forEach((image) => {
    if (!isValidImageFile(image)) {
      emit('error-size', image.name)
      return
    }
    const reader = new FileReader()
    reader.onload = (e) => {
      if (e.target?.result) {
        form.value.images.push({
          file: image,
          type: 'image',
          preview: e.target.result as string,
        })
      }
    }
    reader.readAsDataURL(image)
  })
}

const removeImage = (index: number): void => {
  form.value.images.splice(index, 1)
}
</script>

<template>
  <div>
    <!-- Button to open modal -->
    <button
      @click="open = true"
      class="bg-primary hover:bg-primary-dark text-white px-6 py-3 rounded-2xl font-bold shadow-lg shadow-primary/20 transition-all active:scale-95 flex items-center gap-2"
    >
      <div class="i-mdi-plus text-xl"></div>
      Ajouter un produit
    </button>

    <!-- Modal -->
    <div
      v-if="open"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50"
    >
      <div class="bg-white dark:bg-slate-900 rounded-[2rem] w-full max-w-4xl max-h-[90vh] overflow-y-auto shadow-2xl">
        <!-- Header -->
        <div class="p-8 border-b border-slate-200 dark:border-slate-800 flex items-center justify-between">
          <h3 class="text-2xl font-bold text-slate-800 dark:text-white">Ajouter un nouveau produit</h3>
          <button
            @click="closeModal"
            class="p-2 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-xl transition-colors"
          >
            <div class="i-mdi-close text-2xl text-slate-400"></div>
          </button>
        </div>

        <!-- Form -->
        <form @submit.prevent="submit" class="p-8 space-y-8">
          <!-- Basic Information -->
          <div class="space-y-6">
            <h4 class="text-lg font-semibold text-slate-800 dark:text-white">Informations de base</h4>
            
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
              <InputLabelAdmin
                v-model="form.name"
                label="Nom du produit"
                placeholder="Entrez le nom du produit"
                required
              />
              
              <InputLabelAdmin
                v-model="form.price"
                label="Prix (FCFA)"
                type="number"
                placeholder="0"
                required
              />
            </div>

            <InputDescription
              v-model="form.description"
              label="Description"
              placeholder="Décrivez votre produit en détail..."
              required
            />

            <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
              <div>
                <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-2">
                  Catégorie
                </label>
                <select
                  v-model="form.categoryId"
                  class="w-full px-4 py-3 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-800 dark:text-white focus:ring-2 focus:ring-primary focus:border-transparent"
                  required
                >
                  <option value="">Sélectionner une catégorie</option>
                  <option v-for="category in categories" :key="category.id" :value="category.id">
                    {{ category.name }}
                  </option>
                </select>
              </div>

              <div>
                <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-2">
                  Marque
                </label>
                <select
                  v-model="form.brandId"
                  class="w-full px-4 py-3 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-800 dark:text-white focus:ring-2 focus:ring-primary focus:border-transparent"
                >
                  <option value="">Sélectionner une marque</option>
                  <option v-for="brand in brands" :key="brand.id" :value="brand.id">
                    {{ brand.name }}
                  </option>
                </select>
              </div>

              <div>
                <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-2">
                  État
                </label>
                <select
                  v-model="form.state"
                  class="w-full px-4 py-3 rounded-xl border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-800 dark:text-white focus:ring-2 focus:ring-primary focus:border-transparent"
                  required
                >
                  <option :value="ProductState.NEW">Neuf</option>
                  <option :value="ProductState.USED">Occasion</option>
                  <option :value="ProductState.RECONDITIONED">Reconditionné</option>
                </select>
              </div>
            </div>
          </div>

          <!-- Images -->
          <div class="space-y-6">
            <h4 class="text-lg font-semibold text-slate-800 dark:text-white">Images</h4>
            <InputImageAdmin
              v-model:images="form.images"
              label="Photos du produit"
              placeholder=""
              :is-required="false"
              @select="(p) => addImage(p)"
              @drop="(p) => addImage(p)"
              @remove="(p) => removeImage(p)"
            />
          </div>

          <!-- Features -->
          <div class="space-y-6">
            <h4 class="text-lg font-semibold text-slate-800 dark:text-white">Caractéristiques</h4>
            <InputFeature
              v-model="form.features"
              label="Ajoutez les caractéristiques principales"
              placeholder="Ex: GPS, Bluetooth, Camera 48MP..."
            />
          </div>

          <!-- Video -->
          <div class="space-y-6">
            <h4 class="text-lg font-semibold text-slate-800 dark:text-white">Vidéo (optionnel)</h4>
            <InputLabelAdmin
              v-model="form.video"
              label="URL de la vidéo YouTube"
              placeholder="https://youtube.com/watch?v=..."
            />
          </div>

          <!-- Actions -->
          <div class="flex items-center justify-between pt-6 border-t border-slate-200 dark:border-slate-800">
            <button
              type="button"
              @click="closeModal"
              class="px-6 py-3 rounded-xl border border-slate-200 dark:border-slate-700 text-slate-700 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors font-medium"
            >
              Annuler
            </button>
            
            <div class="flex items-center gap-4">
              <button
                type="submit"
                class="bg-primary hover:bg-primary-dark text-white px-8 py-3 rounded-2xl font-bold shadow-lg shadow-primary/20 transition-all active:scale-95"
              >
                Créer le produit
              </button>
            </div>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;900&display=swap');

.font-sans {
  font-family: 'Inter', sans-serif;
}
</style>
