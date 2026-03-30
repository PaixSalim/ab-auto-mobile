import mail from '@adonisjs/mail/services/main'
import env from '#start/env'
import { SendingOrderEmailDto } from '#dto/order_dto'
import { logJson } from '#utils/log_utils'

export class EmailService {
  #mailFrom = env.get('MAIL_FROM_ADDRESS')
  #mailTo = env.get('MAIL_TO_ADDRESS')
  #mailTo1 = env.get('MAIL_TO_ADDRESS1')
  async sendPendingOrderEmail(payload: SendingOrderEmailDto): Promise<boolean> {
    try {
      await mail.send((message) => {
        message
          .from(this.#mailFrom, 'Auto-Pro')
          .to(this.#mailTo)
          .subject('Commande passée sur Auto-Pro')
          .htmlView('emails/order-notification', {
            phoneNumber: payload.phoneNumber,
            customerName: payload.customerName,
            orderId: payload.orderId,
            city: payload.city,
            productName: payload.productName,
            productPrice: payload.productPrice,
            quantity: payload.quantity,
            date: payload.date,
          })
      })
      await mail.send((message) => {
        message
          .from(this.#mailFrom, 'Auto-Pro')
          .to(this.#mailTo1)
          .subject('Commande passée sur Auto-Pro')
          .htmlView('emails/order-notification', {
            phoneNumber: payload.phoneNumber,
            customerName: payload.customerName,
            orderId: payload.orderId,
            productName: payload.productName,
            productPrice: payload.productPrice,
            quantity: payload.quantity,
            date: payload.date,
          })
      })
      return true
    } catch (e) {
      logJson({
        message: 'Unable to send email email',
        error: e.message,
      })
      return false
    }
  }
}
