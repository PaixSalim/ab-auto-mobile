import type { HttpContext } from '@adonisjs/core/http'
import User from '#models/user'
import Role from '#models/role'
import { UserStatus } from '#dto/user_types'
import vine from '@vinejs/vine'

export default class CustomersController {
  async index({ inertia }: HttpContext) {
    const customers = await User.query()
      .where('role', UserStatus.CUSTOMER)
      .orderBy('created_at', 'desc')

    return inertia.render('admin/customers/index', { customers })
  }

  async create({ request, response, session }: HttpContext) {
    const schema = vine.compile(
      vine.object({
        fullName: vine.string().trim().minLength(3),
        email: vine.string().email().normalizeEmail(),
        password: vine.string().minLength(8),
        phone: vine.string().trim().optional(),
      })
    )

    try {
      const data = await request.validateUsing(schema)

      const user = await User.create({
        fullName: data.fullName,
        email: data.email,
        password: data.password,
        phone: data.phone || null,
        role: UserStatus.CUSTOMER,
        isValidated: true,
      })

      // Assigner le rôle dans la table pivot
      const role = await Role.findBy('slug', 'customer')
      if (role) {
        await user.related('roles').attach([role.id])
      }

      session.flash('notification', { type: 'success', message: 'Client créé avec succès' })
      return response.redirect().back()
    } catch (error) {
      session.flash('notification', { type: 'error', message: 'Erreur lors de la création du client' })
      return response.redirect().back()
    }
  }

  async edit({ request, response, session }: HttpContext) {
    const schema = vine.compile(
      vine.object({
        id: vine.number(),
        fullName: vine.string().trim().minLength(3),
        email: vine.string().email().normalizeEmail(),
        phone: vine.string().trim().optional(),
        password: vine.string().minLength(8).optional(),
      })
    )

    try {
      const data = await request.validateUsing(schema)
      const customer = await User.findOrFail(data.id)

      if (customer.role !== UserStatus.CUSTOMER) {
        session.flash('notification', { type: 'error', message: 'Utilisateur introuvable' })
        return response.redirect().back()
      }

      customer.fullName = data.fullName
      customer.email = data.email
      customer.phone = data.phone || null
      if (data.password) customer.password = data.password
      await customer.save()

      session.flash('notification', { type: 'success', message: 'Client modifié avec succès' })
      return response.redirect().back()
    } catch (error) {
      session.flash('notification', { type: 'error', message: 'Erreur lors de la modification du client' })
      return response.redirect().back()
    }
  }

  async delete({ params, response, session }: HttpContext) {
    try {
      const customer = await User.findOrFail(params.id)

      if (customer.role !== UserStatus.CUSTOMER) {
        session.flash('notification', { type: 'error', message: 'Vous ne pouvez supprimer que des clients' })
        return response.redirect().back()
      }

      await customer.delete()

      session.flash('notification', { type: 'success', message: 'Client supprimé avec succès' })
      return response.redirect().back()
    } catch (error) {
      session.flash('notification', { type: 'error', message: 'Erreur lors de la suppression du client' })
      return response.redirect().back()
    }
  }
}
