<script setup lang="ts">
defineProps<{
  label: string
}>()

const emits = defineEmits(['open', 'remove', 'add'])
const handleOpen = () => {
  emits('open')
}

const removeFeature = (index: number) => {
  emits('remove', index)
}
const addFeature = () => {
  emits('add')
}

const features = defineModel<string[]>('features')
</script>

<template>
  <!-- Features Field -->
  <div class="mb-6">
    <div class="flex justify-between items-center mb-2">
      <label class="text-gray-300 text-sm font-bold"> {{ label }}</label>
      <button
        type="button"
        @click="handleOpen"
        class="text-primary hover:text-white transition-colors"
      >
        <div class="i-mdi-robot text-xl"></div>
      </button>
    </div>
    <div class="space-y-2">
      <div v-for="(feature, index) in features" :key="index" class="flex gap-2">
        <input
          v-model="features![index]"
          class="flex-1 bg-background-secondary text-white rounded-lg p-3 focus:outline-none focus:ring-2 focus:ring-primary"
          type="text"
          :placeholder="`Propriété ${index + 1}`"
        />
        <button
          @click="removeFeature(index)"
          type="button"
          class="hover:bg-primary text-white p-3 rounded-lg transition-colors"
        >
          <div class="i-mdi-delete text-lg"></div>
        </button>
      </div>
      <button
        @click="addFeature"
        type="button"
        class="w-full bg-background-secondary border-2 border-background-secondary text-primary p-3 rounded-lg hover:bg-#343541 transition-colors"
      >
        Ajouter une propriété
      </button>
    </div>
  </div>
</template>

<style scoped></style>
