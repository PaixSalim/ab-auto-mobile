import type { HttpContext } from '@adonisjs/core/http'
import Product from '#models/product'
import Category from '#models/category'
import Brand from '#models/brand'
import Order from '#models/order'
import { OrderStatus } from '#utils/enum'
import { MediaType } from '#dto/products_interface'
import { ValidationStatus } from '#dto/products_interface'

export default class SellerProductsController {
  /**
   * Dashboard vendeur avec statistiques
   */
  async dashboard({ inertia, auth }: HttpContext) {
    // Statistiques pour le dashboard
    const productsCount = await Product.query().where('seller_id', auth.user!.id).count('* as total')
    const ordersCount = await Order.query()
      .whereHas('product', (q) => q.where('seller_id', auth.user!.id))
      .count('* as total')
    const commentsCount = await Product.query()
      .where('seller_id', auth.user!.id)
      .preload('comments')
      .then(products => {
        return products.reduce((total, product) => total + (product.comments?.length || 0), 0)
      })

    const stats = {
      products: Number(productsCount[0].$extras.total),
      orders: Number(ordersCount[0].$extras.total),
      comments: commentsCount,
    }

    return inertia.render('seller/dashboard', { stats })
  }

  /**
   * Dashboard vendeur avec ses produits
   */
  async index({ inertia, auth }: HttpContext) {
    const products = await Product.query()
      .where('seller_id', auth.user!.id)
      .preload('category')
      .preload('brand')
      .preload('medias')
      .orderBy('created_at', 'desc')

    const categories = await Category.query().orderBy('name', 'asc')
    const brands = await Brand.query().orderBy('name', 'asc')

    return inertia.render('seller/products/index', { products, categories, brands })
  }

  /**
   * Commandes sur les produits du vendeur
   */
  async orders({ inertia, auth }: HttpContext) {
    const orders = await Order.query()
      .whereHas('product', (q) => q.where('seller_id', auth.user!.id))
      .preload('product', (q) => q.preload('medias'))
      .orderBy('created_at', 'desc')

    return inertia.render('seller/orders/index', { orders })
  }

  /**
   * Voir les commentaires sur les produits du vendeur
   */
  async comments({ inertia, auth }: HttpContext) {
    const products = await Product.query()
      .where('seller_id', auth.user!.id)
      .preload('comments', (query) => {
        query.whereNull('parent_id').preload('replies').preload('author').orderBy('created_at', 'desc')
      })
      .preload('category')
      .preload('medias')

    return inertia.render('seller/comments/index', { products })
  }

  /**
   * Activer/Désactiver un commentaire
   */
  async toggleCommentStatus({ request, response, session }: HttpContext) {
    const { commentId } = request.only(['commentId'])

    try {
      const Comment = (await import('#models/comment')).default
      const comment = await Comment.findOrFail(commentId)
      comment.isActive = !comment.isActive
      await comment.save()

      session.flash('notification', {
        type: 'success',
        message: comment.isActive ? 'Commentaire activé avec succès' : 'Commentaire désactivé avec succès'
      })

      return response.redirect().back()
    } catch (error) {
      session.flash('notification', {
        type: 'error',
        message: 'Erreur lors de la modification du commentaire'
      })
      return response.redirect().back()
    }
  }

  /**
   * Répondre à un commentaire
   */
  async replyComment({ request, response, auth, session }: HttpContext) {
    const { commentId, comment } = request.only(['commentId', 'comment'])

    try {
      const Comment = (await import('#models/comment')).default
      const parentComment = await Comment.findOrFail(commentId)

      await Comment.create({
        productId: parentComment.productId,
        userId: auth.user!.id,
        parentId: commentId,
        comment: comment,
        user: auth.user!.fullName || 'Vendeur',
        isActive: true,
        ip: request.ip(),
      })

      session.flash('notification', {
        type: 'success',
        message: 'Réponse ajoutée avec succès'
      })

      return response.redirect().back()
    } catch (error) {
      session.flash('notification', {
        type: 'error',
        message: 'Erreur lors de la réponse'
      })
      return response.redirect().back()
    }
  }

  /**
   * Créer un produit
   */
  async create({ request, response, auth, session }: HttpContext) {
    const data = request.only([
      'name',
      'description',
      'price',
      'categoryId',
      'brandId',
      'state',
      'warranty',
      'features',
    ])

    try {
      // Convertir features en tableau si c'est une chaîne
      let features = data.features
      if (typeof features === 'string') {
        features = features.split(',').map((f: string) => f.trim())
      }

      // Créer le produit d'abord
      const product = await Product.create({
        name: data.name,
        description: data.description,
        price: Number(data.price),
        categoryId: Number(data.categoryId),
        brandId: data.brandId ? Number(data.brandId) : undefined, // Rendre brandId optionnel
        state: data.state || 'new',
        warranty: data.warranty || '1 mois',
        features: features || [],
        sellerId: auth.user!.id,
        slug: data.name.toLowerCase().replace(/\s+/g, '-'),
        discount: 0,
        validationStatus: ValidationStatus.PENDING,
      })

      // Gérer les images si elles existent
      if (request.files('images')) {
        const images = request.files('images')
        
        for (let i = 0; i < images.length; i++) {
          const image = images[i]
          if (image && image.tmpPath) {
            // Créer le nom de fichier unique
            const timestamp = Date.now()
            const fileName = `${timestamp}-${image.clientName}`
            
            // Déplacer le fichier vers le dossier uploads
            await image.move('public/uploads/products', {
              name: fileName,
              overwrite: true
            })
            
            // Créer le média pour le produit
            await product.related('medias').create({
              url: `/uploads/products/${fileName}`,
              type: MediaType.IMAGE,
              productId: product.id
            })
          }
        }
      }

      session.flash('notification', {
        type: 'success',
        message: 'Produit créé avec succès'
      })

      return response.redirect().back()
    } catch (error) {
      session.flash('notification', {
        type: 'error',
        message: 'Erreur lors de la création du produit'
      })
      return response.redirect().back()
    }
  }

  /**
   * Modifier un produit
   */
  async edit({ request, response, auth, session }: HttpContext) {
    const { id, ...data } = request.only([
      'id',
      'name',
      'description',
      'price',
      'categoryId',
      'brandId',
      'state',
      'warranty',
      'features',
    ])

    try {
      const product = await Product.query()
        .where('id', id)
        .where('seller_id', auth.user!.id)
        .firstOrFail()

      product.merge(data)
      await product.save()

      // Gérer les images si elles existent
      if (request.files('images')) {
        const images = request.files('images')
        
        for (let i = 0; i < images.length; i++) {
          const image = images[i]
          if (image && image.tmpPath) {
            // Créer le nom de fichier unique
            const timestamp = Date.now()
            const fileName = `${timestamp}-${image.clientName}`
            
            // Déplacer le fichier vers le dossier uploads
            await image.move('public/uploads/products', {
              name: fileName,
              overwrite: true
            })
            
            // Créer le média pour le produit
            await product.related('medias').create({
              url: `/uploads/products/${fileName}`,
              type: MediaType.IMAGE,
              productId: product.id
            })
          }
        }
      }

      session.flash('notification', {
        type: 'success',
        message: 'Produit modifié avec succès'
      })

      return response.redirect().back()
    } catch (error) {
      session.flash('notification', {
        type: 'error',
        message: 'Erreur lors de la modification du produit'
      })
      return response.redirect().back()
    }
  }

  /**
   * Annuler une commande
   */
  async cancelOrder({ request, response, auth, session }: HttpContext) {
    const { orderId } = request.only(['orderId'])

    try {
      const order = await Order.query()
        .whereHas('product', (q) => q.where('seller_id', auth.user!.id))
        .where('id', orderId)
        .firstOrFail()

      await order.merge({
        status: OrderStatus.CANCELLED,
      }).save()

      session.flash('notification', {
        type: 'success',
        message: 'Commande annulée avec succès'
      })

      return response.redirect().back()
    } catch (error) {
      session.flash('notification', {
        type: 'error',
        message: 'Erreur lors de l\'annulation de la commande'
      })
      return response.redirect().back()
    }
  }

  /**
   * Marquer une commande comme livrée
   */
  async deliveredOrder({ request, response, auth, session }: HttpContext) {
    const { orderId } = request.only(['orderId'])

    try {
      const order = await Order.query()
        .whereHas('product', (q) => q.where('seller_id', auth.user!.id))
        .where('id', orderId)
        .firstOrFail()

      await order.merge({
        status: OrderStatus.DELIVERED,
      }).save()

      session.flash('notification', {
        type: 'success',
        message: 'Commande marquée comme livrée avec succès'
      })

      return response.redirect().back()
    } catch (error) {
      session.flash('notification', {
        type: 'error',
        message: 'Erreur lors de la mise à jour de la commande'
      })
      return response.redirect().back()
    }
  }

  /**
   * Supprimer un produit
   */
  async delete({ params, response, auth, session }: HttpContext) {
    try {
      const product = await Product.query()
        .where('id', params.id)
        .where('seller_id', auth.user!.id)
        .firstOrFail()

      await product.delete()

      session.flash('notification', {
        type: 'success',
        message: 'Produit supprimé avec succès'
      })

      return response.redirect().back()
    } catch (error) {
      session.flash('notification', {
        type: 'error',
        message: 'Erreur lors de la suppression du produit'
      })
      return response.redirect().back()
    }
  }
}
