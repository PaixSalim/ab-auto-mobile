import type { HttpContext } from '@adonisjs/core/http'
import Role from '#models/role'
import vine from '@vinejs/vine'

export default class RolesController {
  async index({ inertia }: HttpContext) {
    const roles = await Role.all()
    return inertia.render('admin/roles/index', { roles })
  }

  async store({ request, response }: HttpContext) {
    const validator = vine.compile(
      vine.object({
        name: vine.string().trim(),
        slug: vine.string().trim().toLowerCase(),
      })
    )

    const data = await request.validateUsing(validator)
    await Role.create(data)
    
    return response.redirect().back()
  }

  async update({ params, request, response }: HttpContext) {
    const role = await Role.findOrFail(params.id)
    
    const validator = vine.compile(
      vine.object({
        name: vine.string().trim().optional(),
        slug: vine.string().trim().toLowerCase().optional(),
      })
    )

    const data = await request.validateUsing(validator)
    role.merge(data)
    await role.save()

    return response.redirect().back()
  }

  async destroy({ params, response }: HttpContext) {
    const role = await Role.findOrFail(params.id)
    await role.delete()
    return response.redirect().back()
  }
}