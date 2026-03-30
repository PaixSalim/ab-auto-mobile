import { BaseSeeder } from '@adonisjs/lucid/seeders'
import { DateTime } from 'luxon'
import Product from '#models/product'
import Promotion from '#models/promotion'

export default class extends BaseSeeder {
  async run() {
    const products = await Product.all()

    if (products.length === 0) {
      console.log('Aucun produit trouvé. Ajoute d’abord des produits avant de lancer ce seeder.')
      return
    }

    const promotionsData = products.slice(0, 3).map((product) => ({
      productId: product.id,
      url: 'https://cdn.autodoc.de/thumb?id=16592559&m=1&n=0&lng=fr&rev=94077846',
      discountPercent: 20,
      promoLabel: 'Profitez à max',
      promoStartDate: DateTime.now().minus({ days: 1 }),
      promoEndDate: DateTime.now().plus({ days: 3 }),
    }))

    await Promotion.createMany(promotionsData)

    console.log(`✅ ${promotionsData.length} promotions ajoutées avec succès !`)
  }
}
