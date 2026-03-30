import type { HttpContext } from '@adonisjs/core/http'
import type { NextFn } from '@adonisjs/core/types/http'

export default class AdminMiddleware {
  async handle({ auth, response }: HttpContext, next: NextFn) {
    const user = auth.user

    if (!user) {
      return response.redirect('/auth/login')
    }

    // Check roles via pivot table (role_user) OR the legacy user.role column
    await user.load('roles')
    const roleNames = user.roles?.map((r: any) => r.slug) ?? []
    const isAdmin = roleNames.includes('admin') || roleNames.includes('superadmin') || user.role === 'admin'

    if (!isAdmin) {
      return response.redirect('/')
    }

    return next()
  }
}
