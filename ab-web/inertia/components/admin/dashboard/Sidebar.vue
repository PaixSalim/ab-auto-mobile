<script setup lang="ts">
import { Link, usePage } from '@inertiajs/vue3'
import { computed } from 'vue'
import { usePermissions } from '~/composables/usePermissions'

defineProps<{
  isOpen: boolean
}>()

const page = usePage()
const { isAdminRole, can } = usePermissions()

const logoUrl = '/uploads/logos/logo.png'

const navigation = computed(() => {
  const groups = [
    {
      title: 'Principal',
      items: [
        { label: 'Tableau de bord', route: '/dashboard', icon: 'i-mdi-view-dashboard' },
        { label: 'Boutique', route: '/', icon: 'i-mdi-storefront-outline' },
      ]
    }
  ]

  if (isAdminRole.value) {
    const boutiqueItems = [
      ...(can('view_all_products') || can('manage_all_products') ? [{ label: 'Articles', route: '/dashboard/products', icon: 'i-mdi-package-variant-closed' }] : []),
      ...(can('view_all_orders') || can('manage_all_orders') ? [{ label: 'Commandes', route: '/dashboard/orders', icon: 'i-mdi-cart-outline' }] : []),
      ...(can('view_categories') || can('manage_categories') ? [{ label: 'Catégories', route: '/dashboard/categories', icon: 'i-mdi-folder-outline' }] : []),
      ...(can('view_banners') || can('manage_banners') ? [{ label: 'Bannières', route: '/dashboard/banners', icon: 'i-mdi-image-multiple-outline' }] : []),
      ...(can('view_sellers') || can('validate_sellers') || can('manage_sellers') ? [{ label: 'Vendeurs', route: '/sellers-admin', icon: 'i-mdi-account-tie' }] : []),
      ...(can('view_customers') || can('manage_customers') ? [{ label: 'Clients', route: '/dashboard/customers', icon: 'i-mdi-account-group-outline' }] : []),
      ...(can('view_comments') || can('manage_comments') ? [{ label: 'Commentaires', route: '/dashboard/comments', icon: 'i-mdi-comment-multiple-outline' }] : []),
      ...(can('validate_products') ? [{ label: 'Validation Articles', route: '/dashboard/validation', icon: 'i-mdi-check-circle-outline' }] : []),
      ...(can('view_promotions') || can('manage_promotions') ? [{ label: 'Promotions', route: '/dashboard/promotions', icon: 'i-mdi-tag-outline' }] : []),
      ...(can('view_brands') || can('manage_brands') ? [{ label: 'Marques', route: '/dashboard/brands', icon: 'i-mdi-truck-outline' }] : []),
    ]

    const adminItems = [
      ...(can('view_users') || can('create_users') || can('edit_users') || can('delete_users')
        ? [{ label: 'Utilisateurs', route: '/dashboard/users', icon: 'i-mdi-account-cog-outline' }]
        : []),
      ...(can('view_roles') || can('manage_roles')
        ? [{ label: 'Rôles', route: '/dashboard/roles', icon: 'i-mdi-shield-account-outline' }]
        : []),
      ...(can('assign_permissions')
        ? [{ label: 'Permissions', route: '/dashboard/permissions', icon: 'i-mdi-key-chain-variant' }]
        : []),
    ]

    if (boutiqueItems.length) groups.push({ title: 'Gestion Boutique', items: boutiqueItems })
    if (adminItems.length) groups.push({ title: 'Administration', items: adminItems })
  } else {
    const sellerItems = [
      ...(can('manage_own_products') ? [{ label: 'Mes Produits', route: '/seller/products', icon: 'i-mdi-package-variant' }] : []),
      ...(can('manage_own_orders') ? [{ label: 'Mes Commandes', route: '/seller/orders', icon: 'i-mdi-cart-outline' }] : []),
    ]
    if (sellerItems.length) groups.push({ title: 'Ma Boutique', items: sellerItems })
  }

  return groups
})
</script>

<template>
  <aside
    :class="[
      'text-slate-300 border-r border-slate-800 transform top-0 left-0 w-72 bg-slate-950 h-full overflow-auto ease-in-out transition-all duration-300',
      'sm:translate-x-0 sm:relative sm:z-0',
      isOpen ? 'translate-x-0 z-50' : '-translate-x-full',
      'fixed sm:static',
    ]"
  >
    <div class="p-8 pb-4">
      <div class="flex items-center gap-3">
        <div class="w-10 h-10 bg-primary rounded-xl flex items-center justify-center shadow-lg shadow-primary/20">
           <img :src="logoUrl" class="w-8 h-8 object-contain" alt="Logo" />
        </div>
        <div>
          <span class="text-white text-xl font-bold tracking-tight">Auto-Pro</span>
          <p class="text-[10px] text-slate-500 font-bold uppercase tracking-widest">{{ isAdminRole ? 'Administration' : 'Vendeur' }}</p>
        </div>
      </div>
    </div>

    <nav class="px-4 py-4 space-y-8">
      <div v-for="group in navigation" :key="group.title" class="space-y-2">
        <h5 class="px-4 text-[10px] font-black text-slate-500 uppercase tracking-[0.2em] mb-4">
          {{ group.title }}
        </h5>
        
        <div class="space-y-1">
          <Link
            v-for="nav in group.items"
            :key="nav.route"
            :class="[
              'flex items-center gap-3 px-4 py-3 rounded-xl transition-all duration-200 group',
              page.url === nav.route 
                ? 'bg-primary/10 text-primary shadow-sm' 
                : 'hover:bg-slate-900 text-slate-400 hover:text-slate-200'
            ]"
            :href="nav.route"
          >
            <div :class="[nav.icon, 'text-xl group-hover:scale-110 transition-transform duration-300']"></div>
            <span class="font-medium text-sm">{{ nav.label }}</span>
            <div v-if="page.url === nav.route" class="ml-auto w-1.5 h-1.5 rounded-full bg-primary shadow-glow"></div>
          </Link>
        </div>
      </div>
    </nav>
    

  </aside>
</template>

<style scoped>
.shadow-glow {
  box-shadow: 0 0 10px var(--primary-color);
}
</style>
