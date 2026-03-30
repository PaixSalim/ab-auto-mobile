// import type { HttpContext } from '@adonisjs/core/http'

import type { HttpContext } from '@adonisjs/core/http'
import User from '#models/user'
import Role from '#models/role'
import Product from '#models/product'
import Order from '#models/order'
import Category from '#models/category'
import Brand from '#models/brand'
import Comment from '#models/comment'

export default class DashboardController {
  async index({ inertia, auth }: HttpContext) {
    const user = auth.user!
    await user.load('roles')
    const roles = user.roles.map((r: Role) => r.slug)
    const isAdmin = roles.includes('admin') || roles.includes('superadmin')
    const isSeller = roles.includes('seller')

    // Fetch Stats
    let productsCount = 0
    let ordersCount = 0
    let pendingSellersCount = 0
    let recentProducts: any[] = []
    let pendingSellersList: any[] = []
    let categoriesCount = 0
    let brandsCount = 0
    let customersCount = 0
    let validatedSellersCount = 0
    let pendingProductsCount = 0
    let validatedProductsCount = 0
    let commentsCount = 0
    let recentOrders: any[] = []
    let monthlyStats: any[] = []
    let topCategories: any[] = []
    let topBrands: any[] = []

    if (isAdmin) {
      // Statistiques générales
      productsCount = await Product.query().count('* as total').then(r => Number(r[0].$extras.total))
      ordersCount = await Order.query().count('* as total').then(r => Number(r[0].$extras.total))
      categoriesCount = await Category.query().count('* as total').then(r => Number(r[0].$extras.total))
      brandsCount = await Brand.query().count('* as total').then(r => Number(r[0].$extras.total))

      // Statistiques utilisateurs
      customersCount = await User.query().where('role', 'customer').count('* as total').then(r => Number(r[0].$extras.total))
      pendingSellersCount = await User.query().where('role', 'seller').where('is_validated', false).count('* as total').then(r => Number(r[0].$extras.total))
      validatedSellersCount = await User.query().where('role', 'seller').where('is_validated', true).count('* as total').then(r => Number(r[0].$extras.total))

      // Statistiques produits
      pendingProductsCount = await Product.query().where('validation_status', 'pending').count('* as total').then(r => Number(r[0].$extras.total))
      validatedProductsCount = await Product.query().where('validation_status', 'approved').count('* as total').then(r => Number(r[0].$extras.total))
      
      // Statistiques commentaires
      commentsCount = await Comment.query().count('* as total').then(r => Number(r[0].$extras.total))

      // Données récentes
      recentProducts = await Product.query().preload('category').preload('brand').orderBy('created_at', 'desc').limit(5)
      recentOrders = await Order.query().preload('customer').preload('product').orderBy('created_at', 'desc').limit(5)
      pendingSellersList = await User.query().where('role', 'seller').where('is_validated', false).limit(5)

      // Statistiques mensuelles (6 derniers mois)
      monthlyStats = await Order.query()
        .where('created_at', '>=', new Date(Date.now() - 6 * 30 * 24 * 60 * 60 * 1000))
        .preload('product')
        .preload('customer')
        .orderBy('created_at', 'desc')

      // Top catégories par nombre de produits
      const categoriesWithProductCount = await Category.query()
        .preload('products')
      topCategories = categoriesWithProductCount
        .map(category => ({
          ...category.toJSON(),
          productsCount: category.products.length
        }))
        .sort((a, b) => b.productsCount - a.productsCount)
        .slice(0, 5)

      // Top marques par nombre de produits
      const brandsWithProductCount = await Brand.query()
        .preload('products')
      topBrands = brandsWithProductCount
        .map(brand => ({
          ...brand.toJSON(),
          productsCount: brand.products.length
        }))
        .sort((a, b) => b.productsCount - a.productsCount)
        .slice(0, 5)
    } else if (isSeller) {
      productsCount = await Product.query().where('seller_id', user.id).count('* as total').then(r => Number(r[0].$extras.total))
      ordersCount = await Order.query().whereHas('product', (q) => q.where('seller_id', user.id)).count('* as total').then(r => Number(r[0].$extras.total))
      
      // Statistiques commentaires pour les vendeurs
      commentsCount = await Comment.query()
        .whereHas('product', (query) => query.where('seller_id', user.id))
        .count('* as total')
        .then(r => Number(r[0].$extras.total))

      recentProducts = await Product.query().where('seller_id', user.id).preload('category').preload('brand').orderBy('created_at', 'desc').limit(5)
      recentOrders = await Order.query()
        .whereHas('product', (q) => q.where('seller_id', user.id))
        .preload('customer')
        .preload('product')
        .orderBy('created_at', 'desc')
        .limit(5)
    }

    return inertia.render('dashboard', {
      auth: {
        user: {
          ...user.toJSON(),
          isValidated: user.isValidated || false
        },
        roles: roles
      },
      stats: {
        products: productsCount,
        orders: ordersCount,
        pendingSellers: pendingSellersCount,
        categories: categoriesCount,
        brands: brandsCount,
        customers: customersCount,
        validatedSellers: validatedSellersCount,
        pendingProducts: pendingProductsCount,
        validatedProducts: validatedProductsCount,
        comments: commentsCount
      },
      recentProducts,
      recentOrders,
      pendingSellersList,
      monthlyStats,
      topCategories,
      topBrands
    })
  }
}