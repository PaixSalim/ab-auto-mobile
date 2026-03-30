import { defineConfig } from '@adonisjs/inertia'
import type { InferSharedProps } from '@adonisjs/inertia/types'

const inertiaConfig = defineConfig({
  /**
   * Path to the Edge view that will be used as the root view for Inertia responses
   */
  rootView: 'inertia_layout',

  /**
   * Data that should be shared with all rendered pages
   */
  sharedData: {
    notification: (ctx) => ctx.session.flashMessages.get('notification'),
    auth: async (ctx) => {
      if (!ctx.auth.user) return { user: null, roles: [], permissions: [] }

      const user = ctx.auth.user
      await user.load('roles')
      const roles = user.roles ?? []
      const roleNames = roles.map((r: any) => r.slug)

      // Superadmin gets all permissions implicitly
      const isSuperAdmin = roleNames.includes('superadmin')
      let permissionSlugs: string[] = []
      if (!isSuperAdmin) {
        for (const role of roles) {
          await role.load('permissions')
          const slugs = role.permissions?.map((p: any) => p.slug) ?? []
          permissionSlugs.push(...slugs)
        }
        permissionSlugs = [...new Set(permissionSlugs)]
      }

      return {
        user: {
          id: user.id,
          email: user.email,
          fullName: user.fullName,
          role: user.role,
          isValidated: user.isValidated,
          companyName: user.companyName,
        },
        roles: roleNames,
        permissions: permissionSlugs,
        isSuperAdmin,
      }
    },
  },

  /**
   * Options for the server-side rendering
   */
  ssr: {
    enabled: true,
    entrypoint: 'inertia/app/ssr.ts'
  }
})

export default inertiaConfig

declare module '@adonisjs/inertia/types' {
  export interface SharedProps extends InferSharedProps<typeof inertiaConfig> {}
}