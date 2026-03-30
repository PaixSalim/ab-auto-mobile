import type { HttpContext } from '@adonisjs/core/http'
import User from '#models/user'

export default class DebugUsersController {
  async index({ response }: HttpContext) {
    const users = await User.query().select('id', 'fullName', 'email', 'phone', 'role', 'isValidated').orderBy('id', 'desc').limit(10)
    return response.json(users)
  }
}
