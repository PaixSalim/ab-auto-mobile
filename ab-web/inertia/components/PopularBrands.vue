<script setup lang="ts">
import { PartnerInterface } from '#dto/partners_interface'

defineProps<{
  partners: PartnerInterface[]
}>()
</script>

<template>
  <section class="py-10">
    <h2 class="text-2xl font-bold text-center mb-8">Nos marques partenaires</h2>
    <div class="flex flex-wrap justify-center items-center gap-8 md:gap-12">
      <div v-for="partner in partners" :key="partner.label" class=" hover:grayscale transition-all duration-300">
        <img :src="partner.image" :alt="partner.label" class="h-15 w-15 sm:(h-30 w-30) object-contain" />
      </div>
    </div>
  </section>
</template>

<style scoped>

</style>
