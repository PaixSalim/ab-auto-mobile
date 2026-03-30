<script setup lang="ts">
import BannerSlider from '~/components/BannerSlider.vue'
import ProductCategories from '~/components/ProductCategories.vue'
import MobileNavbar from '~/components/MobileNavbar.vue'
import DealGrid from '~/components/DealGrid.vue'
import DesktopNavbar from '~/components/DesktopNavbar.vue'
import AllProductsGrid from '~/components/AllProductsGrid.vue'
import Footer from '~/components/Footer.vue'
import Notification from '~/components/Notification.vue'
import { Head } from '@inertiajs/vue3'
import SupportAssistant from '~/components/SupportAssistant.vue'
import RegisterPopup from '~/components/auth/RegisterPopup.vue'
import { BannerInterface } from '#dto/banners_interface'
import { PartnerInterface } from '#dto/partners_interface'
import { GetProductDto } from '#dto/products_interface'
import { CategoryDto } from '#dto/category_dto'
import { ref, provide, computed } from 'vue'

const props = defineProps<{
  banners: BannerInterface[]
  partners: PartnerInterface[]
  products: GetProductDto[]
  categories: CategoryDto[]
  auth?: {
    user?: any
    roles?: string[]
  }
}>()

const showRegisterPopup = ref(false)
const openRegister = () => {
  showRegisterPopup.value = true
}

// Provide to children components (Navbars)
provide('openRegister', openRegister)

// Filtrer uniquement les produits approuvés
const approvedProducts = computed(() => {
  return props.products.filter(product => product.validationStatus === 'approved')
})

const interval: number = 5000
const autoplay: boolean = true

</script>
<template>

  <Head>
    <title>Accueil</title>
  </Head>
  <div class="min-h-screen bg-gray-50">
    <Notification />
    <DesktopNavbar />
    <MobileNavbar />

    <!-- v-if : démontage complet quand fermé (évite overlay « figé » / bloquant) -->
    <RegisterPopup v-if="showRegisterPopup" @close="showRegisterPopup = false" />

    <main class="container mx-auto px-4 py-6">
      <BannerSlider :banners="banners" :interval="interval" :autoplay="autoplay"/>

      <ProductCategories />

       <!-- <PopularBrands :partners="partners"/>  -->

      <div id="promotions">
        <DealGrid/>
      </div>

      <AllProductsGrid :products="approvedProducts" :categories="categories" />

      <!-- <SupportAssistant /> -->
    </main>

    <Footer />
  </div>
</template>

<style scoped>
</style>
