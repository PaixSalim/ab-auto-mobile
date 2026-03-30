import type { HttpContext } from '@adonisjs/core/http'
import Product from '#models/product'

export default class ProductValidationController {
  /**
   * Afficher les produits en attente de validation
   */
  async index({ inertia }: HttpContext) {
    try {
      console.log('ProductValidationController.index appelé')
      
      // Requête simple sans enum pour tester
      const pendingProducts = await Product.query()
        .where('validationStatus', 'pending')
        .preload('seller')
        .preload('category')
        .preload('brand')
        .preload('medias')

      console.log(`Trouvé ${pendingProducts.length} produits en attente`)

      return inertia.render('admin/product_validation/simple', {
        products: pendingProducts,
      })
    } catch (error) {
      console.error('Erreur dans ProductValidationController.index:', error)
      
      // En cas d'erreur, page simple
      return inertia.render('admin/product_validation/simple', {
        products: [],
        error: 'Erreur: ' + error.message
      })
    }
  }

  /**
   * Approuver un produit
   */
  async approve({ request, response, session }: HttpContext) {
    const productId = request.input('productId')
    
    try {
      const product = await Product.findOrFail(productId)
      await product.merge({
        validationStatus: 'approved',
        rejectionReason: null,
      }).save()

      session.flash('notification', {
        type: 'success',
        message: 'Produit approuvé avec succès'
      })
    } catch (error) {
      session.flash('notification', {
        type: 'error',
        message: 'Erreur lors de l\'approbation du produit'
      })
    }

    return response.redirect().back()
  }

  /**
   * Rejeter un produit
   */
  async reject({ request, response, session }: HttpContext) {
    const productId = request.input('productId')
    const reason = request.input('reason')
    
    if (!reason) {
      session.flash('notification', {
        type: 'error',
        message: 'Veuillez fournir une raison de rejet'
      })
      return response.redirect().back()
    }

    try {
      const product = await Product.findOrFail(productId)
      await product.merge({
        validationStatus: 'rejected',
        rejectionReason: reason,
      }).save()

      session.flash('notification', {
        type: 'success',
        message: 'Produit rejeté avec succès'
      })
    } catch (error) {
      session.flash('notification', {
        type: 'error',
        message: 'Erreur lors du rejet du produit'
      })
    }

    return response.redirect().back()
  }

  /**
   * Afficher tous les produits avec leur statut
   */
  async all({ inertia }: HttpContext) {
    try {
      const products = await Product.query()
        .preload('seller')
        .preload('category')
        .preload('brand')
        .preload('medias')

      return inertia.render('admin/product_validation/simple', {
        products,
      })
    } catch (error) {
      console.error('Erreur dans ProductValidationController.all:', error)
      return inertia.render('admin/product_validation/simple', {
        products: [],
        error: 'Erreur: ' + error.message
      })
    }
  }
}
