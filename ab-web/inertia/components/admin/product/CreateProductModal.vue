<script setup lang="ts">
import InputLabelAdmin from '~/components/admin/form/InputLabelAdmin.vue'
import InputDescription from '~/components/admin/form/InputDescription.vue'
import { ref } from 'vue'
import AIGenerator from '~/components/admin/AIGenerator.vue'
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
const currentType = ref('')
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
const handleAiPopup = (type: string) => {
  currentType.value = type
  open.value = true
}
const addFeature = () => {
  form.value.features.push('')
}

const removeFeature = (index: number) => {
  form.value.features.splice(index, 1)
}
const closeAiModal = () => {
  open.value = false
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

const handleUpdateDescription = (content: string) => {
  form.value.description = content
}

const handleUpdateFeatures = (features: string[]) => {
  for (const feature of features) {
    form.value.features.push(feature)
  }
}

const removeImage = (index: number): void => {
  form.value.images.splice(index, 1)
}
const handleSubmit = () => {
  const formData = new FormData()

  if(form.value.price === null) {
    form.value.price = 1
  }

  Object.keys(form.value).forEach((key) => {
    if (key !== 'images') {
      const formKey = key as keyof Form
      const value = form.value[formKey]
      formData.append(
        key,
        typeof value === 'object' ? JSON.stringify(value) : String(value)
      )
    }
  })
  //formData.append('img', form.value.images[0].preview)

  // Append images files

  form.value.images.forEach((image, index) => {
    formData.append(`images[${index}]`, image.file)
    formData.append(`mediaTypes[${index}]`, image.type)
  })

  router.post('/dashboard/product/create', formData, {
    forceFormData: true,
    preserveScroll: true,
    onSuccess: () => {
      emit('success', form.value.name)
      form.value = {
        name: '',
        brandId: '',
        cta: CTAType.NONE,
        state: ProductState.NEW,
        categoryId: '',
        description: '',
        video: '',
        price: null,
        features: [],
        images: [],
      }
    },
    onError: () => {
      emit('error', form.value.name)
    },
    onFinish: () => {},
  })
}
</script>

<template>
  <form action="" @submit.prevent="handleSubmit" class="bg-background-admin shadow-lg p-8">
    <!--- Le nom du produit-->
    <InputLabelAdmin
      v-model:name-model="form.name"
      id="name"
      label="Nom du produit"
      name="name"
      placeholder="Entrez le nom du produit"
      type="text"
      :required="false"
    />

    <div class="mb-6 grid grid-cols-2 gap-4">
      <!--- La category du produit-->
      <InputLabelAdmin
        v-model:category-id="form.categoryId"
        id="category"
        label="Catégorie"
        name="category"
        placeholder="Selectionner la categorie"
        type="select"
        :categories="categories"
        :required="false"
      />
      <InputLabelAdmin
        v-model:category-id="form.brandId"
        id="brand"
        label="Marque"
        name="brand"
        placeholder=""
        type="select"
        :brands="brands"
        :required="false"
      />
    </div>

    <!--- Le CTA -->
    <InputLabelAdmin
      v-model:cta-model="form.cta"
      cta="cta"
      id="cta"
      label="Call to action"
      name="cta"
      placeholder="Selectionner"
      type="select"
      :required="false"
    />

    <InputDescription
      v-model:description="form.description"
      id="description"
      label="Description du produit"
      placeholder="Entrez la description du produit ou laisser UBot la générer pour vous"
      @open="handleAiPopup('description')"
    />

    <!-- Les features -->
    <InputFeature
      v-model:features="form.features"
      label="Propriétés"
      @add="addFeature"
      @remove="removeFeature"
      @open="handleAiPopup('features')"
    />

    <div class="mb-6 grid grid-cols-2 gap-4">
    <!--- Le prix du produit-->
    <InputLabelAdmin
      v-model:name-model="form.price"
      id="price"
      label="Prix de Vente"
      name="price"
      placeholder="Prix du produit"
      type="number"
      :required="false"
    />

      <InputLabelAdmin
        v-model:category-id="form.state"
        id="state"
        label="Etat du produit"
        name="state"
        placeholder=""
        type="select"
        :state="['new', 'old']"
        :required="false"
      />
    </div>
    <!-- Les images -->
    <InputImageAdmin
      label="Images"
      placeholder="Glisser déposer"
      v-model:images="form.images"
      @select="(p) => addImage(p)"
      @remove="(p) => removeImage(p)"
      @drop="(p) => addImage(p)"
      :is-required="false"
    />

    <!--- Le lien de la vidéo-->
    <InputLabelAdmin
      v-model:name-model="form.video"
      id="video"
      label="Vidéo"
      name="video"
      placeholder="Entrez le lien youtube"
      type="text"
    />

    <!-- Submit Button -->
    <div class="flex justify-end">
      <button type="submit" class="bg-primary px-3 py-2 rounded-lg hover:(bg-primary/60)">Ajouter un produit</button>
    </div>
  </form>

  <AIGenerator
    :type="currentType"
    :is-open="open"
    @close="closeAiModal"
    @content="handleUpdateDescription"
    @features="handleUpdateFeatures"
  />

  <showAddPopup :show="showInit" :message="''" :title="''" />
</template>

<style scoped>

</style>
