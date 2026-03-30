import type { HttpContext } from '@adonisjs/core/http'
import User from '#models/user'
import Role from '#models/role'
import { UserStatus } from '#dto/user_types'
import vine from '@vinejs/vine'

export default class UsersController {
  async index({ inertia }: HttpContext) {
    const users = await User.query().preload('roles').orderBy('created_at', 'desc')
    const roles = await Role.all()
    
    return inertia.render('admin/users/index', { users, roles })
  }

  async store({ request, response, session }: HttpContext) {
    const validator = vine.compile(
      vine.object({
        fullName: vine.string().trim(),
        email: vine.string().email().unique({ table: 'users', column: 'email' }).optional(),
        phone: vine.string().trim().unique({ table: 'users', column: 'phone' }),
        password: vine.string().minLength(8),
        isValidated: vine.boolean().optional(),
        roleId: vine.number(),
        // Seller specific fields
        companyName: vine.string().trim().optional(),
        city: vine.string().trim().optional(),
        neighborhood: vine.string().trim().optional(),
      })
    )

    try {
      const data = await request.validateUsing(validator)
      
      // Normalisation du téléphone
      const cleanPhone = data.phone.replace(/[^\d+]/g, '')

      // Find the role to determine the UserStatus
      const role = await Role.findOrFail(data.roleId)
      let userStatus = UserStatus.CUSTOMER
      if (role.slug === 'superadmin' || role.slug === 'admin') {
        userStatus = UserStatus.ADMIN
      } else if (role.slug === 'seller') {
        userStatus = UserStatus.SELLER
      }

      const user = await User.create({
        fullName: data.fullName,
        email: data.email || null,
        phone: cleanPhone,
        password: data.password,
        role: userStatus,
        isValidated: data.isValidated ?? true,
        companyName: data.companyName,
        city: data.city,
        neighborhood: data.neighborhood,
      })

      // Assigner le rôle dans la table pivot (nécessaire pour l'authentification/redirection)
      await user.related('roles').attach([role.id])

      session.flash('notification', { type: 'success', message: 'Utilisateur créé' })
      return response.redirect().back()
    } catch (error) {
      session.flash('notification', { type: 'error', message: 'Erreur: ' + (error.message || 'Données invalides') })
      return response.redirect().back()
    }
  }

  async update({ params, request, response, session }: HttpContext) {
    try {
      const user = await User.findOrFail(params.id)
      
      const validator = vine.compile(
        vine.object({
          fullName: vine.string().trim().optional(),
          email: vine.string().email().optional(),
          phone: vine.string().trim().optional(),
          isValidated: vine.boolean().optional(),
          roleId: vine.number().optional(),
          companyName: vine.string().trim().optional(),
          city: vine.string().trim().optional(),
          neighborhood: vine.string().trim().optional(),
        })
      )

      const data = await request.validateUsing(validator)
      
      if (data.roleId) {
        const role = await Role.findOrFail(data.roleId)
        let userStatus = UserStatus.CUSTOMER
        if (role.slug === 'superadmin' || role.slug === 'admin') {
          userStatus = UserStatus.ADMIN
        } else if (role.slug === 'seller') {
          userStatus = UserStatus.SELLER
        }
        user.role = userStatus
        await user.related('roles').sync([data.roleId])
      }

      const updateData: any = {
        fullName: data.fullName,
        email: data.email || null,
        isValidated: data.isValidated,
        companyName: data.companyName,
        city: data.city,
        neighborhood: data.neighborhood,
      }

      if (data.phone) {
        updateData.phone = data.phone.replace(/[^\d+]/g, '')
      }

      user.merge(updateData)
      await user.save()

      session.flash('notification', { type: 'success', message: 'Utilisateur mis à jour' })
      return response.redirect().back()
    } catch (error) {
      session.flash('notification', { type: 'error', message: 'Erreur lors de la mise à jour' })
      return response.redirect().back()
    }
  }

  async destroy({ params, response, session }: HttpContext) {
    try {
      const user = await User.findOrFail(params.id)
      await user.delete()
      session.flash('notification', { type: 'success', message: 'Utilisateur supprimé' })
      return response.redirect().back()
    } catch (error) {
      session.flash('notification', { type: 'error', message: 'Erreur lors de la suppression' })
      return response.redirect().back()
    }
  }
}