<script setup lang="ts">
defineProps<{
  label: string
  //images: Media[]
}>()

const images = defineModel<any[]>('images')

const emits = defineEmits(['remove'])

const removeImage = (index: number): void => {
  if (index >= 0) {
    emits('remove', index)
  }
}

// YouTube URL Helper
const getYouTubeEmbedUrl = (url: string) => {
  const videoId = url.split('v=')[1]
  return `https://www.youtube.com/embed/${videoId}`
}
</script>

<template>
  <div class="mb-6">
    <label class="block text-gray-300 text-sm font-bold mb-2"> {{ label }} </label>
    <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
      <!-- Existing image -->
      <div
        v-for="(image, index) in images"
        :key="index"
        class="relative aspect-square rounded-lg overflow-hidden group"
      >
        <img v-if="image.type === 'image'" :src="image.url" class="w-full h-full object-cover" />
        <div
          v-else-if="image.type === 'video'"
          class="w-full h-full bg-background-secondary flex items-center justify-center"
        >
          <iframe
            :src="getYouTubeEmbedUrl(image.url)"
            class="w-full h-full"
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
            allowfullscreen
          ></iframe>
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
    </div>
  </div>
</template>

<style scoped></style>
