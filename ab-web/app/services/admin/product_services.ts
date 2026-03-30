import Media from '#models/media'
import { generateSlug } from '#utils/slug_utils'
import Product from '#models/product'
import { MediaType } from '#dto/products_interface'
import { EditType } from '#dto/edit_type'

export class ProductServices {
  async createProducts(payload: any) {
    const product = await Product.create({
      name: payload.name,
      description: payload.description,
      cta: payload.cta,
      slug: generateSlug(payload.name),
      price: payload.price,
      state: payload.state,
      features: payload.features,
      brandId: payload.brandId || undefined, // Rendre brandId optionnel
      categoryId: payload.categoryId,
      validationStatus: 'approved', // Les produits admin sont automatiquement approuvés
    })

    if (payload.video) {
      await Media.create({
        productId: product.id,
        type: MediaType.VIDEO,
        url: payload.video,
      })
    }
    return product
  }

  async editProduct(payload: any) {
    const product = await Product.query().where('id', payload.id).preload('medias').firstOrFail()

    await product
      .merge({
        name: payload.name ?? product.name,
        cta: payload.cta ?? product.cta,
        categoryId: payload.categoryId ?? product.categoryId,
        brandId: payload.brandId ?? product.brandId, // Conserver la valeur existante si null
        description: payload.description ?? product.description,
        price: payload.price ?? product.price,
        features: payload.features ?? product.features,
      })
      .save()

    if (payload.remove) {
      payload.remove = JSON.parse(payload.remove)
      for (const media of payload.remove) {
        const mediaToRemove = await Media.find(media)
        await mediaToRemove?.delete()
      }
    }
    if (payload.video) {
      await Media.create({
        productId: product.id,
        type: MediaType.VIDEO,
        url: payload.video,
      })
    }
    return product
  }
  async uploadProductFiles(images: any[], prod: Product, type: EditType): Promise<any> {
    let url: string = ''
    let i = type === EditType.CREATE ? 0 : prod.medias.length
    for (const file of images) {
      if (i <= 5) {
        const timestamp = Date.now()
        const fileName = `${timestamp}-${file.clientName}`
        
        try {
          // Utiliser la même méthode que le seller
          await file.move('public/uploads/products', {
            name: fileName,
            overwrite: true
          })
          
          // Construire l'URL locale
          url = `/uploads/products/${fileName}`
          console.log('✅ Product image uploaded:', url)
        } catch (error) {
          console.error('Erreur lors de l\'enregistrement du fichier :', error)
          // Utiliser l'image par défaut locale en cas d'erreur
          url = '/uploads/products/default-product.jpg'
        }
        i++

        await Media.create({
          productId: prod.id,
          type: MediaType.IMAGE,
          url: url,
        })
      }
    }
  }
  async getProducts() {
    const products = await Product.all()
    return products.length
  }
  async getPromotions() {
    const { default: Promotion } = await import('#models/promotion')
    const promotions = await Promotion.all()
    return promotions.length
  }
  async getOrders() {
    const { default: Order } = await import('#models/order')
    const orders = await Order.all()
    return orders.length
  }
  async getBrands() {
    return await Product.all()
  }
}
