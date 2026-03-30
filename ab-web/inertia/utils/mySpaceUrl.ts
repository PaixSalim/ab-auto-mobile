/**
 * URL de l’espace personnel selon le rôle.
 * Aligné avec `src/auth/post-auth-redirect.ts`.
 *
 * Côté Inertia, `getUserWithPermissions` envoie :
 * - `auth.user` (sans relation `roles` sur l’objet user)
 * - `auth.roles` : slugs normalisés (`admin`) ou legacy (`administrateur` → traité via `canonicalRoleSlug`)
 */
import { canonicalRoleSlug, isAdminSpaceRole } from '~/utils/roleSlugs'

function slugSet(
  userRoles: { slug: string }[] | string[] | undefined,
  sharedSlugs: string[] | undefined,
): Set<string> {
  const s = new Set<string>()
  if (Array.isArray(sharedSlugs)) {
    sharedSlugs.forEach((x) => s.add(canonicalRoleSlug(x)))
  }
  if (!Array.isArray(userRoles)) return s
  for (const r of userRoles) {
    if (typeof r === 'string') s.add(canonicalRoleSlug(r))
    else if (r && typeof r === 'object' && 'slug' in r)
      s.add(canonicalRoleSlug(r.slug))
  }
  return s
}

export function getMySpaceUrl(
  user: { role?: string; roles?: { slug: string }[] | string[] } | null | undefined,
  /** Slugs issus de `page.props.auth.roles` (souvent nécessaire : non présents sur `user`) */
  authRoleSlugs?: string[],
): string {
  if (!user?.role) return '/auth/login'

  const slugs = slugSet(user.roles, authRoleSlugs)

  if (user.role === 'superadmin' || user.role === 'admin') {
    return '/dashboard'
  }
  for (const s of slugs) {
    if (isAdminSpaceRole(s)) return '/dashboard'
  }

  if (user.role === 'seller' || [...slugs].some((x) => canonicalRoleSlug(x) === 'seller')) {
    return '/seller/products'
  }

  return '/orders'
}

/** Utilise `auth` tel que renvoyé par InertiaMiddleware (`auth.user` + `auth.roles`). */
export function getMySpaceUrlFromAuth(auth: {
  user?: { role?: string; roles?: { slug: string }[] | string[] }
  roles?: string[]
} | null | undefined): string {
  return getMySpaceUrl(auth?.user, auth?.roles)
}
