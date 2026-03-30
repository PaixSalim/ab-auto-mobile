import type { HttpContext } from '@adonisjs/core/http'
import Category from '#models/category'
import Product from '#models/product'
import Brand from '#models/brand'
import Media from '#models/media'
import User from '#models/user'
import { UserStatus } from '#dto/user_types'
import { createProductValidator, editProductValidator } from '#validators/product_validator'
import { ProductServices } from '#services/admin/product_services'
import { AdminProductsService } from '#services/admin/admin_products_service'
import { inject } from '@adonisjs/core'
import { StoreService } from '#services/store_service'
import { DateTime } from 'luxon'
import { EditType } from '#dto/edit_type'

@inject()
export default class AdminController {
  constructor(
    private productService: ProductServices,
    private storeService: StoreService,
    private adminProductsService: AdminProductsService
  ) {}
  async index({ inertia, logger, request }: HttpContext) {
    logger.info(
      '[%s] Admin: %s - Method: %s - IP: %s',
      DateTime.local().toISO(),
      request.url(),
      request.method(),
      request.ip()
    )

    return inertia.render('admin/index', {
      products: inertia.defer(() => this.productService.getProducts()),
      orders: inertia.defer(() => this.productService.getOrders()),
      promotions: inertia.defer(() => this.productService.getPromotions()),
      sellers: inertia.defer(() => User.query().where('role', UserStatus.SELLER).count('* as total').then(r => Number(r[0].$extras.total))),
      customers: inertia.defer(() => User.query().where('role', UserStatus.CUSTOMER).count('* as total').then(r => Number(r[0].$extras.total))),
      pendingValidations: await Product.query().where('validationStatus', 'pending').count('* as total').then(r => Number(r[0].$extras.total)),
    })
  }

  async products({ inertia, logger, request }: HttpContext) {
    logger.info(
      '[%s] Admin: %s - Method: %s - IP: %s',
      DateTime.local().toISO(),
      request.url(),
      request.method(),
      request.ip()
    )
    const brands = await Brand.all()
    const categories = await Category.all()

    // Utiliser le service admin qui voit TOUS les produits (sans filtre de validation)
    const all = await this.adminProductsService.getAllProducts()

    return inertia.render('admin/products', {
      products: all,
      categories: categories,
      brands: brands,
    })
  }

  async create({ request, response, logger, session }: HttpContext) {
    logger.info(
      '[%s] Admin: %s - Method: %s - IP: %s',
      DateTime.local().toISO(),
      request.url(),
      request.method(),
      request.ip()
    )
    
    // Récupérer les fichiers envoyés avec images[0], images[1], etc.
    const files = request.files('images')
    console.log('🔍 Admin product create - files received:', files.length)
    console.log('🔍 Files details:', files.map(f => ({ name: f.fileName, size: f.size, tmpPath: f.tmpPath })))
    
    if (files.length === 0) {
      session.flash('notification', {
        type: 'error',
        message: 'Aucune image reçue'
      })
      return response.redirect().back()
    }
    
    const payload = await request.validateUsing(createProductValidator)
    if (payload.features && typeof payload.features === 'string') {
      payload.features = JSON.parse(payload.features)
    }
    
    const product = await this.productService.createProducts(payload)
    await this.productService.uploadProductFiles(files, product, EditType.CREATE)
    
    session.flash('notification', {
      type: 'success',
      message: 'Produit créé avec succès'
    })
    
    return response.redirect().back()
  }

  async edit({ response, request, logger, session }: HttpContext) {
    logger.info(
      '[%s] Admin: %s - Method: %s - IP: %s',
      DateTime.local().toISO(),
      request.url(),
      request.method(),
      request.ip()
    )
    const payload = await request.validateUsing(editProductValidator)

    if (payload.features && typeof payload.features === 'string') {
      payload.features = JSON.parse(payload.features)
    }
    const product = await this.productService.editProduct(payload)

    const files = request.files('images')
    if (files) {
      await this.productService.uploadProductFiles(files, product, EditType.EDIT)
    }
    
    session.flash('notification', {
      type: 'success',
      message: 'Produit modifié avec succès'
    })
    
    return response.redirect().back()
  }
  async delete({ response, params, logger, request, session }: HttpContext) {
    logger.info(
      '[%s] Admin: %s - Method: %s - IP: %s',
      DateTime.local().toISO(),
      request.url(),
      request.method(),
      request.ip()
    )
    const id = params.id
    const product = await Product.findOrFail(id)
    const medias = await Media.findManyBy('product_id', id)
    await product.delete()
    for (const media of medias) {
      await media.delete()
    }
    
    session.flash('notification', {
      type: 'success',
      message: 'Produit supprimé avec succès'
    })
    
    return response.redirect().back()
  }
}
