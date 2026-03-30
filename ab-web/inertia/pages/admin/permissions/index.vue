<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import Layout from '~/components/admin/Layout.vue'
import { Head, usePage } from '@inertiajs/vue3'
import axios from 'axios'

const props = defineProps<{
  roles: any[]
  groupedPermissions: Record<string, any[]>
}>()

const page = usePage()
const isSuperAdmin = computed(() => (page.props.auth as any).isSuperAdmin)

const selectedRole = ref(props.roles[0]?.id || null)
const selectedRoleName = computed(() => props.roles.find(r => r.id === selectedRole.value)?.name || '')
const rolePermissions = ref<number[]>([])
const loading = ref(false)
const saving = ref(false)
const saved = ref(false)

// Count permissions per group
const groupCounts = computed(() => {
  const counts: Record<string, number> = {}
  for (const [group, perms] of Object.entries(props.groupedPermissions)) {
    counts[group] = (perms as any[]).filter(p => rolePermissions.value.includes(p.id)).length
  }
  return counts
})

const totalSelected = computed(() => rolePermissions.value.length)
const totalPermissions = computed(() => Object.values(props.groupedPermissions).flat().length)

const fetchRolePermissions = async () => {
  if (!selectedRole.value) return
  loading.value = true
  try {
    const response = await axios.get(`/dashboard/permissions/role/${selectedRole.value}`)
    rolePermissions.value = response.data
  } catch (error) {
  } finally {
    loading.value = false
  }
}

const savePermissions = async () => {
  saving.value = true
  try {
    await axios.post('/dashboard/permissions/sync', {
      roleId: selectedRole.value,
      permissionIds: rolePermissions.value
    })
    saved.value = true
    setTimeout(() => saved.value = false, 2500)
  } catch (error) {
    alert('Erreur lors de la mise à jour')
  } finally {
    saving.value = false
  }
}

const toggleGroup = (permissions: any[]) => {
  const ids = permissions.map((p: any) => p.id)
  const allSelected = ids.every(id => rolePermissions.value.includes(id))
  if (allSelected) {
    rolePermissions.value = rolePermissions.value.filter(id => !ids.includes(id))
  } else {
    rolePermissions.value = [...new Set([...rolePermissions.value, ...ids])]
  }
}

const isGroupFullySelected = (permissions: any[]) =>
  permissions.every((p: any) => rolePermissions.value.includes(p.id))

const groupIcons: Record<string, string> = {
  'Utilisateurs': 'i-mdi-account-group',
  'Configuration': 'i-mdi-cog',
  'Catalogue': 'i-mdi-folder-multiple',
  'Produits': 'i-mdi-package-variant-closed',
  'Vendeurs': 'i-mdi-account-tie',
  'Clients': 'i-mdi-account-heart',
  'Commandes': 'i-mdi-cart',
  'Commentaires': 'i-mdi-comment-text',
  'Promotions': 'i-mdi-percent',
  'Marques': 'i-mdi-tag',
  'Bannières': 'i-mdi-image-multiple',
}

watch(selectedRole, fetchRolePermissions)
onMounted(fetchRolePermissions)
</script>

<template>
  <Head title="Habilitations" />
  <Layout>
    <div class="space-y-8 pb-24">

      <!-- Page Header -->
      <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 class="text-2xl font-black text-slate-900 dark:text-white tracking-tight">Gestion des Habilitations</h1>
          <p class="text-slate-500 mt-1 text-sm">Définissez précisément les actions autorisées pour chaque rôle.</p>
        </div>
        <div v-if="isSuperAdmin" class="inline-flex items-center gap-2 bg-amber-50 border border-amber-200 text-amber-700 text-xs font-bold px-3 py-1.5 rounded-full">
          <div class="i-mdi-shield-crown text-base"></div>
          Superadmin — accès total par défaut
        </div>
      </div>

      <!-- Role Tabs + Stats -->
      <div class="bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-2xl overflow-hidden shadow-sm">
        <!-- Role selector tabs -->
        <div class="flex border-b border-slate-200 dark:border-slate-800 overflow-x-auto">
          <button
            v-for="role in roles"
            :key="role.id"
            @click="selectedRole = role.id"
            class="flex-shrink-0 px-6 py-4 text-sm font-bold transition-all duration-200 border-b-2"
            :class="selectedRole === role.id
              ? 'border-primary text-primary bg-primary/5'
              : 'border-transparent text-slate-500 hover:text-slate-800 dark:hover:text-slate-200'"
          >
            {{ role.name }}
          </button>
        </div>

        <!-- Stats bar -->
        <div class="flex items-center justify-between px-6 py-3 bg-slate-50 dark:bg-slate-950/50">
          <div v-if="loading" class="text-xs text-slate-400">Chargement...</div>
          <div v-else class="flex items-center gap-2 text-sm">
            <span class="font-black text-slate-800 dark:text-white">{{ totalSelected }}</span>
            <span class="text-slate-400">/ {{ totalPermissions }} permissions actives pour</span>
            <span class="font-bold text-primary">{{ selectedRoleName }}</span>
          </div>
          <!-- Progress bar -->
          <div class="hidden sm:block w-48 bg-slate-200 dark:bg-slate-800 rounded-full h-1.5">
            <div
              class="bg-primary h-1.5 rounded-full transition-all duration-500"
              :style="{ width: totalPermissions > 0 ? `${(totalSelected / totalPermissions) * 100}%` : '0%' }"
            ></div>
          </div>
        </div>
      </div>

      <!-- Permissions Grid -->
      <div v-if="loading" class="flex justify-center py-20">
        <div class="animate-spin rounded-full h-10 w-10 border-t-2 border-primary"></div>
      </div>

      <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
        <div
          v-for="(permissions, group) in groupedPermissions"
          :key="group"
          class="bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-2xl overflow-hidden shadow-sm hover:shadow-md transition-all duration-300"
          :class="isGroupFullySelected(permissions as any[]) ? 'ring-2 ring-primary/30 border-primary/30' : ''"
        >
          <!-- Group Header -->
          <div class="flex items-center justify-between p-5 border-b border-slate-100 dark:border-slate-800">
            <div class="flex items-center gap-3">
              <div
                class="w-9 h-9 rounded-xl flex items-center justify-center text-white"
                :class="isGroupFullySelected(permissions as any[]) ? 'bg-primary' : 'bg-slate-200 dark:bg-slate-700'"
              >
                <div :class="[groupIcons[group as string] || 'i-mdi-key', 'text-lg', isGroupFullySelected(permissions as any[]) ? 'text-white' : 'text-slate-500']"></div>
              </div>
              <div>
                <h3 class="font-black text-slate-800 dark:text-white text-sm uppercase tracking-wider">{{ group }}</h3>
                <p class="text-[10px] text-slate-400">{{ groupCounts[group as string] || 0 }} / {{ (permissions as any[]).length }} actif(s)</p>
              </div>
            </div>
            <!-- Toggle All -->
            <button
              @click="toggleGroup(permissions as any[])"
              class="text-[10px] font-bold uppercase tracking-wider transition-colors px-2.5 py-1 rounded-lg"
              :class="isGroupFullySelected(permissions as any[])
                ? 'text-primary bg-primary/10 hover:bg-primary/20'
                : 'text-slate-400 bg-slate-100 dark:bg-slate-800 hover:text-primary'"
            >
              {{ isGroupFullySelected(permissions as any[]) ? 'Tout retirer' : 'Tout cocher' }}
            </button>
          </div>

          <!-- Permission Items -->
          <div class="p-3 space-y-1">
            <label
              v-for="permission in (permissions as any[])"
              :key="permission.id"
              class="flex items-center gap-3 p-3 rounded-xl cursor-pointer transition-all duration-150 group"
              :class="rolePermissions.includes(permission.id)
                ? 'bg-primary/8 text-primary'
                : 'hover:bg-slate-50 dark:hover:bg-slate-800 text-slate-600 dark:text-slate-400'"
            >
              <div
                class="w-5 h-5 rounded-md border-2 flex items-center justify-center transition-all flex-shrink-0"
                :class="rolePermissions.includes(permission.id)
                  ? 'border-primary bg-primary'
                  : 'border-slate-300 dark:border-slate-600 group-hover:border-primary/50'"
              >
                <div v-if="rolePermissions.includes(permission.id)" class="i-mdi-check text-white text-xs"></div>
              </div>
              <input type="checkbox" :value="permission.id" v-model="rolePermissions" class="hidden" />
              <div class="min-w-0">
                <span class="text-sm font-semibold block truncate" :class="rolePermissions.includes(permission.id) ? 'text-primary' : 'text-slate-700 dark:text-slate-300'">
                  {{ permission.name }}
                </span>
                <span class="text-[10px] text-slate-400 font-mono">{{ permission.slug }}</span>
              </div>
            </label>
          </div>
        </div>
      </div>

      <!-- Floating Save Button -->
      <div class="fixed bottom-8 right-8 z-50 flex items-center gap-3">
        <!-- Success toast -->
        <transition
          enter-active-class="transition duration-300 ease-out"
          enter-from-class="opacity-0 translate-y-2"
          enter-to-class="opacity-100 translate-y-0"
          leave-active-class="transition duration-200 ease-in"
          leave-from-class="opacity-100"
          leave-to-class="opacity-0"
        >
          <div v-if="saved" class="bg-green-500 text-white text-sm font-bold px-4 py-3 rounded-xl shadow-lg flex items-center gap-2">
            <div class="i-mdi-check-circle text-lg"></div>
            Permissions enregistrées !
          </div>
        </transition>

        <button
          @click="savePermissions"
          :disabled="saving"
          class="bg-primary hover:bg-primary/90 text-white px-6 py-3.5 rounded-xl font-bold shadow-xl shadow-primary/25 flex items-center gap-2.5 transition-all duration-200 hover:scale-105 active:scale-95 disabled:opacity-60"
        >
          <div v-if="saving" class="animate-spin i-mdi-loading text-lg"></div>
          <div v-else class="i-mdi-content-save text-lg"></div>
          {{ saving ? 'Enregistrement...' : 'Enregistrer' }}
        </button>
      </div>

    </div>
  </Layout>
</template>
