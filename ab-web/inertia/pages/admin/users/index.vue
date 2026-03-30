<template>
  <Layout title="Gestion des Utilisateurs">
    <div class="px-6 py-8">
      <div class="flex justify-between items-center mb-8">
        <div>
          <h1 class="text-3xl font-bold text-title mb-1">Utilisateurs</h1>
          <p class="text-description text-sm">Gérez les comptes, les rôles et les permissions des utilisateurs</p>
        </div>
        <button 
          @click="handleCreate"
          class="bg-primary hover:bg-primary-dark text-white font-bold py-2.5 px-6 rounded-xl shadow-lg shadow-primary/20 transition-all flex items-center gap-2 group"
        >
          <div class="i-mdi-account-plus text-xl group-hover:scale-110 transition-transform"></div>
          Nouvel Utilisateur
        </button>
      </div>

      <PaginatedList
        :items="users"
        :headers="userHeaders"
        :items-per-page="10"
        item-name="utilisateurs"
        empty-message="Aucun utilisateur trouvé."
      >
        <template #cell-fullName="{ item }">
          <div class="flex items-center gap-3">
            <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-primary/20 to-primary/5 flex items-center justify-center text-primary font-bold shadow-inner">
              {{ item.fullName?.charAt(0) || 'U' }}
            </div>
            <div class="font-bold text-title">{{ item.fullName }}</div>
          </div>
        </template>

        <template #cell-contact="{ item }">
          <div class="space-y-0.5">
            <div class="text-sm text-title flex items-center gap-2">
              <div class="i-mdi-email-outline text-slate-500 text-xs text-primary"></div>
              {{ item.email }}
            </div>
            <div v-if="item.phone" class="text-xs text-description flex items-center gap-2">
              <div class="i-mdi-phone-outline text-slate-500 text-xs"></div>
              {{ item.phone }}
            </div>
          </div>
        </template>

        <template #cell-roles="{ item }">
          <div class="flex flex-wrap gap-1.5">
            <span 
              v-for="role in item.roles" 
              :key="role.id"
              class="px-2.5 py-0.5 bg-primary/10 text-primary text-[10px] uppercase font-black rounded-lg border border-primary/20 tracking-wider"
            >
              {{ role.name }}
            </span>
          </div>
        </template>

        <template #cell-status="{ item }">
          <span 
            :class="[
              'inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[10px] font-black uppercase tracking-wider',
              item.isValidated 
                ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20' 
                : 'bg-amber-500/10 text-amber-400 border border-amber-500/20'
            ]"
          >
            <div :class="item.isValidated ? 'i-mdi-check-circle' : 'i-mdi-clock-outline'" class="text-xs"></div>
            {{ item.isValidated ? 'Validé' : 'En attente' }}
          </span>
        </template>

        <template #cell-actions="{ item }">
          <div class="flex items-center gap-4">
            <button 
              @click="handleEdit(item)" 
              class="text-blue-400 hover:text-blue-300 flex items-center gap-1.5 transition-colors group"
              title="Modifier"
            >
              <div class="i-mdi-pencil text-lg group-hover:scale-110 transition-transform"></div>
              <span class="text-xs font-bold uppercase tracking-wider">Modifier</span>
            </button>
            <button 
              v-if="item.roles?.[0]?.slug !== 'superadmin'"
              @click="deleteUser(item.id)" 
              class="text-red-400 hover:text-red-300 flex items-center gap-1.5 transition-colors group"
              title="Supprimer"
            >
              <div class="i-mdi-delete text-lg group-hover:scale-110 transition-transform"></div>
              <span class="text-xs font-bold uppercase tracking-wider">Supprimer</span>
            </button>
          </div>
        </template>
      </PaginatedList>

      <!-- Modal Créer/Modifier Utilisateur -->
      <div v-if="showCreateModal" class="fixed inset-0 bg-slate-950/80 backdrop-blur-sm flex items-center justify-center z-50 p-4">
        <div class="bg-background-secondary border border-slate-800 rounded-2xl shadow-2xl w-full max-w-lg overflow-hidden transform transition-all max-h-[90vh] flex flex-col">
          <!-- Modal Header -->
          <div class="p-6 border-b border-slate-800 flex justify-between items-center bg-slate-900/50">
            <h2 class="text-xl font-bold text-title">{{ editingUser ? 'Modifier l\'utilisateur' : 'Créer un utilisateur' }}</h2>
            <button @click="closeModal" class="text-slate-400 hover:text-white transition-colors">
              <div class="i-mdi-close text-2xl"></div>
            </button>
          </div>
          
          <!-- Modal Body -->
          <form @submit.prevent="submit" class="p-8 space-y-6 overflow-y-auto">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div class="md:col-span-2">
                <label class="block text-sm font-bold text-description uppercase tracking-widest mb-2">Nom Complet *</label>
                <input 
                  v-model="form.fullName" 
                  type="text" 
                  class="w-full bg-slate-950 border border-slate-800 rounded-xl px-4 py-3 text-title focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all" 
                  placeholder="Jean Dupont"
                  required 
                />
              </div>
              
              <div>
                <label class="block text-sm font-bold text-description uppercase tracking-widest mb-2">Email *</label>
                <input 
                  v-model="form.email" 
                  type="email" 
                  class="w-full bg-slate-950 border border-slate-800 rounded-xl px-4 py-3 text-title focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all" 
                  placeholder="jean@example.com"
                  required 
                />
              </div>
              
              <div>
                <label class="block text-sm font-bold text-description uppercase tracking-widest mb-2">Téléphone</label>
                <input 
                  v-model="form.phone" 
                  type="text" 
                  class="w-full bg-slate-950 border border-slate-800 rounded-xl px-4 py-3 text-title focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all" 
                  placeholder="+237 ..."
                />
              </div>
              
              <div v-if="!editingUser" class="md:col-span-2">
                <label class="block text-sm font-bold text-description uppercase tracking-widest mb-2">Mot de passe *</label>
                <div class="relative">
                  <input 
                    v-model="form.password" 
                    type="password" 
                    class="w-full bg-slate-950 border border-slate-800 rounded-xl px-4 py-3 text-title focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all" 
                    required 
                  />
                  <div class="i-mdi-lock-outline absolute right-4 top-1/2 -translate-y-1/2 text-slate-600"></div>
                </div>
              </div>
            </div>

            <!-- Role Section -->
            <div class="pt-4 border-t border-slate-800">
              <label class="block text-sm font-bold text-description uppercase tracking-widest mb-4">Rôle attribué *</label>
              <div class="grid grid-cols-2 sm:grid-cols-3 gap-3">
                <label
                  v-for="role in roles"
                  :key="role.id"
                  class="relative flex items-center justify-center gap-2 cursor-pointer p-3 rounded-xl transition-all border shrink-0"
                  :class="form.roleId === role.id 
                    ? 'bg-primary/10 border-primary text-primary shadow-sm' 
                    : 'bg-slate-950 border-slate-800 text-slate-400 hover:border-slate-700'"
                >
                  <input
                    type="radio"
                    :value="role.id"
                    v-model="form.roleId"
                    class="hidden"
                    required
                  />
                  <div v-if="form.roleId === role.id" class="i-mdi-check-circle text-lg animate-in zoom-in-50 duration-200"></div>
                  <span class="text-xs font-black uppercase tracking-wider">{{ role.name }}</span>
                </label>
              </div>
            </div>

            <!-- Seller Specific Fields -->
            <transition 
              enter-active-class="transition duration-300 ease-out"
              enter-from-class="opacity-0 -translate-y-4"
              enter-to-class="opacity-100 translate-y-0"
            >
              <div v-if="roles.find(r => r.id === form.roleId)?.slug === 'seller'" class="space-y-6 pt-6 border-t border-dashed border-slate-800">
                <h3 class="text-xs font-black text-primary uppercase tracking-[0.2em] flex items-center gap-2">
                  <div class="i-mdi-storefront text-lg"></div>
                  Informations Boutique
                </h3>
                <div>
                  <label class="block text-sm font-bold text-description uppercase tracking-widest mb-2">Nom de la Boutique</label>
                  <input v-model="form.companyName" type="text" class="w-full bg-slate-950 border border-slate-800 rounded-xl px-4 py-3 text-title focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all" placeholder="Ex: AB Auto Express" />
                </div>
                <div class="grid grid-cols-2 gap-4">
                  <div>
                    <label class="block text-sm font-bold text-description uppercase tracking-widest mb-2">Ville</label>
                    <input v-model="form.city" type="text" class="w-full bg-slate-950 border border-slate-800 rounded-xl px-4 py-3 text-title focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all" placeholder="Ex: Douala" />
                  </div>
                  <div>
                    <label class="block text-sm font-bold text-description uppercase tracking-widest mb-2">Quartier</label>
                    <input v-model="form.neighborhood" type="text" class="w-full bg-slate-950 border border-slate-800 rounded-xl px-4 py-3 text-title focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all" placeholder="Ex: Akwa" />
                  </div>
                </div>
              </div>
            </transition>
            
            <div class="flex items-center gap-3 p-4 bg-slate-900/50 rounded-xl border border-slate-800 shadow-inner">
              <input 
                v-model="form.isValidated" 
                type="checkbox" 
                id="isValidated" 
                class="w-5 h-5 rounded-lg border-slate-700 bg-slate-950 text-primary focus:ring-primary transition-all cursor-pointer" 
              />
              <label for="isValidated" class="text-sm font-bold text-title cursor-pointer tracking-tight">Utilisateur validé et actif</label>
            </div>

            <!-- Modal Actions -->
            <div class="flex gap-4 pt-4 border-t border-slate-800">
              <button 
                type="button" 
                @click="closeModal" 
                class="flex-1 bg-slate-800 text-title px-6 py-3.5 rounded-xl hover:bg-slate-700 transition-colors font-bold uppercase tracking-widest text-xs"
              >
                Annuler
              </button>
              <button 
                type="submit" 
                :disabled="!form.roleId" 
                class="flex-1 bg-primary text-white px-6 py-3.5 rounded-xl hover:bg-primary-dark transition-all font-bold shadow-lg shadow-primary/20 disabled:opacity-50 uppercase tracking-widest text-xs"
              >
                {{ editingUser ? 'Enregistrer' : 'Créer l\'utilisateur' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </Layout>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import Layout from '~/components/admin/Layout.vue'
import { router } from '@inertiajs/vue3'
import PaginatedList from '~/components/admin/PaginatedList.vue'

const props = defineProps<{
  users: any[]
  roles: any[]
}>()

const userHeaders = [
  { key: 'fullName', label: 'Utilisateur' },
  { key: 'contact', label: 'Contact' },
  { key: 'roles', label: 'Rôles' },
  { key: 'status', label: 'Statut' },
  { key: 'actions', label: 'Actions', cellClass: 'text-right' }
]

const showCreateModal = ref(false)
const editingUser = ref<any>(null)

const form = ref({
  fullName: '',
  email: '',
  phone: '',
  password: '',
  isValidated: true,
  roleId: null as number | null,
  companyName: '',
  city: '',
  neighborhood: '',
})

const resetForm = () => {
  form.value = {
    fullName: '',
    email: '',
    phone: '',
    password: '',
    isValidated: true,
    roleId: null,
    companyName: '',
    city: '',
    neighborhood: '',
  }
  editingUser.value = null
}

const handleCreate = () => {
  resetForm()
  showCreateModal.value = true
}

const handleEdit = (user: any) => {
  editingUser.value = user
  form.value = {
    fullName: user.fullName,
    email: user.email,
    phone: user.phone,
    password: '', 
    isValidated: user.isValidated,
    roleId: user.roles[0]?.id || null,
    companyName: user.companyName || '',
    city: user.city || '',
    neighborhood: user.neighborhood || '',
  }
  showCreateModal.value = true
}

const closeModal = () => {
  showCreateModal.value = false
  resetForm()
}

const submit = () => {
  if (editingUser.value) {
    router.post(`/dashboard/users/${editingUser.value.id}`, form.value, {
      onSuccess: () => closeModal()
    })
  } else {
    router.post('/dashboard/users', form.value, {
      onSuccess: () => closeModal()
    })
  }
}

const deleteUser = (id: number) => {
  if (confirm('Êtes-vous sûr de vouloir supprimer cet utilisateur ?')) {
    router.delete(`/dashboard/users/${id}`)
  }
}
</script>
