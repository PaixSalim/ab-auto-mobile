<template>
  <Layout title="Gestion des Vendeurs">
    <div class="space-y-8 animate-fade-in pb-12">
      <!-- Header Section -->
      <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-6">
        <div>
          <h1 class="text-4xl font-black text-slate-900 dark:text-white tracking-tight">Vendeurs</h1>
          <p class="text-slate-500 dark:text-slate-400 mt-1 font-medium italic">Gérez les accès de vos partenaires commerciaux.</p>
        </div>
        <button
          @click="showCreateModal = true"
          class="flex items-center gap-2 px-8 py-4 bg-primary hover:bg-primary-dark text-white rounded-[20px] font-bold shadow-xl shadow-primary/20 transition-all active:scale-95 group"
        >
          <div class="i-mdi-plus text-2xl group-hover:rotate-90 transition-transform duration-300"></div>
          Nouveau Vendeur
        </button>
      </div>

      <!-- Stats Summary -->
      <div v-if="sellers?.meta" class="grid grid-cols-1 sm:grid-cols-3 gap-6">
        <div class="bg-white dark:bg-slate-900 p-6 rounded-[24px] border border-slate-200 dark:border-slate-800 shadow-sm flex items-center gap-4">
          <div class="w-12 h-12 rounded-2xl bg-blue-500/10 flex items-center justify-center text-blue-500 font-bold">
            <div class="i-mdi-account-group text-2xl"></div>
          </div>
          <div>
            <p class="text-xs font-black text-slate-400 uppercase tracking-widest">Total</p>
            <p class="text-2xl font-black text-slate-900 dark:text-white">{{ sellers.meta.total }}</p>
          </div>
        </div>
        <div class="bg-white dark:bg-slate-900 p-6 rounded-[24px] border border-slate-200 dark:border-slate-800 shadow-sm flex items-center gap-4">
          <div class="w-12 h-12 rounded-2xl bg-emerald-500/10 flex items-center justify-center text-emerald-500 font-bold">
            <div class="i-mdi-check-decagram text-2xl"></div>
          </div>
          <div>
            <p class="text-xs font-black text-slate-400 uppercase tracking-widest">Page Actuelle</p>
            <p class="text-2xl font-black text-slate-900 dark:text-white">{{ sellers.data.length }}</p>
          </div>
        </div>
        <div class="bg-white dark:bg-slate-900 p-6 rounded-[24px] border border-slate-200 dark:border-slate-800 shadow-sm flex items-center gap-4">
          <div class="w-12 h-12 rounded-2xl bg-amber-500/10 flex items-center justify-center text-amber-500 font-bold">
            <div class="i-mdi-layers-outline text-2xl"></div>
          </div>
          <div>
            <p class="text-xs font-black text-slate-400 uppercase tracking-widest">Pages</p>
            <p class="text-2xl font-black text-slate-900 dark:text-white">{{ sellers.meta.last_page }}</p>
          </div>
        </div>
      </div>

      <!-- Table Container -->
      <div class="bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-[32px] shadow-2xl overflow-hidden ring-1 ring-black/5">
        <div class="overflow-x-auto">
          <table class="w-full text-left border-collapse">
            <thead>
              <tr class="bg-slate-50/50 dark:bg-slate-800/50 border-b border-slate-100 dark:border-slate-800">
                <th class="px-8 py-6 text-[10px] font-black text-slate-400 uppercase tracking-[2px]">Profil Vendeur</th>
                <th class="px-8 py-6 text-[10px] font-black text-slate-400 uppercase tracking-[2px] hidden md:table-cell">Coordonnées</th>
                <th class="px-8 py-6 text-[10px] font-black text-slate-400 uppercase tracking-[2px]">Statut</th>
                <th class="px-8 py-6 text-[10px] font-black text-slate-400 uppercase tracking-[2px] hidden lg:table-cell">Date</th>
                <th class="px-8 py-6 text-[10px] font-black text-slate-400 uppercase tracking-[2px] text-right">Actions</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-100 dark:divide-slate-800">
              <tr v-if="!sellers?.data || sellers.data.length === 0">
                <td colspan="5" class="px-8 py-32 text-center text-slate-300 dark:text-slate-600">
                  <div class="flex flex-col items-center gap-4">
                    <div class="i-mdi-account-off text-6xl opacity-20"></div>
                    <p class="text-xl font-bold italic">Aucun vendeur à afficher</p>
                  </div>
                </td>
              </tr>
              <tr 
                v-for="seller in sellers?.data || []" 
                :key="seller.id" 
                class="group hover:bg-slate-50 dark:hover:bg-slate-800/30 transition-all duration-300"
              >
                <!-- Avatar & Name -->
                <td class="px-8 py-6">
                  <div class="flex items-center gap-5">
                    <div class="relative">
                      <div class="w-14 h-14 rounded-[20px] bg-primary/10 flex items-center justify-center border border-primary/20 group-hover:scale-105 transition-transform duration-500 overflow-hidden shadow-inner">
                        <span class="text-primary font-black text-2xl">{{ seller.fullName.charAt(0) }}</span>
                      </div>
                      <div v-if="!seller.isValidated" class="absolute -top-1 -right-1 w-4 h-4 bg-amber-500 border-4 border-white dark:border-slate-900 rounded-full"></div>
                    </div>
                    <div>
                      <div class="font-black text-slate-800 dark:text-white text-lg tracking-tight">{{ seller.fullName }}</div>
                      <div class="text-[10px] text-slate-400 font-black uppercase tracking-widest mt-0.5">ID #{{ seller.id }}</div>
                    </div>
                  </div>
                </td>

                <!-- Contact Info -->
                <td class="px-8 py-6 hidden md:table-cell">
                  <div class="space-y-1.5">
                    <div class="flex items-center gap-2.5 text-slate-500 dark:text-slate-400 group/link">
                      <div class="i-mdi-email text-sm text-primary/60 group-hover/link:text-primary transition-colors"></div>
                      <span class="text-[13px] font-bold">{{ seller.email }}</span>
                    </div>
                    <div class="flex items-center gap-2.5 text-slate-500 dark:text-slate-400 group/link">
                      <div class="i-mdi-phone text-sm text-primary/60 group-hover/link:text-primary transition-colors"></div>
                      <span class="text-[13px] font-bold">{{ seller.phone || '—' }}</span>
                    </div>
                  </div>
                </td>

                <!-- Status Badge -->
                <td class="px-8 py-6">
                  <div 
                    :class="[
                      seller.isValidated 
                        ? 'bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border-emerald-500/20' 
                        : 'bg-amber-500/10 text-amber-600 dark:text-amber-400 border-amber-500/20',
                      'px-4 py-2 rounded-full text-[10px] font-black border flex items-center gap-2 w-fit uppercase tracking-tighter'
                    ]"
                  >
                    <div :class="[seller.isValidated ? 'i-mdi-check-decagram' : 'i-mdi-clock-outline', 'text-sm']"></div>
                    {{ seller.isValidated ? 'Activé' : 'En attente' }}
                  </div>
                </td>

                <!-- Date -->
                <td class="px-8 py-6 hidden lg:table-cell">
                  <p class="text-[13px] font-bold text-slate-400 tracking-tight">{{ formatDate(seller.createdAt) }}</p>
                </td>

                <!-- Actions -->
                <td class="px-8 py-6 text-right">
                  <div class="flex justify-end items-center gap-3 pr-2">
                    <button
                      @click="openDetailModal(seller)"
                      class="p-2.5 text-slate-500 bg-slate-500/5 hover:bg-slate-500/15 rounded-xl transition-all duration-300 hover:scale-110 active:scale-95 border border-transparent hover:border-current/20"
                      title="Voir les détails"
                    >
                      <div class="i-mdi-eye-outline text-2xl"></div>
                    </button>

                    <button
                      @click="openEditModal(seller)"
                      class="p-2.5 text-blue-500 bg-blue-500/5 hover:bg-blue-500/15 rounded-xl transition-all duration-300 hover:scale-110 active:scale-95 border border-transparent hover:border-current/20"
                      title="Modifier"
                    >
                      <div class="i-mdi-square-edit-outline text-2xl"></div>
                    </button>

                    <button
                      @click="deleteSeller(seller.id)"
                      class="p-2.5 text-red-500 bg-red-500/5 hover:bg-red-500/15 rounded-xl transition-all duration-300 hover:scale-110 active:scale-95 border border-transparent hover:border-current/20"
                      title="Supprimer"
                    >
                      <div class="i-mdi-trash-can-outline text-2xl"></div>
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Pagination Section -->
        <div v-if="sellers?.meta?.last_page > 1" class="border-t border-slate-100 dark:border-slate-800 px-8 py-6 flex items-center justify-between bg-slate-50/30 dark:bg-slate-800/20">
          <div class="text-[10px] font-black text-slate-400 uppercase tracking-widest">
            Affichage de {{ sellers.meta.from }} à {{ sellers.meta.to }} sur {{ sellers.meta.total }} vendeurs
          </div>
          
          <div class="flex items-center gap-2">
            <button
              v-for="link in sellers.meta.links"
              :key="link.label"
              @click="goToPage(link.url)"
              :disabled="!link.url || link.active"
              class="px-3 py-2 rounded-xl text-[11px] font-black transition-all"
              :class="[
                link.active 
                  ? 'bg-primary text-white shadow-lg shadow-primary/20 scale-110' 
                  : link.url 
                    ? 'bg-white dark:bg-slate-800 text-slate-600 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-700 border border-slate-200 dark:border-slate-700' 
                    : 'bg-slate-50 dark:bg-slate-900 text-slate-300 dark:text-slate-700 cursor-not-allowed opacity-50 border border-dashed border-slate-200 dark:border-slate-800'
              ]"
              v-html="link.label.replace('Previous', '<').replace('Next', '>')"
            ></button>
          </div>
        </div>
      </div>

      <!-- REUSABLE MODALS -->
      <transition enter-active-class="duration-300 ease-out" enter-from-class="opacity-0 translate-y-4" enter-to-class="opacity-100 translate-y-0" leave-active-class="duration-200 ease-in" leave-from-class="opacity-100 translate-y-0" leave-to-class="opacity-0 translate-y-4">
        <div v-show="showCreateModal || showEditModal || showDetailModal" class="fixed inset-0 z-50 flex items-center justify-center p-4">
          <div class="absolute inset-0 bg-slate-950/60 backdrop-blur-md" @click="closeModal"></div>
          
          <!-- Create / Edit Modal -->
          <div v-if="showCreateModal || showEditModal" class="relative w-full max-w-lg bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-[40px] shadow-3xl p-10 ring-1 ring-black/5 overflow-hidden">
            <h2 class="text-3xl font-black text-slate-900 dark:text-white mb-8 tracking-tighter">
              {{ showCreateModal ? 'Nouveau Vendeur' : 'Modifier le Profil' }}
            </h2>
            
            <form @submit.prevent="showCreateModal ? createSeller() : updateSeller()" class="space-y-6">
              <div v-if="showCreateModal" class="space-y-5">
                <div class="space-y-2">
                  <label class="text-[10px] font-black text-slate-400 uppercase tracking-widest pl-1">Structure / Entreprise</label>
                  <input v-model="formData.fullName" type="text" class="w-full bg-slate-50 dark:bg-slate-800/50 border border-slate-200 dark:border-slate-700 rounded-[20px] px-6 py-4 dark:text-white focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all font-bold placeholder:text-slate-300" placeholder="Ex: Boutique Auto" required />
                </div>
                <div class="space-y-2">
                  <label class="text-[10px] font-black text-slate-400 uppercase tracking-widest pl-1">Contact Email</label>
                  <input v-model="formData.email" type="email" class="w-full bg-slate-50 dark:bg-slate-800/50 border border-slate-200 dark:border-slate-700 rounded-[20px] px-6 py-4 dark:text-white focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all font-bold placeholder:text-slate-300" placeholder="partenaire@email.com" required />
                </div>
                <div class="space-y-2">
                  <label class="text-[10px] font-black text-slate-400 uppercase tracking-widest pl-1">GSM / Téléphone</label>
                  <input v-model="formData.phone" type="tel" class="w-full bg-slate-50 dark:bg-slate-800/50 border border-slate-200 dark:border-slate-700 rounded-[20px] px-6 py-4 dark:text-white focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all font-bold placeholder:text-slate-300" placeholder="+226 XX" />
                </div>
                <div class="space-y-2">
                  <label class="text-[10px] font-black text-slate-400 uppercase tracking-widest pl-1">Mot de passe</label>
                  <input v-model="formData.password" type="password" class="w-full bg-slate-50 dark:bg-slate-800/50 border border-slate-200 dark:border-slate-700 rounded-[20px] px-6 py-4 dark:text-white focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all font-bold placeholder:text-slate-300" placeholder="Minimum 8 caractères" required minlength="8" />
                </div>
              </div>

              <div v-else class="space-y-5">
                <div class="space-y-2">
                  <label class="text-[10px] font-black text-slate-400 uppercase tracking-widest pl-1">Structure / Entreprise</label>
                  <input v-model="editData.fullName" type="text" class="w-full bg-slate-50 dark:bg-slate-800/50 border border-slate-200 dark:border-slate-700 rounded-[20px] px-6 py-4 dark:text-white focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all font-bold" required />
                </div>
                <div class="space-y-2">
                  <label class="text-[10px] font-black text-slate-400 uppercase tracking-widest pl-1">Contact Email</label>
                  <input v-model="editData.email" type="email" class="w-full bg-slate-50 dark:bg-slate-800/50 border border-slate-200 dark:border-slate-700 rounded-[20px] px-6 py-4 dark:text-white focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all font-bold" required />
                </div>
                <div class="space-y-2">
                  <label class="text-[10px] font-black text-slate-400 uppercase tracking-widest pl-1">GSM / Téléphone</label>
                  <input v-model="editData.phone" type="tel" class="w-full bg-slate-50 dark:bg-slate-800/50 border border-slate-200 dark:border-slate-700 rounded-[20px] px-6 py-4 dark:text-white focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all font-bold" />
                </div>
                <div class="space-y-2">
                  <label class="text-[10px] font-black text-primary/70 uppercase tracking-widest pl-1">Nouveau mot de passe (optionnel)</label>
                  <input v-model="editData.password" type="password" class="w-full bg-slate-50 dark:bg-slate-800/50 border border-slate-200 dark:border-slate-700 rounded-[20px] px-6 py-4 dark:text-white focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all font-bold" placeholder="Laisser vide pour ne pas changer" />
                </div>
              </div>

              <div class="flex gap-4 pt-6">
                <button type="submit" class="flex-1 bg-primary hover:bg-primary-dark text-white py-5 rounded-[22px] font-black transition-all active:scale-95 shadow-2xl shadow-primary/20 tracking-tighter">
                  {{ showCreateModal ? 'CRÉER LE VENDEUR' : 'ENREGISTRER' }}
                </button>
                <button type="button" @click="closeModal" class="flex-1 bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 dark:hover:bg-slate-700 text-slate-900 dark:text-white py-5 rounded-[22px] font-black transition-all border border-slate-200 dark:border-slate-700 tracking-tighter">
                  ANNULER
                </button>
              </div>
            </form>
          </div>

          <!-- Detail Modal -->
          <div v-if="showDetailModal && selectedSeller" class="relative w-full max-w-2xl bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-[40px] shadow-3xl p-0 ring-1 ring-black/5 overflow-hidden">
            <!-- Modal Header with Pattern -->
            <div class="bg-slate-50 dark:bg-slate-800/50 p-10 pb-6 border-b border-slate-100 dark:border-slate-800 relative overflow-hidden">
               <div class="absolute top-0 right-0 p-8 opacity-5">
                <div class="i-mdi-store text-9xl"></div>
              </div>

              <div class="flex items-start justify-between">
                <div class="flex items-center gap-6">
                  <div class="w-20 h-20 rounded-3xl bg-primary/10 flex items-center justify-center border border-primary/20">
                    <span class="text-primary font-black text-4xl">{{ selectedSeller.fullName.charAt(0) }}</span>
                  </div>
                  <div>
                    <h2 class="text-3xl font-black text-slate-900 dark:text-white tracking-tighter">{{ selectedSeller.fullName }}</h2>
                    <div class="flex items-center gap-2 mt-1">
                      <span class="px-3 py-1 bg-primary/5 text-primary text-[10px] font-black uppercase rounded-lg border border-primary/10 tracking-widest tracking-tighter">Vendeur Pro</span>
                      <span class="text-slate-400 font-bold text-xs">ID #{{ selectedSeller.id }}</span>
                    </div>
                  </div>
                </div>
                
                <div 
                  :class="[
                    selectedSeller.isValidated 
                      ? 'bg-emerald-500/10 text-emerald-600 border-emerald-500/20' 
                      : 'bg-amber-500/10 text-amber-600 border-amber-500/20',
                    'px-4 py-2 rounded-xl text-[10px] font-black border flex items-center gap-2 uppercase'
                  ]"
                >
                  <div :class="[selectedSeller.isValidated ? 'i-mdi-check-decagram' : 'i-mdi-clock-outline']"></div>
                  {{ selectedSeller.isValidated ? 'Compte Actif' : 'En attente' }}
                </div>
              </div>
            </div>

            <div class="p-10">
              <div class="grid grid-cols-2 gap-10">
                <!-- Info Section -->
                <div class="space-y-8">
                  <div>
                    <h3 class="text-[10px] font-black text-slate-400 uppercase tracking-[2px] mb-4">Informations Générales</h3>
                    <div class="space-y-4">
                      <div class="flex items-start gap-4 group">
                        <div class="w-10 h-10 rounded-xl bg-slate-100 dark:bg-slate-800 flex items-center justify-center text-slate-400 group-hover:text-primary transition-colors">
                          <div class="i-mdi-text-box-search-outline text-xl"></div>
                        </div>
                        <div>
                          <p class="text-[10px] font-black text-slate-400 uppercase tracking-tighter">Matricule</p>
                          <p class="font-black text-slate-800 dark:text-white">{{ selectedSeller.registrationNumber || 'Non généré' }}</p>
                        </div>
                      </div>

                      <div class="flex items-start gap-4 group">
                        <div class="w-10 h-10 rounded-xl bg-slate-100 dark:bg-slate-800 flex items-center justify-center text-slate-400 group-hover:text-primary transition-colors">
                          <div class="i-mdi-storefront-outline text-xl"></div>
                        </div>
                        <div>
                          <p class="text-[10px] font-black text-slate-400 uppercase tracking-tighter">Enseigne commerciale</p>
                          <p class="font-black text-slate-800 dark:text-white">{{ selectedSeller.companyName || selectedSeller.fullName }}</p>
                        </div>
                      </div>
                    </div>
                  </div>

                  <div>
                    <h3 class="text-[10px] font-black text-slate-400 uppercase tracking-[2px] mb-4">Localisation</h3>
                    <div class="space-y-4">
                      <div class="flex items-start gap-4 group">
                        <div class="w-10 h-10 rounded-xl bg-slate-100 dark:bg-slate-800 flex items-center justify-center text-slate-400 group-hover:text-primary transition-colors">
                          <div class="i-mdi-map-marker-radius-outline text-xl"></div>
                        </div>
                        <div>
                          <p class="text-[10px] font-black text-slate-400 uppercase tracking-tighter">Ville & Secteur</p>
                          <p class="font-black text-slate-800 dark:text-white">{{ selectedSeller.city || 'Non renseignée' }} - {{ selectedSeller.neighborhood || 'N/A' }}</p>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>

                <!-- Contact Section -->
                <div class="space-y-8">
                  <div>
                    <h3 class="text-[10px] font-black text-slate-400 uppercase tracking-[2px] mb-4">Coordonnées</h3>
                    <div class="space-y-4">
                      <div class="flex items-start gap-4 group">
                        <div class="w-10 h-10 rounded-xl bg-slate-100 dark:bg-slate-800 flex items-center justify-center text-slate-400 group-hover:text-primary transition-colors">
                          <div class="i-mdi-at text-xl"></div>
                        </div>
                        <div>
                          <p class="text-[10px] font-black text-slate-400 uppercase tracking-tighter">Email Professionnel</p>
                          <p class="font-black text-slate-800 dark:text-white truncate max-w-[180px]">{{ selectedSeller.email }}</p>
                        </div>
                      </div>

                      <div class="flex items-start gap-4 group">
                        <div class="w-10 h-10 rounded-xl bg-slate-100 dark:bg-slate-800 flex items-center justify-center text-slate-400 group-hover:text-primary transition-colors">
                          <div class="i-mdi-phone-outline text-xl"></div>
                        </div>
                        <div>
                          <p class="text-[10px] font-black text-slate-400 uppercase tracking-tighter">Téléphone</p>
                          <p class="font-black text-slate-800 dark:text-white">{{ selectedSeller.phone || 'Non renseigné' }}</p>
                        </div>
                      </div>
                    </div>
                  </div>

                  <div class="p-6 bg-primary/5 rounded-[24px] border border-primary/10">
                    <div class="flex items-center justify-between mb-4">
                       <h3 class="text-[10px] font-black text-primary uppercase tracking-widest">Compte Utilisateur</h3>
                       <div class="i-mdi-shield-check-outline text-primary text-xl"></div>
                    </div>
                    <p class="text-xs text-slate-500 dark:text-slate-400 font-medium">Inscrit le <span class="font-black text-slate-700 dark:text-slate-300">{{ formatDate(selectedSeller.createdAt) }}</span></p>
                    
                    <button 
                      @click="toggleValidation(selectedSeller.id)"
                      class="w-full mt-4 py-3 rounded-xl font-black text-[10px] uppercase tracking-widest transition-all"
                      :class="selectedSeller.isValidated ? 'bg-amber-500 hover:bg-amber-600 text-white' : 'bg-emerald-500 hover:bg-emerald-600 text-white'"
                    >
                      {{ selectedSeller.isValidated ? 'Désactiver le compte' : 'Valider maintenant' }}
                    </button>
                  </div>
                </div>
              </div>

              <!-- Footer Actions -->
              <div class="mt-12 flex justify-end">
                <button 
                  @click="closeModal" 
                  class="px-10 py-4 bg-slate-900 dark:bg-slate-800 hover:bg-slate-800 dark:hover:bg-slate-700 text-white rounded-[20px] font-black transition-all active:scale-95 shadow-xl shadow-slate-900/10 tracking-widest text-[10px]"
                >
                  FERMER
                </button>
              </div>
            </div>
          </div>
        </div>
      </transition>
    </div>
  </Layout>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { router } from '@inertiajs/vue3'
import Layout from '~/components/admin/Layout.vue'

interface Seller {
  id: number
  fullName: string
  email: string
  phone: string | null
  registrationNumber: string | null
  companyName: string | null
  city: string | null
  neighborhood: string | null
  isValidated: boolean
  createdAt: string
}

interface SellersResponse {
  data: Seller[]
  meta: {
    total: number
    per_page: number
    current_page: number
    last_page: number
    first_page: number
    from: number
    to: number
    links: Array<{ url: string | null, label: string, active: boolean }>
  }
}

defineProps<{ sellers: SellersResponse }>()

const showCreateModal = ref(false)
const showEditModal = ref(false)
const showDetailModal = ref(false)
const selectedSeller = ref<Seller | null>(null)
const loading = ref(false)

const formData = ref({ fullName: '', email: '', phone: '', password: '' })
const editData = ref({ id: 0, fullName: '', email: '', phone: '', password: '' })

function closeModal() {
  showCreateModal.value = false
  showEditModal.value = false
  showDetailModal.value = false
  selectedSeller.value = null
  formData.value = { fullName: '', email: '', phone: '', password: '' }
  editData.value = { id: 0, fullName: '', email: '', phone: '', password: '' }
}

function openDetailModal(seller: Seller) {
  selectedSeller.value = seller
  showDetailModal.value = true
}

function openEditModal(seller: Seller) {
  editData.value = { id: seller.id, fullName: seller.fullName, email: seller.email, phone: seller.phone || '', password: '' }
  showEditModal.value = true
}

async function createSeller() {
  
  try {
    // Utiliser la bonne route admin pour créer un vendeur
    
    // Récupérer tous les cookies pour les passer à la requête
    const cookies = document.cookie
    
    const response = await fetch('/sellers-admin/create', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'Cookie': cookies, // Important pour l'authentification AdonisJS
      },
      credentials: 'same-origin', // Inclure les cookies automatiquement
      body: JSON.stringify(formData.value)
    })
    
    
    if (response.ok) {
      closeModal()
      // Recharger la page manuellement
      window.location.reload()
    } else {
      const error = await response.json()
      alert(`Erreur: ${error.message || 'Erreur inconnue'}`)
    }
  } catch (error) {
    alert('Erreur de connexion au serveur')
  }
}

function updateSeller() {
  router.put('/dashboard/sellers/edit', editData.value, {
    onSuccess: () => closeModal(),
  })
}

function toggleValidation(id: number) {
  fetch(`/sellers-admin/toggle-validation/${id}`, {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    credentials: 'same-origin',
  })
  .then(response => response.json())
  .then(data => {
    if (data.success) {
      // Recharger la page pour voir les changements
      window.location.reload()
    } else {
      alert(`Erreur: ${data.message}`)
    }
  })
  .catch(error => {
    alert('Erreur de connexion au serveur')
  })
}

function goToPage(url: string | null) {
  if (url) {
    router.visit(url, {
      preserveScroll: true,
    })
  }
}

function deleteSeller(id: number) {
  if (confirm('Êtes-vous sûr de vouloir supprimer ce vendeur ? Tous ses produits seront également supprimés.')) {
    router.delete(`/dashboard/sellers/delete/${id}`)
  }
}

function formatDate(date: string) {
  return new Date(date).toLocaleDateString('fr-FR', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
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

.shadow-3xl {
  box-shadow: 0 50px 100px -20px rgba(0, 0, 0, 0.25);
}

.dark .shadow-3xl {
  box-shadow: 0 50px 100px -20px rgba(0, 0, 0, 0.6);
}
</style>
