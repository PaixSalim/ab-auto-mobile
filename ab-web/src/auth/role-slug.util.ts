import { UserRole } from '@prisma/client';

/**
 * Slugs alternatifs en base (ex. « administrateur ») vs enum Prisma `admin`.
 * Utilisé pour charger le bon `Role` et normaliser `auth.roles` côté Inertia.
 */
export const ROLE_SLUG_LOOKUP: Record<UserRole, string[]> = {
  [UserRole.customer]: ['customer', 'client'],
  [UserRole.seller]: ['seller', 'vendeur'],
  [UserRole.admin]: ['admin', 'administrateur', 'administrator'],
  [UserRole.superadmin]: ['superadmin', 'super-admin', 'super_admin'],
};

const LOWER_SLUG_TO_CANONICAL: Record<string, UserRole> = {};

for (const [canonical, slugs] of Object.entries(ROLE_SLUG_LOOKUP) as [
  UserRole,
  string[],
][]) {
  LOWER_SLUG_TO_CANONICAL[canonical.toLowerCase()] = canonical;
  for (const s of slugs) {
    LOWER_SLUG_TO_CANONICAL[s.toLowerCase()] = canonical;
  }
}

/** Slugs à tester en base pour un enum `User.role` */
export function prismaSlugsForEnum(role: UserRole): string[] {
  return ROLE_SLUG_LOOKUP[role] ?? [role];
}

/** Normalise un slug de table `roles` vers l’enum (ex. administrateur → admin). */
export function canonicalRoleSlug(slug: string): string {
  const c = LOWER_SLUG_TO_CANONICAL[slug.toLowerCase()];
  return c ?? slug;
}
