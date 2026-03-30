import Product from '#models/product'
import Category from '#models/category'
import Brand from '#models/brand'
import Media from '#models/media'
import Promotion from '#models/promotion'
import { DateTime } from 'luxon'
import { capitalize } from '#utils/capitalyze_utils'
import { GetProductDto } from '#dto/products_interface'

export class AdminProductsService {
  async getAllProducts() {
    const products = await Product.query()
      .preload('medias')
      .preload('category')
      .preload('brand')
      .preload('seller')

    const categories = await Category.all()
    const brands = await Brand.all()
    const medias = await Media.all()

    // Récupérer uniquement les promotions en cours
    const currentDate = DateTime.local().toFormat('yyyy-MM-dd HH:mm:ss')
    const promotions = await Promotion.query()
      .where('promo_start_date', '<=', currentDate)
      .where('promo_end_date', '>=', currentDate)

    return products.map((product: Product) => {
      // Trouver la promotion en cours pour ce produit
      const promotion = promotions.find((p) => p.productId === product.id)

      return {
        id: product.id,
        name: capitalize(product.name),
        state: product.state,
        cta: product.cta,
        slug: product.slug,
        description: product.description,
        price: product.price,
        warranty: product.warranty,
        features: product.features,
        discount: promotion ? promotion.discountPercent : 0,
        promo_price: promotion
          ? product.price - (product.price * promotion.discountPercent) / 100
          : product.price,
        medias: medias.filter((media) => media.productId === product.id),
        category: categories.find((category) => category.id === product.categoryId),
        brand: brands.find((brand) => brand.id === product.brandId),
        seller: product.seller ? {
          id: product.seller.id,
          fullName: product.seller.fullName,
          email: product.seller.email,
          phone: product.seller.phone,
          city: product.seller.city,
        } : null,
        validationStatus: product.validationStatus,
        rejectionReason: product.rejectionReason,
      }
    })
  }
}
