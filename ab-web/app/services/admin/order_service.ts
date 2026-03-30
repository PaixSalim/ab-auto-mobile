import Order from '#models/order'
import { EmailService } from '#services/email/email_service'
import { formatDate } from '#utils/format_date_utils'
import { CreateOrderDto } from '#dto/order_dto'
import { inject } from '@adonisjs/core'
import Product from '#models/product'

@inject()
export class OrderService {
  constructor(private mailService: EmailService) {}
  async createOrder(payload: CreateOrderDto): Promise<boolean> {
    const order = await Order.create(payload)
    const product = await Product.findOrFail(payload.productId)
    return await this.mailService.sendPendingOrderEmail({
      orderId: order.id,
      customerName: payload.customerName,
      phoneNumber: payload.phoneNumber,
      city: payload.city,
      productName: product.name,
      productPrice: product.price,
      quantity: payload.quantity,
      date: formatDate(new Date().toString()),
    })
  }
}
