<template>
  <div class="fixed bottom-4 right-4 z-50">
    <!-- Icône d'assistance -->
    <button
      @click="toggleChat"
      class="flex items-center justify-center w-14 h-14 rounded-full bg-primary text-white shadow-lg hover:bg-primary/90 transition-all duration-300 focus:outline-none"
      :class="{ 'scale-0': isChatOpen }"
    >
      <div class="i-mdi-headset text-2xl"></div>
    </button>

    <!-- Fenêtre de chat -->
    <div
      v-show="isChatOpen"
      class="absolute bottom-0 right-0 w-[320px] sm:w-[350px] bg-white rounded-lg shadow-xl overflow-hidden transition-all duration-300"
      :class="{ 'translate-y-full opacity-0': !isChatOpen, 'translate-y-0 opacity-100': isChatOpen }"
    >
      <!-- En-tête -->
      <div class="bg-primary text-white p-4 flex justify-between items-center">
        <div class="flex items-center">
          <div class="i-mdi-headset text-xl mr-2"></div>
          <h3 class="font-medium">Uvatis Bot</h3>
        </div>
        <button @click="toggleChat" class="text-white hover:text-gray-200 focus:outline-none">
          <div class="i-mdi-close text-xl"></div>
        </button>
      </div>

      <!-- Corps du chat -->
      <div class="h-80 overflow-y-auto p-4 bg-gray-50" ref="chatContainer">
        <div v-for="(message, index) in messages" :key="index" class="mb-4">
          <div
            v-if="message.sender === 'assistant'"
            class="flex items-start"
          >
            <div class="w-8 h-8 rounded-full bg-primary flex items-center justify-center text-white flex-shrink-0">
              <div class="i-mdi-robot text-lg"></div>
            </div>
            <div class="ml-2 p-3 bg-white rounded-lg rounded-tl-none max-w-[85%] shadow-sm">
              <p class="text-gray-800 text-sm break-words break-all" v-html="formatMessageWithLinks(message.text)"></p>
            </div>
          </div>
          <div
            v-else
            class="flex items-start justify-end"
          >
            <div class="mr-2 p-3 bg-primary/10 rounded-lg rounded-tr-none max-w-[85%] shadow-sm">
              <p class="text-gray-800 text-sm">{{ message.text }}</p>
            </div>
            <div class="w-8 h-8 rounded-full bg-gray-100 border flex items-center justify-center text-gray-500 flex-shrink-0">
              <div class="i-mdi-account text-lg"></div>
            </div>
          </div>
        </div>
        <div v-if="isTyping" class="flex items-start">
          <div class="w-8 h-8 rounded-full bg-primary flex items-center justify-center text-white flex-shrink-0">
            <div class="i-mdi-robot text-lg"></div>
          </div>
          <div class="ml-2 p-3 bg-white rounded-lg rounded-tl-none shadow-sm">
            <div class="flex space-x-1">
              <div class="w-2 h-2 bg-gray-400 rounded-full animate-bounce"></div>
              <div class="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style="animation-delay: 0.2s"></div>
              <div class="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style="animation-delay: 0.4s"></div>
            </div>
          </div>
        </div>
      </div>

      <!-- Pied de page avec zone de saisie -->
      <div class="border-t border-gray-200 p-4 bg-white">
        <form @submit.prevent="sendMessage" class="flex">
          <input
            v-model="newMessage"
            type="text"
            placeholder="Tapez votre message..."
            class="flex-1 border border-gray-300 rounded-l-lg px-4 py-2 focus:outline-none focus:ring-1 focus:ring-primary/30"
            :disabled="isTyping"
          />
          <button
            type="submit"
            class="bg-primary text-white px-4 py-2 rounded-r-lg hover:bg-primary/90 focus:outline-none disabled:opacity-50"
            :disabled="!newMessage.trim() || isTyping"
          >
            <div class="i-mdi-send text-lg"></div>
          </button>
        </form>
      </div>

      <!-- Pied de page avec logo et mention -->
      <div @click="goTo" class="border-t border-gray-200 p-3 bg-gray-50">
        <div class="flex items-center justify-center">
          <img :src="logoUrl" alt="UVATIS LLC Logo" class="h-6 mr-2" />
          <p class="text-xs text-gray-500">Chat développé par UVATIS LLC</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch, nextTick, onMounted, onUnmounted } from 'vue'

interface Message {
  text: string
  sender: 'user' | 'assistant'
}

const goTo = () => {
  document.location.href = 'https://www.uvatis.com'
}
const logoUrl = 'https://www.uvatis.com/icon.svg'

const isChatOpen = ref(false)
const messages = ref<Message[]>([
  {
    text: "Bonjour ! Comment puis-je vous aider aujourd'hui ?",
    sender: 'assistant'
  }
])
const newMessage = ref('')
const isTyping = ref(false)
const chatContainer = ref<HTMLElement | null>(null)

const toggleChat = () => {
  isChatOpen.value = !isChatOpen.value
}

// Fonction pour formater le texte et rendre les liens cliquables
const formatMessageWithLinks = (text: string): string => {
  // Regex pour détecter les URLs
  const urlRegex = /(https?:\/\/[^\s]+)/g

  // Remplacer les URLs par des liens cliquables
  return text.replace(urlRegex, (url) => {
    return `<a href="${url}" target="_blank" rel="noopener noreferrer" class="text-blue-600 hover:underline">${url}</a>`
  })
}

const sendMessage = async () => {
  if (!newMessage.value.trim() || isTyping.value) return

  // Ajouter le message de l'utilisateur
  messages.value.push({
    text: newMessage.value,
    sender: 'user'
  })

  const userMessage = newMessage.value
  newMessage.value = ''

  // Faire défiler vers le bas
  await nextTick()
  scrollToBottom()

  // Simuler la réponse de l'assistant
  isTyping.value = true
  await nextTick()
  scrollToBottom()

  setTimeout(async () => {


    // Générer une réponse basée sur le message de l'utilisateur
    let response = await sendToChat(userMessage)

      messages.value.push({
        text: response,
        sender: 'assistant'
      })

    isTyping.value = false

    // Faire défiler vers le bas après avoir ajouté la réponse
    nextTick(() => {
      scrollToBottom()
    })
  }, 1500) // Délai simulé pour l'effet de frappe
}

const scrollToBottom = () => {
  if (chatContainer.value) {
    chatContainer.value.scrollTop = chatContainer.value.scrollHeight
  }
}


const sendToChat = async (message: string) => {
  try {
    const response = await fetch('/api/v1/generate/chat', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        prompt: message,
        type: 'chat',
      })
    })

    if (!response.ok) {
      throw new Error(`HTTP error! Status: ${response.status}`)
    }

    const data = await response.json()
    return data.text
  }
  catch (e) {
    throw e
  }
}

// Observer les changements de messages pour faire défiler automatiquement
watch(messages, () => {
  nextTick(() => {
    scrollToBottom()
  })
})

// Observer l'ouverture du chat pour faire défiler vers le bas
watch(isChatOpen, (newValue) => {
  if (newValue) {
    nextTick(() => {
      scrollToBottom()
    })
  }
})


const handleKeydown = (event: KeyboardEvent) => {
  if (event.key === 'Escape') {
    toggleChat()
  }
}
onMounted(() => {
  document.addEventListener('keydown', handleKeydown)
})

onUnmounted(() => {
  document.removeEventListener('keydown', handleKeydown)
})

</script>

<style scoped>
.animate-bounce {
  animation: bounce 1s infinite;
}

@keyframes bounce {
  0%, 100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-25%);
  }
}
</style>

