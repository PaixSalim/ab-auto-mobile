<template>
  <Layout title="Gestion des Clients">
    <div class="px-6 py-8">
      <div class="flex justify-between items-center mb-8">
        <div>
          <h1 class="text-3xl font-bold text-title mb-1">Gestion des Clients</h1>
          <p class="text-description text-sm">Suivez et gérez les comptes de vos clients professionnels</p>
        </div>
        <button
          @click="showCreateModal = true"
          class="bg-primary hover:bg-primary-dark text-white font-bold py-2.5 px-6 rounded-xl shadow-lg shadow-primary/20 transition-all flex items-center gap-2 group"
        >
          <div class="i-mdi-account-plus text-xl group-hover:scale-110 transition-transform"></div>
          Nouveau client
        </button>
      </div>

      <PaginatedList
        :items="customers"
        :headers="customerHeaders"
        :items-per-page="10"
        item-name="clients"
        empty-message="Aucun client pour le moment."
      >
        <template #cell-fullName="{ item }">
          <div class="flex items-center gap-3">
            <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-primary/20 to-primary/5 flex items-center justify-center text-primary font-bold shadow-inner">
              {{ item.fullName?.charAt(0) || 'C' }}
            </div>
            <div class="font-bold text-title">{{ item.fullName }}</div>
          </div>
        </template>

        <template #cell-email="{ item }">
          <div class="flex items-center gap-2 text-title">
            <div class="i-mdi-email-outline text-primary text-xs"></div>
            {{ item.email }}
          </div>
        </template>

        <template #cell-phone="{ item }">
          <div class="flex items-center gap-2 text-description">
            <div class="i-mdi-phone-outline text-xs"></div>
            {{ item.phone || '—' }}
          </div>
        </template>

        <template #cell-createdAt="{ item }">
          <div class="text-description text-sm italic">{{ formatDate(item.createdAt) }}</div>
        </template>

        <template #cell-actions="{ item }">
          <div class="flex items-center gap-4">
            <button
              @click="openEditModal(item)"
              class="text-blue-400 hover:text-blue-300 flex items-center gap-1.5 transition-colors group"
              title="Modifier"
            >
              <div class="i-mdi-pencil text-lg group-hover:scale-110 transition-transform"></div>
              <span class="text-xs font-bold uppercase tracking-wider">Modifier</span>
            </button>
            <button
              @click="deleteCustomer(item.id)"
              class="text-red-400 hover:text-red-300 flex items-center gap-1.5 transition-colors group"
              title="Supprimer"
            >
              <div class="i-mdi-delete text-lg group-hover:scale-110 transition-transform"></div>
              <span class="text-xs font-bold uppercase tracking-wider">Supprimer</span>
            </button>
          </div>
        </template>
      </PaginatedList>

      <!-- Modal Créer client -->
      <div v-if="showCreateModal" class="fixed inset-0 bg-slate-950/80 backdrop-blur-sm flex items-center justify-center z-50 p-4">
        <div class="bg-background-secondary border border-slate-800 rounded-2xl shadow-2xl w-full max-w-md overflow-hidden transform transition-all">
          <div class="p-6 border-b border-slate-800 flex justify-between items-center bg-slate-900/50">
            <h2 class="text-xl font-bold text-title">Nouveau client</h2>
            <button @click="closeModal" class="text-slate-400 hover:text-white transition-colors">
              <div class="i-mdi-close text-2xl"></div>
            </button>
          </div>
          
          <form @submit.prevent="createCustomer" class="p-8 space-y-6">
            <div>
              <label class="block text-sm font-bold text-description uppercase tracking-widest mb-2">Nom de l'entreprise *</label>
              <input 
                v-model="formData.fullName" 
                type="text" 
                class="w-full bg-slate-950 border border-slate-800 rounded-xl px-4 py-3 text-title focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all" 
                placeholder="Ex: Auto Services Sarl"
                required 
              />
            </div>
            
            <div>
              <label class="block text-sm font-bold text-description uppercase tracking-widest mb-2">Email direct *</label>
              <input 
                v-model="formData.email" 
                type="email" 
                class="w-full bg-slate-950 border border-slate-800 rounded-xl px-4 py-3 text-title focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all" 
                placeholder="contact@entreprise.com"
                required 
              />
            </div>
            
            <div>
              <label class="block text-sm font-bold text-description uppercase tracking-widest mb-2">Téléphone professionnel</label>
              <input 
                v-model="formData.phone" 
                type="tel" 
                class="w-full bg-slate-950 border border-slate-800 rounded-xl px-4 py-3 text-title focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all" 
                placeholder="+237 ..." 
              />
            </div>
            
            <div>
              <label class="block text-sm font-bold text-description uppercase tracking-widest mb-2">Mot de passe *</label>
              <input 
                v-model="formData.password" 
                type="password" 
                class="w-full bg-slate-950 border border-slate-800 rounded-xl px-4 py-3 text-title focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all" 
                required 
                minlength="8" 
              />
              <p class="text-[10px] text-description mt-2 italic">Le client pourra modifier son mot de passe ultérieurement.</p>
            </div>

            <div class="flex gap-4 pt-4 border-t border-slate-800">
              <button 
                type="button" 
                @click="closeModal" 
                class="flex-1 bg-slate-800 text-title px-4 py-3 rounded-xl hover:bg-slate-700 transition-colors font-bold text-xs uppercase tracking-widest"
              >
                Annuler
              </button>
              <button 
                type="submit" 
                class="flex-1 bg-primary text-white px-4 py-3 rounded-xl hover:bg-primary-dark transition-all font-bold shadow-lg shadow-primary/20 text-xs uppercase tracking-widest"
              >
                Créer le client
              </button>
            </div>
          </form>
        </div>
      </div>

      <!-- Modal Modifier client -->
      <div v-if="showEditModal" class="fixed inset-0 bg-slate-950/80 backdrop-blur-sm flex items-center justify-center z-50 p-4">
        <div class="bg-background-secondary border border-slate-800 rounded-2xl shadow-2xl w-full max-w-md overflow-hidden transform transition-all">
          <div class="p-6 border-b border-slate-800 flex justify-between items-center bg-slate-900/50">
            <h2 class="text-xl font-bold text-title">Modifier les informations</h2>
            <button @click="closeModal" class="text-slate-400 hover:text-white transition-colors">
              <div class="i-mdi-close text-2xl"></div>
            </button>
          </div>
          
          <form @submit.prevent="updateCustomer" class="p-8 space-y-6">
            <div>
              <label class="block text-sm font-bold text-description uppercase tracking-widest mb-2">Nom de l'entreprise *</label>
              <input 
                v-model="editData.fullName" 
                type="text" 
                class="w-full bg-slate-950 border border-slate-800 rounded-xl px-4 py-3 text-title focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all" 
                required 
              />
            </div>

            <div>
              <label class="block text-sm font-bold text-description uppercase tracking-widest mb-2">Email *</label>
              <input 
                v-model="editData.email" 
                type="email" 
                class="w-full bg-slate-950 border border-slate-800 rounded-xl px-4 py-3 text-title focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all" 
                required 
              />
            </div>

            <div>
              <label class="block text-sm font-bold text-description uppercase tracking-widest mb-2">Téléphone</label>
              <input 
                v-model="editData.phone" 
                type="tel" 
                class="w-full bg-slate-950 border border-slate-800 rounded-xl px-4 py-3 text-title focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all" 
              />
            </div>

            <div>
              <label class="block text-sm font-bold text-description uppercase tracking-widest mb-2">
                Nouveau mot de passe
                <span class="text-[10px] font-normal lowercase tracking-normal italic opacity-60">(Optionnel)</span>
              </label>
              <input 
                v-model="editData.password" 
                type="password" 
                class="w-full bg-slate-950 border border-slate-800 rounded-xl px-4 py-3 text-title focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all" 
                minlength="8" 
                placeholder="Laisser vide pour conserver l'actuel"
              />
            </div>

            <div class="flex gap-4 pt-4 border-t border-slate-800">
              <button 
                type="button" 
                @click="closeModal" 
                class="flex-1 bg-slate-800 text-title px-4 py-3 rounded-xl hover:bg-slate-700 transition-colors font-bold text-xs uppercase tracking-widest"
              >
                Annuler
              </button>
              <button 
                type="submit" 
                class="flex-1 bg-primary text-white px-4 py-3 rounded-xl hover:bg-primary-dark transition-all font-bold shadow-lg shadow-primary/20 text-xs uppercase tracking-widest"
              >
                Enregistrer
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </Layout>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { router } from '@inertiajs/vue3'
import Layout from '~/components/admin/Layout.vue'
import PaginatedList from '~/components/admin/PaginatedList.vue'

interface Customer {
  id: number
  fullName: string
  email: string
  phone: string | null
  createdAt: string
}

const props = defineProps<{ customers: Customer[] }>()

const customerHeaders = [
  { key: 'fullName', label: 'Client / Entreprise' },
  { key: 'email', label: 'Email' },
  { key: 'phone', label: 'Téléphone' },
  { key: 'createdAt', label: 'Inscription' },
  { key: 'actions', label: 'Actions', cellClass: 'text-right' }
]

const showCreateModal = ref(false)
const showEditModal = ref(false)

const formData = ref({ fullName: '', email: '', phone: '', password: '' })
const editData = ref({ id: 0, fullName: '', email: '', phone: '', password: '' })

function closeModal() {
  showCreateModal.value = false
  showEditModal.value = false
  formData.value = { fullName: '', email: '', phone: '', password: '' }
  editData.value = { id: 0, fullName: '', email: '', phone: '', password: '' }
}

function openEditModal(customer: Customer) {
  editData.value = { id: customer.id, fullName: customer.fullName, email: customer.email, phone: customer.phone || '', password: '' }
  showEditModal.value = true
}

function createCustomer() {
  router.post('/dashboard/customers/create', formData.value, {
    onSuccess: () => closeModal(),
  })
}

function updateCustomer() {
  router.post('/dashboard/customers/edit', editData.value, {
    onSuccess: () => closeModal(),
  })
}

function deleteCustomer(id: number) {
  if (confirm('Êtes-vous sûr de vouloir supprimer ce client ?')) {
    router.delete(`/dashboard/customers/delete/${id}`)
  }
}

function formatDate(date: string) {
  return new Date(date).toLocaleDateString('fr-FR', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
  })
}
</script>
