<template>
  <div class="min-h-screen bg-gray-50">
    <DesktopNavbar/>

    <MobileNavbar/>
    <main class="container mx-auto px-4">
  <div
    class="min-h-screen  flex flex-col justify-center items-center p-6"
  >
    <div class="text-center">
      <h1 class="text-9xl font-bold text-primary mb-4">404</h1>
      <p class="text-2xl mb-8">Oups ! Cette page semble avoir disparu dans le cyberespace.</p>
      <div class="mb-8">
        <svg
          class="mx-auto"
          width="200"
          height="200"
          viewBox="0 0 200 200"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
        >
          <circle cx="100" cy="100" r="80" stroke="#ff4d00" stroke-width="4" />
          <path
            d="M65 80C65 91.0457 56.0457 100 45 100C33.9543 100 25 91.0457 25 80C25 68.9543 33.9543 60 45 60C56.0457 60 65 68.9543 65 80Z"
            fill="#ff4d00"
          />
          <path
            d="M175 80C175 91.0457 166.046 100 155 100C143.954 100 135 91.0457 135 80C135 68.9543 143.954 60 155 60C166.046 60 175 68.9543 175 80Z"
            fill="#ff4d00"
          />
          <path
            d="M50 140C50 140 70 120 100 120C130 120 150 140 150 140"
            stroke="#ff4d00"
            stroke-width="4"
            stroke-linecap="round"
          />
        </svg>
      </div>
      <p class="text-xl mb-8">
        Ne vous inquiétez pas, il arrive même aux meilleurs d'entre nous de se perdre parfois.
      </p>
      <button
        @click="goHome"
        class="bg-primary hover:bg-opacity-90 text-white font-bold py-3 px-6 rounded-lg transition-colors text-lg"
      >
        Retourner à l'accueil
      </button>
    </div>
    </div>
    </main>
  </div>
</template>

<script setup lang="ts">
import { router } from '@inertiajs/vue3'
import MobileNavbar from '~/components/MobileNavbar.vue'
import DesktopNavbar from '~/components/DesktopNavbar.vue'

const goHome = () => {
  router.get('/')
}
</script>
