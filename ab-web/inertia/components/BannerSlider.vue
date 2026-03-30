<template>
  <section class="relative overflow-hidden">
    <div class="w-full relative overflow-hidden rounded-lg">
      <div
        class="flex transition-transform duration-500 ease-in-out"
        :style="{ transform: `translateX(-${currentSlide * 100}%)` }"
      >
        <div v-for="(banner, index) in banners" :key="index" class="w-full flex-shrink-0 relative">
          <img
            :src="banner.image"
            :alt="banner.title"
            class="w-full h-44 md:h-80 lg:h-96 object-cover rounded-lg"
          />
          <div
            class="absolute inset-0 bg-gradient-to-r from-black/70 to-transparent flex flex-col justify-end p-6 md:p-8 text-white"
          >
            <div class="max-w-2xl">
              <div class="inline-block bg-yellow-400 text-red-900 font-bold text-xs px-3 py-1 rounded-full mb-3 md:mb-4">
                🔥 PROMOTION
              </div>
              <h3 class="text-xl md:text-3xl lg:text-4xl font-black mb-2 md:mb-3 leading-tight">{{ banner.title }}</h3>
              <p class="text-sm md:text-base lg:text-lg mb-4 md:mb-6 text-white/90">{{ banner.description }}</p>
              <button
                @click="router.get('/catalogue')"
                class="bg-white text-red-600 font-bold px-6 py-3 rounded-lg hover:scale-105 transition-transform shadow-lg"
              >
                Acheter maintenant →
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Navigation dots -->
      <div class="absolute bottom-4 left-1/2 transform -translate-x-1/2 flex space-x-2">
        <button
          v-for="(_, index) in banners"
          :key="index"
          @click="goToSlide(index)"
          class="w-3 h-3 rounded-full transition-all duration-300"
          :class="currentSlide === index ? 'bg-yellow-400 w-8' : 'bg-white/50 hover:bg-white/80'"
          aria-label="Go to slide"
        ></button>
      </div>

      <!-- Arrow navigation -->
      <button
        @click="prevSlide"
        class="absolute left-4 top-1/2 transform -translate-y-1/2 bg-white/20 backdrop-blur-sm hover:bg-white/30 rounded-full p-3 text-white transition-all duration-300 border border-white/30"
        aria-label="Previous slide"
      >
        <ChevronLeftIcon class="w-6 h-6" />
      </button>
      <button
        @click="nextSlide"
        class="absolute right-4 top-1/2 transform -translate-y-1/2 bg-white/20 backdrop-blur-sm hover:bg-white/30 rounded-full p-3 text-white transition-all duration-300 border border-white/30"
        aria-label="Next slide"
      >
        <ChevronRightIcon class="w-6 h-6" />
      </button>
    </div>
  </section>
</template>

<script setup lang="ts">
import { ref, onMounted, onBeforeUnmount } from 'vue'
import { ChevronLeftIcon, ChevronRightIcon } from 'lucide-vue-next'
import { router } from '@inertiajs/vue3'

const props = defineProps<{
  banners: any[]
  autoplay: boolean
  interval: number
}>()

const currentSlide = ref(0)
let autoplayInterval: NodeJS.Timeout | null = null

const nextSlide = () => {
  currentSlide.value = (currentSlide.value + 1) % props.banners.length
}

const prevSlide = () => {
  currentSlide.value = (currentSlide.value - 1 + props.banners.length) % props.banners.length
}

const goToSlide = (index: number) => {
  currentSlide.value = index
}

const startAutoplay = () => {
  if (props.autoplay) {
    autoplayInterval = setInterval(() => {
      nextSlide()
    }, props.interval)
  }
}

const stopAutoplay = () => {
  if (autoplayInterval) {
    clearInterval(autoplayInterval as NodeJS.Timeout)
    autoplayInterval = null
  }
}

onMounted(() => {
  startAutoplay()
})

onBeforeUnmount(() => {
  stopAutoplay()
})
</script>
