import { canonicalRoleSlug } from './role-slug.util';

/**
 * Cible après connexion / inscription (enum `User.role` + slugs table `roles`).
 * Slugs BDD ex. `administrateur` sont normalisés vers `admin`.
 */
function collectRoleSlugs(user: {
  role: string;
  roles?: { slug: string }[] | string[];
}): Set<string> {
  const slugs = new Set<string>();
  if (!Array.isArray(user.roles)) return slugs;
  for (const r of user.roles) {
    if (typeof r === 'string') slugs.add(canonicalRoleSlug(r));
    else if (r && typeof r === 'object' && 'slug' in r)
      slugs.add(canonicalRoleSlug(r.slug));
  }
  return slugs;
}

export function resolveMySpacePath(user: {
  role: string;
  roles?: { slug: string }[] | string[];
}): string {
  const slugs = collectRoleSlugs(user);

  if (
    user.role === 'superadmin' ||
    user.role === 'admin' ||
    slugs.has('superadmin') ||
    slugs.has('admin')
  ) {
    return '/dashboard';
  }

  if (user.role === 'seller' || slugs.has('seller')) {
    return '/seller/products';
  }

  // Client (customer) : espace commandes / compte
  return '/orders';
}

export function resolvePostAuthRedirect(user: {
  role: string;
  roles?: { slug: string }[];
}): string {
  return resolveMySpacePath(user);
}
