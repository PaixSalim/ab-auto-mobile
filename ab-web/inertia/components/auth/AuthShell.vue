<script setup lang="ts">
import { Link } from '@inertiajs/vue3'
import AuthBrandMark from './AuthBrandMark.vue'

withDefaults(
  defineProps<{
    title: string
    subtitle: string
    /** Formulaire inscription plus large */
    wide?: boolean
    /** Affiche une croix en haut à droite (retour accueil) */
    showClose?: boolean
  }>(),
  { wide: false, showClose: false },
)
</script>

<template>
  <div
    class="relative min-h-screen overflow-hidden bg-[#0c0f14] flex items-center justify-center px-4 py-10 sm:py-14"
  >
    <div
      class="pointer-events-none absolute -left-32 top-1/4 h-72 w-72 rounded-full bg-[#BE1622]/20 blur-[100px]"
      aria-hidden="true"
    />
    <div
      class="pointer-events-none absolute -right-24 bottom-1/4 h-64 w-64 rounded-full bg-blue-600/10 blur-[90px]"
      aria-hidden="true"
    />
    <div
      class="pointer-events-none absolute inset-0 opacity-[0.04] bg-[length:24px_24px] bg-[linear-gradient(to_right,rgba(255,255,255,0.08)_1px,transparent_1px),linear-gradient(to_bottom,rgba(255,255,255,0.08)_1px,transparent_1px)]"
      aria-hidden="true"
    />

    <div class="relative z-10 w-full" :class="wide ? 'max-w-2xl' : 'max-w-md'">
      <div
        class="relative rounded-3xl border border-white/[0.08] bg-white/[0.04] p-6 shadow-2xl shadow-black/40 backdrop-blur-xl sm:p-8"
      >
        <Link
          v-if="showClose"
          href="/"
          class="absolute right-4 top-4 z-20 flex h-10 w-10 items-center justify-center rounded-xl text-white/50 transition hover:bg-white/10 hover:text-white"
          aria-label="Fermer et retour à l’accueil"
        >
          <span class="i-mdi-close h-6 w-6" aria-hidden="true" />
        </Link>
        <AuthBrandMark class="mb-8" />

        <h1
          class="text-center text-2xl font-bold tracking-tight text-white sm:text-3xl"
        >
          {{ title }}
        </h1>
        <p class="mt-2 text-center text-sm leading-relaxed text-white/55 sm:text-[15px]">
          {{ subtitle }}
        </p>

        <div class="mt-8">
          <slot />
        </div>
      </div>

      <p class="mt-6 text-center text-xs text-white/35">
        En continuant, vous acceptez nos conditions d’utilisation.
      </p>
    </div>
  </div>
</template>
