<script setup lang="ts">
defineProps<{
  label: string
  placeholder: string
  isRequired: boolean
}>()

const images = defineModel<{ file: File; type: 'image' | 'video'; preview: string }[]>('images')

const emits = defineEmits(['select', 'remove', 'drop'])

const handleFileSelect = (event: Event): void => {
  const target = event.target as HTMLInputElement
  if (target.files) {
    const images = Array.from(target.files)
    emits('select', images)
  }
}

const handleDrop = (event: DragEvent): void => {
  const images = Array.from(event.dataTransfer?.files || [])
  emits('drop', images)
}

const removeImage = (index: number): void => {
  if (index >= 0) {
    emits('remove', index)
  }
}
</script>

<template>
  <div class="mb-6">
    <label class="block text-gray-300 text-sm font-bold mb-2"> {{ label }} </label>
    <div class="grid grid-cols-2 md:grid-cols-4 gap-4" @dragover.prevent @drop.prevent="handleDrop">
      <!-- Existing image -->
      <div
        v-for="(image, index) in images"
        :key="index"
        class="relative aspect-square rounded-lg overflow-hidden group"
      >
        <img
          v-if="image.type === 'image'"
          :src="image.preview"
          class="w-full h-full object-cover"
        />
        <div
          v-else-if="image.type === 'video'"
          class="w-full h-full bg-background-secondary flex items-center justify-center"
        >
          <div class="i-mdi-play text-primary text-3xl"></div>
        </div>
        <div
          class="absolute inset-0 bg-black bg-opacity-50 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center"
        >
          <button
            @click="removeImage(index)"
            type="button"
            class="text-white hover:text-red-500 transition-colors"
          >
            <div class="i-mdi-delete text-2xl"></div>
          </button>
        </div>
      </div>

      <!-- Upload Button -->
      <label
        class="aspect-square rounded-lg border-2 border-dashed border-gray-600 hover:border-primary transition-colors flex flex-col items-center justify-center cursor-pointer bg-background-secondary hover:bg-#343541"
      >
        <div class="i-mdi-cloud-upload text-primary text-3xl mb-2"></div>
        <span class="text-gray-300 text-center text-sm">Déposer ou cliquez pour ajouter</span>
        <input
          type="file"
          multiple
          accept=".jpg,.jpeg,.png,.gif,.webp,image/jpeg,image/png,image/gif,image/webp"
          class="hidden"
          @change="handleFileSelect"
          :required="isRequired"
        />
      </label>
    </div>
  </div>
</template>

<style scoped></style>
