import type { HttpContext } from '@adonisjs/core/http'
import User from '#models/user'
import Role from '#models/role'
import { UserStatus } from '#dto/user_types'
import vine from '@vinejs/vine'
import RegistrationNumberGeneratorService from '#services/registration_number_generator_service'

export default class SellersController {
  /**
   * Liste des vendeurs
   */
  async index({ inertia, request }: HttpContext) {
    const page = Number(request.input('page', 1))
    const sellers = await User.query()
      .where('role', UserStatus.SELLER)
      .orderBy('created_at', 'desc')
      .paginate(page, 10)

    return inertia.render('admin/sellers/index', { sellers })
  }

  /**
   * Afficher le formulaire de création d'un vendeur
   */
  async create({ inertia }: HttpContext) {
    return inertia.render('admin/sellers/create')
  }

  /**
   * Créer un nouveau vendeur
   */
  async store({ request, response, session }: HttpContext) {
    const schema = vine.compile(
      vine.object({
        fullName: vine.string().trim().minLength(3),
        email: vine.string().email().normalizeEmail().unique({ table: 'users', column: 'email' }).optional(),
        password: vine.string().minLength(8),
        phone: vine.string().trim().unique({ table: 'users', column: 'phone' }),
      })
    )

    try {
      const data = await request.validateUsing(schema)

      // Normalisation du téléphone
      const cleanPhone = data.phone.replace(/[^\d+]/g, '')

      const user = await User.create({
        fullName: data.fullName,
        email: data.email || null,
        password: data.password,
        phone: cleanPhone,
        role: UserStatus.SELLER,
        isValidated: true,
        registrationNumber: await RegistrationNumberGeneratorService.generate(),
      })

      // Assigner le rôle dans la table pivot
      const role = await Role.findBy('slug', 'seller')
      if (role) {
        await user.related('roles').attach([role.id])
      }

      session.flash('notification', {
        type: 'success',
        message: 'Vendeur créé avec succès'
      })

      return response.redirect().back()
    } catch (error) {
      session.flash('notification', {
        type: 'error',
        message: 'Erreur lors de la création du vendeur: ' + (error.messages ? 'Données invalides' : error.message)
      })
      return response.redirect().back()
    }
  }

  /**
   * Modifier un vendeur
   */
  async edit({ request, response, session }: HttpContext) {
    const schema = vine.compile(
      vine.object({
        id: vine.number(),
        fullName: vine.string().trim().minLength(3),
        email: vine.string().email().normalizeEmail().optional(),
        phone: vine.string().trim(),
        password: vine.string().minLength(8).optional(),
      })
    )

    try {
      const data = await request.validateUsing(schema)
      const seller = await User.findOrFail(data.id)

      if (seller.role !== UserStatus.SELLER) {
        session.flash('notification', { type: 'error', message: 'Utilisateur introuvable' })
        return response.redirect().back()
      }

      // Normalisation du téléphone
      const cleanPhone = data.phone.replace(/[^\d+]/g, '')

      seller.fullName = data.fullName
      seller.email = data.email || null
      seller.phone = cleanPhone
      if (data.password) seller.password = data.password
      await seller.save()

      session.flash('notification', { type: 'success', message: 'Vendeur modifié avec succès' })
      return response.redirect().back()
    } catch (error) {
      session.flash('notification', { type: 'error', message: 'Erreur lors de la modification du vendeur' })
      return response.redirect().back()
    }
  }

  async delete({ params, response, session }: HttpContext) {
    try {
      const seller = await User.findOrFail(params.id)

      if (seller.role !== UserStatus.SELLER) {
        session.flash('notification', {
          type: 'error',
          message: 'Vous ne pouvez supprimer que des vendeurs'
        })
        return response.redirect().back()
      }

      await seller.delete()

      session.flash('notification', {
        type: 'success',
        message: 'Vendeur supprimé avec succès'
      })

      return response.redirect().back()
    } catch (error) {
      session.flash('notification', {
        type: 'error',
        message: 'Erreur lors de la suppression du vendeur'
      })
      return response.redirect().back()
    }
  }

  /**
   * Activer ou désactiver un vendeur
   */
  async toggleValidation({ params, response, session }: HttpContext) {
    try {
      const seller = await User.findOrFail(params.id)

      if (seller.role !== UserStatus.SELLER) {
        session.flash('notification', { type: 'error', message: 'Vendeur introuvable' })
        return response.redirect().back()
      }

      seller.isValidated = !seller.isValidated
      await seller.save()

      session.flash('notification', {
        type: 'success',
        message: seller.isValidated ? 'Vendeur activé avec succès' : 'Vendeur désactivé avec succès'
      })

      return response.redirect().back()
    } catch (error) {
      session.flash('notification', { type: 'error', message: 'Erreur lors du changement de statut' })
      return response.redirect().back()
    }
  }
}
