<script setup lang="ts">

import PrivacyComponent from '~/components/about/PrivacyComponent.vue'
import DesktopNavbar from '~/components/DesktopNavbar.vue'


const openLink = () => {
  window.location.href = 'https://api.whatsapp.com/send?phone=22607513333'
}
</script>
<template>

  <Head>
    <title>Politique de confidentialité</title>
  </Head>

  <div class="min-h-screen bg-gray-50">
    <PrivacyComponent/>
  </div>
</template>


<style>

</style>
