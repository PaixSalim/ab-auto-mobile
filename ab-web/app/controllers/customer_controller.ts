import type { HttpContext } from '@adonisjs/core/http'
import Comment from '#models/comment'
import Order from '#models/order'
import { DateTime } from 'luxon'

export default class CustomerController {
  /**
   * Afficher les commandes du client connecté
   */
  async orders({ auth, response, logger, request }: HttpContext) {
    logger.info(
      '[%s] Customer Orders: %s - Method: %s - IP: %s',
      DateTime.local().toISO(),
      request.url(),
      request.method(),
      request.ip()
    )

    const user = auth.user!
    
    const orders = await Order.query()
      .where('userId', user.id)
      .preload('product')
      .preload('customer')
      .orderBy('createdAt', 'desc')

    return response.json(orders)
  }

  /**
   * Afficher les commentaires du client connecté
   */
  async comments({ auth, response, logger, request }: HttpContext) {
    logger.info(
      '[%s] Customer Comments: %s - Method: %s - IP: %s',
      DateTime.local().toISO(),
      request.url(),
      request.method(),
      request.ip()
    )

    const user = auth.user!
    
    const comments = await Comment.query()
      .where('userId', user.id)
      .preload('product')
      .preload('author')
      .orderBy('createdAt', 'desc')

    return response.json(comments)
  }

  /**
   * Afficher la page des commandes du client
   */
  async renderOrders({ inertia, auth }: HttpContext) {
    const user = auth.user!
    
    const orders = await Order.query()
      .where('userId', user.id)
      .preload('product')
      .preload('customer')
      .orderBy('createdAt', 'desc')

    return inertia.render('customer/orders', { orders })
  }

  /**
   * Afficher la page des commentaires du client
   */
  async renderComments({ inertia, auth }: HttpContext) {
    const user = auth.user!
    
    const comments = await Comment.query()
      .where('userId', user.id)
      .preload('product')
      .preload('author')
      .orderBy('createdAt', 'desc')

    return inertia.render('customer/comments', { comments })
  }
}
