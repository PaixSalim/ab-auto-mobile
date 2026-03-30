<script setup lang="ts">
defineProps<{
  label: string
  id: string
  placeholder: string
}>()

defineEmits<{
  open: string
}>()

const description = defineModel('description', {})
</script>

<template>
  <div class="mb-6">
    <div class="flex justify-between items-center mb-2">
      <label class="text-gray-300 text-sm font-bold" for="description"> {{ label }} </label>
      <button
        type="button"
        @click="$emit('open')"
        class="text-primary hover:text-white transition-colors"
      >
        <div class="i-mdi-robot text-xl"></div>
      </button>
    </div>
    <textarea
      v-model="description"
      class="w-full bg-background-secondary text-white rounded-lg p-3 mt-2 focus:outline-none focus:ring-2 focus:ring-#ff4d00"
      :id="id"
      :placeholder="placeholder"
      rows="4"
      required
    ></textarea>
  </div>
</template>

<style scoped></style>
