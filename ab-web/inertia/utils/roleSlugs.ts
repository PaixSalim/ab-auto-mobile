/**
 * Aligné sur `src/auth/role-slug.util.ts` (slugs BDD vs enum Prisma).
 */

const LOWER_TO_CANONICAL: Record<string, string> = {
  administrateur: 'admin',
  administrator: 'admin',
  admin: 'admin',
  superadmin: 'superadmin',
  'super-admin': 'superadmin',
  super_admin: 'superadmin',
  vendeur: 'seller',
  seller: 'seller',
  client: 'customer',
  customer: 'customer',
}

export function canonicalRoleSlug(slug: string): string {
  return LOWER_TO_CANONICAL[slug.toLowerCase()] ?? slug
}

/** Rôle « espace admin » (sidebar dashboard) */
export function isAdminSpaceRole(slug: string): boolean {
  const c = canonicalRoleSlug(slug)
  return c === 'admin' || c === 'superadmin'
}

export function isSuperAdminSlug(slug: string): boolean {
  return canonicalRoleSlug(slug) === 'superadmin'
}
