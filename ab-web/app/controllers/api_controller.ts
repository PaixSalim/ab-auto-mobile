import type { HttpContext } from '@adonisjs/core/http'
import { StoreService } from '#services/store_service'
import { inject } from '@adonisjs/core'
import { getBrandsByCategoryValidator } from '#validators/category_validator'
import { OrderService } from '#services/admin/order_service'
import { CreateOrderValidator } from '#validators/order_validator'
import { logJson } from '#utils/log_utils'
import { DateTime } from 'luxon'
import { PostCommentValidator, GetCommentValidator } from '#validators/comment_validator'
import { CommentsService } from '#services/admin/comments_service'

@inject()
export default class ApiController {
  constructor(
    private storeService: StoreService,
    private orderService: OrderService,
    private commentsService: CommentsService
  ) {}
  async getOneProduct({ response, params, logger, request }: HttpContext) {
    logger.info(
      '[%s] API: %s - Method: %s - IP: %s',
      DateTime.local().toISO(),
      request.url(),
      request.method(),
      request.ip()
    )
    return response.ok(await this.storeService.getOneProduct(params.id))
  }
  async getProducts({ response, logger, request }: HttpContext) {
    logger.info(
      '[%s] API: %s - Method: %s - IP: %s',
      DateTime.local().toISO(),
      request.url(),
      request.method(),
      request.ip()
    )
    return response.ok(await this.storeService.getProducts())
  }
  async getCategories({ response, logger, request }: HttpContext) {
    logger.info(
      '[%s] API: %s - Method: %s - IP: %s',
      DateTime.local().toISO(),
      request.url(),
      request.method(),
      request.ip()
    )
    return response.ok(await this.storeService.getCategories())
  }
  async getBanners({ response, logger, request }: HttpContext) {
    logger.info(
      '[%s] API: %s - Method: %s - IP: %s',
      DateTime.local().toISO(),
      request.url(),
      request.method(),
      request.ip()
    )
    return response.ok(await this.storeService.getBanners())
  }
  async getBrands({ response, logger, request }: HttpContext) {
    logger.info(
      '[%s] API: %s - Method: %s - IP: %s',
      DateTime.local().toISO(),
      request.url(),
      request.method(),
      request.ip()
    )
    return response.ok(await this.storeService.getBrands())
  }
  async getBrandsByCategory({ request, response, logger }: HttpContext) {
    logger.info(
      '[%s] API: %s - Method: %s - IP: %s',
      DateTime.local().toISO(),
      request.url(),
      request.method(),
      request.ip()
    )
    const categoryId = await request.validateUsing(getBrandsByCategoryValidator)
    return response.ok(await this.storeService.getBrandsByCategory(categoryId.categoryId))
  }
  async getPromotedProducts({ response, logger, request }: HttpContext) {
    logger.info(
      '[%s] API: %s - Method: %s - IP: %s',
      DateTime.local().toISO(),
      request.url(),
      request.method(),
      request.ip()
    )
    return response.ok(await this.storeService.getPromotedProducts())
  }

  async getPartnersBrands({ response, logger, request }: HttpContext) {
    logger.info(
      '[%s] API: %s - Method: %s - IP: %s',
      DateTime.local().toISO(),
      request.url(),
      request.method(),
      request.ip()
    )
    return response.ok(await this.storeService.getPartners())
  }

  async postOrder({ response, request, auth, logger }: HttpContext) {
    logger.info(
      '[%s] API: %s - Method: %s - IP: %s',
      DateTime.local().toISO(),
      request.url(),
      request.method(),
      request.ip()
    )
    const payload = await request.validateUsing(CreateOrderValidator)
    const order = await this.orderService.createOrder({
      ...payload,
      userId: auth.user?.id ?? payload.userId,
    })
    const acceptType = request.header('Accept') || ''

    if (acceptType.includes('application/json')) {
      logJson({ method: 'POST', userAgent: 'Mobile-App', payload })
      return response.ok(order)
    } else {
      logJson({ method: 'POST', userAgent: 'Web-App', payload })
      return response.redirect().back()
    }
  }

  async postComment(ctx: HttpContext) {
    const payload = await ctx.request.validateUsing(PostCommentValidator)
    return ctx.response.ok(
      await this.commentsService.createComments({
        ...payload,
        userId: ctx.auth.user?.id ?? payload.userId,
        ip: ctx.request.ip(),
        isActive: false,
      })
    )
  }

  async getCommentsByProduct(ctx: HttpContext) {
    const payload = await ctx.request.validateUsing(GetCommentValidator)
    return ctx.response.ok(await this.commentsService.getCommentsById(payload.productId))
  }

  //V2

  async getProductsWeb({ response, logger, request }: HttpContext) {
    logger.info(
      '[%s] API: %s - Method: %s - IP: %s',
      DateTime.local().toISO(),
      request.url(),
      request.method(),
      request.ip()
    )
    return response.ok(await this.storeService.getProductsWeb())
  }
}
