import Category from '#models/category'
import Brand from '#models/brand'
import Product from '#models/product'
import Media from '#models/media'
import Promotion from '#models/promotion'
import { DateTime } from 'luxon'
import { GetProductDto } from '#dto/products_interface'
import { ValidationStatus } from '#dto/products_interface'
import Banner from '#models/banner'
import Partner from '#models/partner'
import { capitalize } from '#utils/capitalyze_utils'
import { getMediaUrlsFor } from '#utils/get_medias_url_array'

export class StoreService {
  async getOneProduct(id: number) {
    const product = await Product.query()
      .where('id', id)
      .where('validation_status', ValidationStatus.APPROVED)
      .preload('seller')
      .first()
    
    if (!product) {
      return
    }

    const currentDate = DateTime.local().toFormat('yyyy-MM-dd HH:mm:ss')
    const promo = await Promotion.query()
      .where('productId', product.id)
      .andWhere('promo_start_date', '<=', currentDate)
      .andWhere('promo_end_date', '>=', currentDate)
      .first()
    const category = await Category.find(product.categoryId)
    const brand = await Brand.find(product.brandId)
    const medias = await Media.findManyBy('productId', product.id)
    return {
      id: product.id,
      name: product.name,
      state: product.state,
      warranty: product.warranty,
      description: product.description,
      price: product.price,
      features: product.features,
      discount: promo ? promo.discountPercent : 0,
      medias: medias,
      category: category,
      brand: brand,
      seller: product.seller,
    }
  }
  async getProductsWeb() {
    const products = await Product.query().where('validation_status', ValidationStatus.APPROVED)
    const categories = await Category.all()
    const brands = await Brand.all()
    const medias = await Media.all()
    const users = await Product.query()
      .whereNotNull('seller_id')
      .where('validation_status', ValidationStatus.APPROVED)
      .preload('seller')

    // Récupérer uniquement les promotions en cours
    const currentDate = DateTime.local().toFormat('yyyy-MM-dd HH:mm:ss')
    const promotions = await Promotion.query()
      .where('promo_start_date', '<=', currentDate)
      .where('promo_end_date', '>=', currentDate)

    return products.map((product: Product) => {
      // Trouver la promotion en cours pour ce produit
      const promotion = promotions.find((promo) => promo.productId === product.id)
      
      // Trouver le vendeur pour ce produit
      const productWithSeller = users.find((p) => p.id === product.id)
      const seller = productWithSeller?.seller

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
        seller: seller ? {
          id: seller.id,
          fullName: seller.fullName,
          email: seller.email,
          phone: seller.phone,
        } : null,
      } as GetProductDto
    })
  }

  async getProducts() {
    const products = await Product.query().where('validation_status', ValidationStatus.APPROVED)
    const categories = await Category.all()
    const brands = await Brand.all()
    const medias = await Media.all()

    // Charger les vendeurs
    const productsWithSellers = await Product.query()
      .whereNotNull('seller_id')
      .where('validation_status', ValidationStatus.APPROVED)
      .preload('seller')

    // Récupérer uniquement les promotions en cours
    const currentDate = DateTime.local().toFormat('yyyy-MM-dd HH:mm:ss')
    const promotions = await Promotion.query()
      .where('promo_start_date', '<=', currentDate)
      .where('promo_end_date', '>=', currentDate)

    return products.map((product: Product) => {
      const promotion = promotions.find((promo) => promo.productId === product.id)
      const productWithSeller = productsWithSellers.find((p) => p.id === product.id)
      const seller = productWithSeller?.seller

      return {
        id: product.id,
        name: capitalize(product.name),
        state: product.state,
        slug: product.slug,
        description: product.description,
        price: product.price,
        cta: product.cta,
        warranty: product.warranty,
        features: product.features,
        discount: promotion ? promotion.discountPercent : 0,
        promo_price: promotion
          ? product.price - (product.price * promotion.discountPercent) / 100
          : product.price,
        medias: getMediaUrlsFor(product.id, medias),
        category: categories.find((category) => category.id === product.categoryId),
        brand: brands.find((brand) => brand.id === product.brandId),
        seller: seller ? {
          id: seller.id,
          fullName: seller.fullName,
          email: seller.email,
          phone: seller.phone,
        } : null,
      }
    })
  }

  /**
   * Before
   *   async getCategories({ response }: HttpContext) {
   *     const categories = await Category.all()
   *     const products = await Product.all()
   *     const all = categories.map((category: Category) => {
   *       const categoryProducts = products.filter((p) => p.categoryId === category.id)
   *       if (categoryProducts.length > 0) {
   *         return {
   *           id: category.id,
   *           name: category.name,
   *           url: category.url,
   *           items: categoryProducts.length,
   *         }
   *       }
   *     })
   *     return response.ok(all)
   *   }
   */
  async getCategories() {
    const categories = await Category.query()
      .select('categories.id', 'categories.name', 'categories.url')
      .leftJoin('products', 'products.category_id', 'categories.id')
      .groupBy('categories.id', 'categories.name', 'categories.url')
      .count('products.id as items')

    // Filtrer les catégories ayant au moins un produit
    const filteredCategories = categories.filter((category) => category.$extras.items > 0)

    // Récupérer les marques par catégorie en une seule requête
    const brandsByCategory = await Product.query()
      .select('category_id', 'brand_id')
      .whereNotNull('brand_id')
      .distinct()
      .then((products) => {
        const brandMap = new Map<number, Set<number>>()
        products.forEach(({ categoryId, brandId }) => {
          if (!brandMap.has(categoryId)) {
            brandMap.set(categoryId, new Set())
          }
          brandMap.get(categoryId)?.add(brandId)
        })
        return brandMap
      })

    // Charger toutes les marques une seule fois
    const brands = await Brand.all()

    return filteredCategories.map((category) => ({
      id: category.id,
      name: category.name,
      url: category.url,
      items: category.$extras.items,
      brands: brands
        .filter((brand) => brandsByCategory.get(category.id)?.has(brand.id))
        .map((brand) => ({
          id: brand.id,
          name: brand.name,
          url: brand.url,
        })),
    }))
  }

  /**
   * * Before better impl
   * const products = await Product.findManyBy('categoryId', 5)
   *     const brands = await Brand.all()
   *
   *     const brandsForProductIndex = [...new Set(products.map((product: Product) => product.brandId))]
   *
   *     const categoryBrands = brands.filter((b: Brand) => {
   *       return brandsForProductIndex.includes(b.id)
   *     })
   */
  async getBrandsByCategory(categoryId: number) {
    return Brand.query().whereIn(
      'id',
      Product.query().select('brandId').where('categoryId', categoryId)
    )
  }
  async getBrands() {
    return Brand.query().select('id', 'name', 'url').has('products')
  }

  async getPromotedProducts() {
    const currentDate = DateTime.local().toFormat('yyyy-MM-dd HH:mm:ss')
    console.log('Current date for promotion filter:', currentDate)
    
    // Temporairement: afficher toutes les promotions pour que la vôtre soit visible
    const promotedProducts = await Promotion.query()
      .select(
        'promotions.id as promotion_id',
        'products.id',
        'products.name',
        'products.slug',
        'products.price as original_price',
        'promotions.discount_percent',
        'promotions.url',
        'promotions.promo_start_date',
        'promotions.promo_end_date',
        'categories.id as category_id',
        'categories.name as category_name'
      )
      // Temporairement désactivé pour voir toutes les promotions
      // .where('promo_start_date', '<=', currentDate)
      // .where('promo_end_date', '>=', currentDate)
      .innerJoin('products', 'promotions.product_id', 'products.id')
      .innerJoin('categories', 'products.category_id', 'categories.id')

    console.log('Found all promotions (no date filter):', promotedProducts.length)
    
    return promotedProducts.map((promotion) => {
      let imageUrl = promotion.url || null
      
      // CORRECTION : Remplacer toutes les URLs externes par l'image par défaut locale
      if (imageUrl) {
        if (imageUrl.startsWith('https://auto-cdn.uvatis.com/') || 
            imageUrl.startsWith('https://cdn.autodoc.de/')) {
          console.log('🔄 Replacing external URL with local default:', imageUrl)
          imageUrl = '/uploads/products/default-product.jpg'
        }
      }
      
      // Pour les fichiers locaux, s'assurer que l'URL commence par /
      if (imageUrl && !imageUrl.startsWith('http') && !imageUrl.startsWith('/')) {
        imageUrl = '/' + imageUrl
      }
      
      console.log('🔍 PROMOTION DEBUG:', {
        promotionId: promotion.$extras.promotion_id,
        productId: promotion.id,
        productName: promotion.$extras.name,
        originalUrl: promotion.url,
        finalUrl: imageUrl,
        startDate: promotion.$extras.promo_start_date,
        endDate: promotion.$extras.promo_end_date,
        isActive: promotion.$extras.promo_start_date <= currentDate && promotion.$extras.promo_end_date >= currentDate
      })
      
      return {
        id: promotion.id,
        name: promotion.$extras.name,
        slug: promotion.$extras.slug,
        url: imageUrl, // URL corrigée
        originalPrice: promotion.$extras.original_price,
        discountPercent: promotion.discountPercent,
        promoPrice:
          promotion.$extras.original_price -
          (promotion.$extras.original_price * promotion.discountPercent) / 100,
        category: promotion.$extras.category_name,
      }
    })
  }

  async getBanners() {
    return Banner.query().select('id', 'title', 'description', 'image', 'link')
  }

  async getPartners() {
    return Partner.query().select('id', 'image', 'label')
  }

  async getCategoryTree() {
    const categories = await Category.query()
      .whereNull('parentId')
      .preload('subCategories', (query) => {
        query.preload('subCategories') // Load up to 2 levels for now, or use recursive function if needed
      })
    return categories
  }
}
