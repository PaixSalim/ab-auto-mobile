import type { HttpContext } from '@adonisjs/core/http'
import { OrderValidator } from '#validators/order_validator'
import Order from '#models/order'
import { OrderStatus } from '#utils/enum'

export default class OrdersController {
  async index({ inertia }: HttpContext) {
    const orders = await Order.query()
      .preload('product', (productQuery) => {
        productQuery.preload('medias').preload('seller')
      })
    return inertia.render('admin/orders', {
      orders,
    })
  }

  async cancel({ request, response, session }: HttpContext) {
    const payload = await request.validateUsing(OrderValidator)
    const order = await Order.findOrFail(payload.orderId)
    await order
      .merge({
        status: OrderStatus.CANCELLED,
      })
      .save()

    session.flash('notification', {
      type: 'success',
      message: 'Commande annulée avec succès'
    })

    return response.redirect().toRoute('admin.orders')
  }

  async delete({ request, response, session }: HttpContext) {
    const payload = await request.validateUsing(OrderValidator)
    const order = await Order.findOrFail(payload.orderId)
    await order.delete()

    session.flash('notification', {
      type: 'success',
      message: 'Commande supprimée avec succès'
    })

    return response.redirect().toRoute('admin.orders')
  }

  async delivered({ request, response, session }: HttpContext) {
    const payload = await request.validateUsing(OrderValidator)
    const order = await Order.findOrFail(payload.orderId)
    await order
      .merge({
        status: OrderStatus.DELIVERED,
      })
      .save()

    session.flash('notification', {
      type: 'success',
      message: 'Commande marquée comme livrée'
    })

    return response.redirect().toRoute('admin.orders')
  }
}
