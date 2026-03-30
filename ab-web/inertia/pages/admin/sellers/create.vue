<template>
  <Layout title="Créer un Vendeur">
    <div class="space-y-8 animate-fade-in pb-12">
      <!-- Header Section -->
      <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-6">
        <div>
          <h1 class="text-4xl font-black text-slate-900 dark:text-white tracking-tight">Nouveau Vendeur</h1>
          <p class="text-slate-500 dark:text-slate-400 mt-1 font-medium italic">Ajoutez un nouveau partenaire commercial.</p>
        </div>
        <button
          @click="goBack"
          class="flex items-center gap-2 px-8 py-4 bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 dark:hover:bg-slate-700 text-slate-900 dark:text-white rounded-[20px] font-bold transition-all active:scale-95"
        >
          <div class="i-mdi-arrow-left text-2xl"></div>
          Retour
        </button>
      </div>

      <!-- Form Container -->
      <div class="bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-[32px] shadow-2xl p-10 ring-1 ring-black/5">
        <form @submit.prevent="createSeller" class="space-y-8">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
            <div class="space-y-6">
              <div class="space-y-3">
                <label class="text-[10px] font-black text-slate-400 uppercase tracking-widest pl-1">Structure / Entreprise *</label>
                <input 
                  v-model="formData.fullName" 
                  type="text" 
                  class="w-full bg-slate-50 dark:bg-slate-800/50 border border-slate-200 dark:border-slate-700 rounded-[20px] px-6 py-4 dark:text-white focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all font-bold placeholder:text-slate-300" 
                  placeholder="Ex: Boutique Auto" 
                  required 
                />
              </div>

              <div class="space-y-3">
                <label class="text-[10px] font-black text-slate-400 uppercase tracking-widest pl-1">Contact Email</label>
                <input 
                  v-model="formData.email" 
                  type="email" 
                  class="w-full bg-slate-50 dark:bg-slate-800/50 border border-slate-200 dark:border-slate-700 rounded-[20px] px-6 py-4 dark:text-white focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all font-bold placeholder:text-slate-300" 
                  placeholder="partenaire@email.com" 
                />
              </div>
            </div>

            <div class="space-y-6">
              <div class="space-y-3">
                <label class="text-[10px] font-black text-slate-400 uppercase tracking-widest pl-1">GSM / Téléphone *</label>
                <input 
                  v-model="formData.phone" 
                  type="tel" 
                  class="w-full bg-slate-50 dark:bg-slate-800/50 border border-slate-200 dark:border-slate-700 rounded-[20px] px-6 py-4 dark:text-white focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all font-bold placeholder:text-slate-300" 
                  placeholder="+226 XX XX XX XX" 
                  required 
                />
              </div>

              <div class="space-y-3">
                <label class="text-[10px] font-black text-slate-400 uppercase tracking-widest pl-1">Mot de passe *</label>
                <input 
                  v-model="formData.password" 
                  type="password" 
                  class="w-full bg-slate-50 dark:bg-slate-800/50 border border-slate-200 dark:border-slate-700 rounded-[20px] px-6 py-4 dark:text-white focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all font-bold placeholder:text-slate-300" 
                  placeholder="Minimum 8 caractères" 
                  required 
                  minlength="8" 
                />
              </div>
            </div>
          </div>

          <!-- Submit Section -->
          <div class="flex gap-6 pt-8 border-t border-slate-100 dark:border-slate-800">
            <button 
              type="submit" 
              :disabled="loading"
              class="flex-1 bg-primary hover:bg-primary-dark text-white py-5 rounded-[22px] font-black transition-all active:scale-95 shadow-2xl shadow-primary/20 tracking-tighter disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <span v-if="loading" class="flex items-center justify-center gap-3">
                <div class="w-5 h-5 border-3 border-white border-t-transparent rounded-full animate-spin"></div>
                CRÉATION EN COURS...
              </span>
              <span v-else>CRÉER LE VENDEUR</span>
            </button>
            <button 
              type="button" 
              @click="goBack" 
              class="flex-1 bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 dark:hover:bg-slate-700 text-slate-900 dark:text-white py-5 rounded-[22px] font-black transition-all border border-slate-200 dark:border-slate-700 tracking-tighter"
            >
              ANNULER
            </button>
          </div>
        </form>
      </div>
    </div>
  </Layout>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { router } from '@inertiajs/vue3'
import Layout from '~/components/admin/Layout.vue'

const loading = ref(false)
const formData = ref({ 
  fullName: '', 
  email: '', 
  phone: '', 
  password: '' 
})

function goBack() {
  router.visit('/dashboard/sellers')
}

function createSeller() {
  loading.value = true
  
  router.post('/dashboard/sellers/', formData.value, {
    onSuccess: () => {
      loading.value = false
      router.visit('/dashboard/sellers')
    },
    onError: () => {
      loading.value = false
    }
  })
}
</script>

<style scoped>
.animate-fade-in {
  animation: fadeIn 0.8s cubic-bezier(0.16, 1, 0.3, 1);
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(30px); }
  to { opacity: 1; transform: translateY(0); }
}
</style>
