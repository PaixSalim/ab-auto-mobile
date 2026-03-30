import type { HttpContext } from '@adonisjs/core/http'
import type { NextFn } from '@adonisjs/core/types/http'
import Role from '#models/role'

export default class InertiaAuthMiddleware {
  async handle(ctx: HttpContext, next: NextFn) {
    const { auth, inertia } = ctx

    if (auth.user) {
      // Charger les rôles et leurs permissions
      // On utilise une approche robuste pour éviter les problèmes de typage ou de chargement profond
      await auth.user.load('roles' as any)
      
      const roles = auth.user.roles.map((role: Role) => role.slug)
      
      // Charger les permissions pour chaque rôle
      const permissionSlugs: string[] = []
      for (const role of auth.user.roles) {
        await role.load('permissions' as any)
        role.permissions.forEach((p: any) => {
          if (!permissionSlugs.includes(p.slug)) {
            permissionSlugs.push(p.slug)
          }
        })
      }

      inertia.share({
        auth: {
          user: auth.user,
          roles,
          permissions: permissionSlugs,
        },
      })
    } else {
      inertia.share({
        auth: {
          user: null,
          roles: [],
          permissions: [],
        },
      })
    }

    return next()
  }
}
