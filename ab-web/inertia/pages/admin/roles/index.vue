<script setup lang="ts">
import { ref } from 'vue'
import Layout from '~/components/admin/Layout.vue'
import { router } from '@inertiajs/vue3'
import PaginatedList from '~/components/admin/PaginatedList.vue'

const props = defineProps<{
  roles: any[]
}>()

const roleHeaders = [
  { key: 'name', label: 'Nom du Rôle' },
  { key: 'slug', label: 'Slug / Identifiant' },
  { key: 'actions', label: 'Actions', cellClass: 'text-right' }
]

const showCreateModal = ref(false)
const editingRole = ref<any>(null)

const form = ref({
  name: '',
  slug: ''
})

const handleCreate = () => {
  form.value = { name: '', slug: '' }
  editingRole.value = null
  showCreateModal.value = true
}

const handleEdit = (role: any) => {
  editingRole.value = role
  form.value = { name: role.name, slug: role.slug }
  showCreateModal.value = true
}

const closeModal = () => {
  showCreateModal.value = false
  editingRole.value = null
  form.value = { name: '', slug: '' }
}

const submit = () => {
  if (editingRole.value) {
    router.post(`/dashboard/roles/${editingRole.value.id}`, form.value, {
      onSuccess: () => closeModal()
    })
  } else {
    router.post('/dashboard/roles', form.value, {
      onSuccess: () => closeModal()
    })
  }
}

const deleteRole = (id: number) => {
  if (confirm('Êtes-vous sûr de vouloir supprimer ce rôle ?')) {
    router.delete(`/dashboard/roles/${id}`)
  }
}
</script>

<template>
  <Layout title="Gestion des Rôles">
    <div class="px-6 py-8">
      <div class="flex justify-between items-center mb-8">
        <div>
          <h1 class="text-3xl font-bold text-title mb-1">Rôles</h1>
          <p class="text-description text-sm">Définissez les niveaux d'accès de votre équipe</p>
        </div>
        <button
          @click="handleCreate"
          class="bg-primary hover:bg-primary-dark text-white font-bold py-2.5 px-6 rounded-xl shadow-lg shadow-primary/20 transition-all flex items-center gap-2 group"
        >
          <div class="i-mdi-shield-plus text-xl group-hover:scale-110 transition-transform"></div>
          Nouveau Rôle
        </button>
      </div>

      <PaginatedList
        :items="roles"
        :headers="roleHeaders"
        :items-per-page="10"
        item-name="rôles"
        empty-message="Aucun rôle configuré."
      >
        <template #cell-name="{ item }">
          <div class="flex items-center gap-3">
            <div class="w-8 h-8 rounded-lg bg-primary/10 flex items-center justify-center">
              <div class="i-mdi-shield-outline text-primary text-lg"></div>
            </div>
            <div class="font-bold text-title">{{ item.name }}</div>
          </div>
        </template>
        
        <template #cell-slug="{ item }">
          <span class="px-2 py-0.5 bg-slate-800 text-description text-[10px] font-mono uppercase tracking-widest rounded border border-slate-700">
            {{ item.slug }}
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
              v-if="!['admin', 'superadmin', 'seller', 'customer'].includes(item.slug)"
              @click="deleteRole(item.id)"
              class="text-red-400 hover:text-red-300 flex items-center gap-1.5 transition-colors group"
              title="Supprimer"
            >
              <div class="i-mdi-delete text-lg group-hover:scale-110 transition-transform"></div>
              <span class="text-xs font-bold uppercase tracking-wider">Supprimer</span>
            </button>
          </div>
        </template>
      </PaginatedList>

      <!-- Modal Role -->
      <div v-if="showCreateModal" class="fixed inset-0 bg-slate-950/80 backdrop-blur-sm flex items-center justify-center z-50 p-4">
        <div class="bg-background-secondary border border-slate-800 rounded-2xl shadow-2xl w-full max-w-md overflow-hidden transform transition-all">
          <div class="p-6 border-b border-slate-800 flex justify-between items-center bg-slate-900/50">
            <h2 class="text-xl font-bold text-title">{{ editingRole ? 'Modifier le rôle' : 'Nouveau rôle' }}</h2>
            <button @click="closeModal" class="text-slate-400 hover:text-white transition-colors">
              <div class="i-mdi-close text-2xl"></div>
            </button>
          </div>
          
          <form @submit.prevent="submit" class="p-8 space-y-6">
            <div>
              <label class="block text-sm font-bold text-description uppercase tracking-widest mb-2">Nom du rôle *</label>
              <input 
                v-model="form.name" 
                type="text" 
                class="w-full bg-slate-950 border border-slate-800 rounded-xl px-4 py-3 text-title focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all" 
                placeholder="Ex: Responsable Marketing"
                required 
              />
            </div>
            
            <div>
              <label class="block text-sm font-bold text-description uppercase tracking-widest mb-2">Slug (Identifiant technique) *</label>
              <input 
                v-model="form.slug" 
                type="text" 
                class="w-full bg-slate-950 border border-slate-800 rounded-xl px-4 py-3 text-title font-mono focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all" 
                placeholder="ex: marketing_manager"
                required 
              />
              <p class="text-[10px] text-description mt-2 italic opacity-60">Utilisé pour les vérifications de permissions dans le code.</p>
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
