import type { HttpContext } from '@adonisjs/core/http'
import Category from '#models/category'
import Brand from '#models/brand'
import { StoreService } from '#services/store_service'
import { inject } from '@adonisjs/core'
import { DateTime } from 'luxon'

@inject()
export default class StoreController {
  constructor(private storeService: StoreService) {}
  async index({ inertia, logger, request }: HttpContext) {
    logger.info(
      '[%s] Store: %s - Method: %s - IP: %s',
      DateTime.local().toISO(),
      request.url(),
      request.method(),
      request.ip()
    )
    const banners = await this.storeService.getBanners()
    const partners = await this.storeService.getPartners()
    const products = await this.storeService.getProductsWeb()
    const categories = await Category.query().orderBy('name', 'asc')
    
    return inertia.render('home', {
      banners,
      partners,
      products,
      categories,
    })
  }
  async catalogue({ inertia, request, logger }: HttpContext) {
    logger.info(
      '[%s] Store: %s - Method: %s - IP: %s',
      DateTime.local().toISO(),
      request.url(),
      request.method(),
      request.ip()
    )
    const { category, brand } = request.qs()

    const categoryModel = category ? await Category.findBy('name', category) : null
    const brandPModel = brand ? await Brand.findBy('name', brand) : null

    return inertia.render('catalogue', {
      categoryName: categoryModel?.name,
      brandName: brandPModel?.name,
    })
  }

  async view(ctx: HttpContext) {
    ctx.logger.info(
      '[%s] Store: %s - Method: %s - IP: %s',
      DateTime.local().toISO(),
      ctx.request.url(),
      ctx.request.method(),
      ctx.request.ip()
    )
    const slug = ctx.params.slug

    const products = await this.storeService.getProductsWeb()
    const product = products.find((p) => p.slug === slug)
    if (!product) {
      return ctx.response.redirect().toRoute('index')
    } else {
      const similarProducts = products.filter(
        (p) => p.category!.name === product.category!.name && p.id !== product.id
      )
      
      // Charger les commentaires du produit
      const Comment = (await import('#models/comment')).default
      const comments = await Comment.query()
        .where('product_id', product.id)
        .whereNull('parent_id')
        .preload('replies')
        .orderBy('created_at', 'desc')
      
      return ctx.inertia.render('view', {
        product,
        similarProducts,
        comments,
      })
    }
  }
}
