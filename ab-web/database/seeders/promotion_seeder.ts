import { BaseSeeder } from '@adonisjs/lucid/seeders'
import Promotion from '#models/promotion'
import Product from '#models/product'
import { DateTime } from 'luxon'

export default class extends BaseSeeder {
  async run() {
    // Récupérer quelques produits existants
    const products = await Product.query().limit(5)
    
    if (products.length === 0) {
      console.log('Aucun produit trouvé pour créer des promotions')
      return
    }

    // Créer quelques promotions de test
    const promotions = [
      {
        productId: products[0]?.id || 1,
        promoLabel: 'SOLDES2024',
        discountPercent: 20,
        promoStartDate: DateTime.now().minus({ days: 1 }),
        promoEndDate: DateTime.now().plus({ days: 30 }),
        url: 'https://auto-cdn.uvatis.com/default-promotion.jpg'
      },
      {
        productId: products[1]?.id || 2,
        promoLabel: 'PROMOFLASH',
        discountPercent: 15,
        promoStartDate: DateTime.now(),
        promoEndDate: DateTime.now().plus({ days: 7 }),
        url: 'https://auto-cdn.uvatis.com/default-promotion.jpg'
      },
      {
        productId: products[2]?.id || 3,
        promoLabel: 'OFFRE_SPECIALE',
        discountPercent: 30,
        promoStartDate: DateTime.now().plus({ days: 1 }),
        promoEndDate: DateTime.now().plus({ days: 14 }),
        url: 'https://auto-cdn.uvatis.com/default-promotion.jpg'
      }
    ]

    await Promotion.createMany(promotions)
    console.log('Promotions de test créées avec succès')
  }
}