import type { HttpContext } from '@adonisjs/core/http'
import { chatbotValidator } from '#validators/chatbot_validator'
import { ChatbotService } from '#services/admin/chatbot_service'
import { inject } from '@adonisjs/core'
import { StoreService } from '#services/store_service'
import { DateTime } from 'luxon'

@inject()
export default class ChatbotsController {
  constructor(
    private chatbotService: ChatbotService,
    private storeService: StoreService
  ) {}
  async description({ request, response, logger }: HttpContext) {
    logger.info(
      '[%s] Chatbot: %s - Method: %s - IP: %s',
      DateTime.local().toISO(),
      request.url(),
      request.method(),
      request.ip()
    )
    const payload = await request.validateUsing(chatbotValidator)
    const res = await this.chatbotService.generateDescription(payload.prompt)
    return response.status(201).send(res)
  }
  async features({ request, response, logger }: HttpContext) {
    logger.info(
      '[%s] Chatbot: %s - Method: %s - IP: %s',
      DateTime.local().toISO(),
      request.url(),
      request.method(),
      request.ip()
    )
    const payload = await request.validateUsing(chatbotValidator)

    const res = await this.chatbotService.generateFeatures(payload.prompt)
    return response.json(res.features)
  }
  async chat({ request, response, logger }: HttpContext) {
    logger.info(
      '[%s] Chatbot: %s - Method: %s - IP: %s',
      DateTime.local().toISO(),
      request.url(),
      request.method(),
      request.ip()
    )
    const payload = await request.validateUsing(chatbotValidator)
    const products = await this.storeService.getProductsWeb()
    const res = await this.chatbotService.chat(payload.prompt, products)
    return response.json(res)
  }

  async feedback({ request, response }: HttpContext) {
    console.log(request.all())
    return response.ok({ isSent: true })
  }
}
