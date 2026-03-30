import type { HttpContext } from '@adonisjs/core/http'
import type { NextFn } from '@adonisjs/core/types/http'
import { UserStatus } from '#dto/user_types'

export default class SellerMiddleware {
  async handle({ auth, response }: HttpContext, next: NextFn) {
    const user = auth.user

    if (!user) {
      return response.redirect('/auth/login')
    }

    if (user.role !== UserStatus.SELLER && user.role !== UserStatus.ADMIN) {
      return response.redirect('/')
    }

    return next()
  }
}
