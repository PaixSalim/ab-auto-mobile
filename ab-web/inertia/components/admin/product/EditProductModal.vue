<script setup lang="ts">
import InputLabelAdmin from '~/components/admin/form/InputLabelAdmin.vue'
import InputDescription from '~/components/admin/form/InputDescription.vue'
import { ref } from 'vue'
import AIGenerator from '~/components/admin/AIGenerator.vue'
import InputImageAdmin from '~/components/admin/form/InputImageAdmin.vue'
import { router } from '@inertiajs/vue3'
import ShowOldImageAdmin from '~/components/admin/form/ShowOldImageAdmin.vue'
import { CTAType, GetProductDto, MediaDto, ProductState } from '#dto/products_interface'
import { CategoryDto } from '#dto/category_dto'
import { BrandsDto } from '#dto/brands_interface'
import InputFeature from '~/components/admin/form/InputFeature.vue'
import { isValidImageFile } from '~/utils/imageUpload'

const props = defineProps<{
  categories: CategoryDto[]
  brands: BrandsDto[]
  productProp: GetProductDto
}>()
const emit = defineEmits(['success', 'error', 'error-size'])
const modalMode = ref('view')
const medias = ref<MediaDto[]>(props.productProp.medias)
interface Form {
  id: number
  name: string
  cta: CTAType
  state: ProductState
  categoryId: number | null
  brandId: number | null
  description: string
  features: string[]
  price: number | null
  video: string | null
  remove: number[]
  images: { file: File; type: 'image'; preview: string }[]
}


const form = ref<Form>({
  id: props.productProp.id,
  name: props.productProp.name || '',
  state: props.productProp.state,
  cta: props.productProp.cta || '',
  categoryId: props.productProp.category.id,
  brandId: props.productProp.brand.id,
  description: props.productProp.description,
  features: props.productProp.features,
  price: props.productProp.price,
  video: '',
  remove: [],
  images: [],
})

const open = ref(false)

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

const addFeature = () => {
  form.value.features.push('')
}

const removeFeature = (index: number) => {
  form.value.features.splice(index, 1)
}

const removeMediaOld = (index: number): void => {
  form.value.remove.push(medias.value[index].id)
  medias.value.splice(index, 1)
}
const handleSubmit = () => {
  const formData = new FormData()

  if(form.value.price =='') {
    form.value.price = 1
  }

  Object.keys(form.value).forEach((key) => {
    if (key !== 'images') {
      formData.append(
        key,
        typeof form.value[key] === 'object' ? JSON.stringify(form.value[key]) : form.value[key]
      )
    }
  })

  form.value.images.forEach((image, index) => {
    formData.append(`images[${index}]`, image.file)
    formData.append(`mediaTypes[${index}]`, image.type)
  })

  router.post('/dashboard/product/edit', formData, {
    forceFormData: true,
    preserveScroll: true,
    onSuccess: () => {
      emit('success', form.value.name)
    },
    onError: () => {
      emit('error', form.value.name)
    },
  })
}

const currentType = ref('')
const handleAiPopup = (type: string) => {
  currentType.value = type
  open.value = true
}

const closeAiModal = () => {
  open.value = false
}
const handleUpdateDescription = (content: string) => {
  form.value.description = content
}
</script>

<template>
  <form action="" @submit.prevent="handleSubmit" class="bg-background-admin shadow-lg p-8">
    <InputLabelAdmin
      v-model:name-model="form.name"
      id="name"
      label="Nom du produit"
      name="name"
      placeholder="Entrez le nom du produit"
      type="text"
      :required="true"
    />

    <div class="mb-6 grid grid-cols-2 gap-4">
      <InputLabelAdmin
        v-model:category-id="form.categoryId"
        id="category"
        label="Catégorie"
        name="category"
        placeholder="Entrez le nom du produit"
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

    <!--- -->
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

    <!-- Les anciens medias -->
    <ShowOldImageAdmin
      label="Les medias"
      v-model:images="medias"
      @remove="(p) => removeMediaOld(p)"
    />

    <!-- Les images -->
    <InputImageAdmin
      :is-required="false"
      label=""
      placeholder="Glisser déposer"
      v-model:images="form.images"
      @select="(p) => addImage(p)"
      @remove="(p) => removeImage(p)"
      @drop="(p) => addImage(p)"
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
      <button class="bg-primary px-3 py-2 rounded-lg hover:(bg-primary/60)" type="submit">
        {{ modalMode === 'create' ? 'Ajouter un produit' : 'Modifier un Produit' }}
      </button>
    </div>
  </form>

  <AIGenerator :type="currentType" :is-open="open" @close="closeAiModal" @content="handleUpdateDescription"/>
</template>

<style scoped>

</style>
