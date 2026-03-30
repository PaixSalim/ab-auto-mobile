// import type { HttpContext } from '@adonisjs/core/http'

import vine from '@vinejs/vine'
import type { HttpContext } from '@adonisjs/core/http'
import User from '#models/user'
import { DateTime } from 'luxon'

export default class LoginController {
  static validator = vine.compile(
    vine.object({
      uid: vine.string(),
      password: vine.string(),
    })
  )

  render(ctx: HttpContext) {
    ctx.logger.info(
      '[%s] Login Page: %s - Method: %s - IP: %s',
      DateTime.local().toISO(),
      ctx.request.url(),
      ctx.request.method(),
      ctx.request.ip()
    )
    return ctx.inertia.render('auth/login')
  }

  async execute({ auth, request, response, logger, session }: HttpContext) {
    logger.info(
      '[%s] Login: %s - Method: %s - IP: %s',
      DateTime.local().toISO(),
      request.url(),
      request.method(),
      request.ip()
    )
    const data = await request.validateUsing(LoginController.validator)

    // Normalisation de l'UID (Email ou Téléphone)
    // On retire les espaces et caractères spéciaux si c'est un numéro de téléphone
    let uid = data.uid.trim()
    if (!uid.includes('@')) {
      uid = uid.replace(/[^\d+]/g, '')
    }

    logger.info('Tentative de connexion: UID normalisé = %s', uid)

    try {
      // Vérifier d'abord si l'utilisateur existe
      const userFound = await User.query()
        .where('email', uid)
        .orWhere('phone', uid)
        .first()

      if (!userFound) {
        logger.warn('Aucun utilisateur trouvé avec l\'identifiant: %s', uid)
        session.flash('errors', { uid: 'Identifiant (Email ou Téléphone) non reconnu.' })
        return response.redirect().back()
      }

      logger.info('Utilisateur trouvé: %s (ID: %s). Vérification du mot de passe...', userFound.fullName, userFound.id)

      const user = (await User.verifyCredentials(uid, data.password)) as User
      logger.info('Vérification réussie pour ID: %s', user.id)

      await auth.use('web').login(user)

      session.flash('notification', {
        type: 'success',
        message: `Bienvenue ${user.fullName || user.email}`,
      })

      // Rediriger selon le rôle
      const roles = await user.related('roles').query()
      const roleNames = roles.map((r: any) => r.slug)

      if (roleNames.includes('admin') || roleNames.includes('superadmin')) {
        return response.redirect('/dashboard')
      } else if (roleNames.includes('seller')) {
        return response.redirect('/seller')
      } else {
        return response.redirect('/')
      }
    } catch (error) {
      session.flash('errors', { uid: 'Email/Téléphone ou mot de passe incorrect.' })
      return response.redirect().back()
    }
  }

  async logout({ auth, response, request, logger }: HttpContext) {
    logger.info(
      '[%s] Logout: %s - Method: %s - IP: %s',
      DateTime.local().toISO(),
      request.url(),
      request.method(),
      request.ip()
    )
    await auth.use('web').logout()
    return response.redirect().toRoute('index')
  }
}
