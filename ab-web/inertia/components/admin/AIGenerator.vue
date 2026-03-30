<template>
  <div
    v-if="isOpen"
    class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-6 z-50"
  >
    <div class="bg-#232430 rounded-lg p-6 max-w-lg w-full space-y-4">
      <div class="flex justify-between items-center">
        <h3 class="text-xl font-bold text-white">Générateur de {{ type }}</h3>
        <button @click="close" class="text-gray-400 hover:text-white">
          <div class="i-mdi-close text-2xl"></div>
        </button>
      </div>

      <div class="space-y-4">
        <div>
          <input
            v-model="prompt"
            rows="4"
            class="w-full bg-#2a2b36 text-white rounded-lg p-3 focus:outline-none focus:ring-2 focus:ring-primary"
            placeholder="Décrivez brièvement votre produit pour générer du contenu..."
          ></input>
        </div>

        <div class="flex gap-2">
          <button v-if="type === 'description'"
            @click="generate"
            :disabled="isLoading"
            class="flex-1 bg-primary text-white py-2 px-4 rounded-lg hover:bg-opacity-90 transition-colors disabled:opacity-50"
          >
            Générer la description
          </button>
          <button v-else
            @click="generate"
            :disabled="isLoading"
            class="flex-1 bg-primary text-white py-2 px-4 rounded-lg hover:bg-opacity-90 transition-colors disabled:opacity-50"
          >
            Générer les fonctionnalités
          </button>
        </div>
      </div>

      <div v-if="isLoading" class="flex items-center justify-center py-4">
        <div class="i-mdi-loading animate-spin text-primary text-2xl"></div>
      </div>

      <div v-if="result && type === 'description'" class="bg-#2a2b36 rounded-lg p-4">
        <h4 class="text-white font-medium mb-2">Contenu généré:</h4>
        <p class="text-gray-300 whitespace-pre-line">{{ result }}</p>
        <button
          @click="useContent"
          class="mt-4 w-full bg-primary text-white py-2 rounded-lg hover:bg-opacity-90 transition-colors"
        >
          Conserver
        </button>
      </div>

      <div v-else-if="result && type === 'features'" class="space-y-2">
        <h4 class="text-white font-medium mb-2">Contenu généré:</h4>

        <div v-for="(feature, index) in features" :key="index" class="flex gap-2">
          <textarea
            v-model="features[index]"
            class="flex-1 bg-background-secondary text-white rounded-lg p-3 focus:outline-none focus:ring-2 focus:ring-primary"
            type="text"
            disabled
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
          @click="useFeatures"
          class="mt-4 w-full bg-primary text-white py-2 rounded-lg hover:bg-opacity-90 transition-colors"
        >
          Conserver
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const props = defineProps<{
  isOpen: boolean,
  type: string
}>()

const emit = defineEmits(['close', 'content', 'features'])

const prompt = ref('')
const result = ref('')
const features = ref<string[]>([])
const isLoading = ref(false)
const close = () => {
  emit('close')
  prompt.value = ''
  result.value = ''
  features.value = []
}

const generate = async () => {
  isLoading.value = true

  try {
    const response = await fetch(`/api/v1/generate/${props.type}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: JSON.stringify({ prompt: prompt.value,
        type: props.type,})
    })

    if (!response.ok) {
      throw new Error('Erreur lors de la requête POST')
    }

    const data = await response.json()

    if (props.type === 'description') {
      result.value = data.message
    } else {
      result.value = 'hi'
      for (const feat in data) {
        features.value.push(data[feat])
      }
    }
  } catch (error) {
  } finally {
    isLoading.value = false
  }
}

const useContent = () => {
  emit('content', result.value,
  )
  close()
}

const useFeatures = () => {
  emit('features', features.value)
  close()
}
const removeFeature = (index: number) => {
  features.value.splice(index, 1)
}

</script>
