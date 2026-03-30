import { computed } from 'vue'
import { usePage } from '@inertiajs/vue3'
import { canonicalRoleSlug, isAdminSpaceRole, isSuperAdminSlug } from '~/utils/roleSlugs'

/**
 * Permissions Inertia (`auth.permissions` = slugs) alignées sur la table `permissions`.
 * `superadmin` et `admin` ont un accès complet au menu ; les autres rôles sont filtrés par slugs.
 * Les slugs BDD peuvent être `administrateur` / `admin` — normalisation via `roleSlugs`.
 */
export function usePermissions() {
  const page = usePage()
  const auth = computed(() => (page.props.auth as Record<string, unknown>) || {})
  const roles = computed(() => (auth.value.roles as string[]) || [])
  const permissions = computed(() => (auth.value.permissions as string[]) || [])

  const isSuperAdmin = computed(() =>
    roles.value.some((s) => isSuperAdminSlug(s)),
  )
  /**
   * `isAdminFullAccess` kept for backward compatibility but no longer bypasses `can()`.
   * Superadmin is the only role with implicit full access.
   */
  const isAdminFullAccess = computed(() =>
    roles.value.some((s) => canonicalRoleSlug(s) === 'admin'),
  )
  /** Admin UI (sidebar « Administration ») */
  const isAdminRole = computed(() => roles.value.some((s) => isAdminSpaceRole(s)))
  const isSellerRole = computed(() =>
    roles.value.some((s) => canonicalRoleSlug(s) === 'seller'),
  )

  /**
   * Vérifie une permission par slug.
   * Seul superadmin a accès complet implicite ; admin doit avoir les permissions assignées en BDD.
   */
  const can = (slug: string) => {
    if (isSuperAdmin.value) return true
    return permissions.value.includes(slug)
  }

  return {
    auth,
    roles,
    permissions,
    isSuperAdmin,
    isAdminFullAccess,
    isAdminRole,
    isSellerRole,
    can,
  }
}
