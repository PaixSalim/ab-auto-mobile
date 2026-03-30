import type { HttpContext } from '@adonisjs/core/http'
import Product from '#models/product'

export default class CheckDbStatusesController {
  async index({ response }: HttpContext) {
    try {
      // Vérifier tous les statuts de validation
      const allProducts = await Product.query().select('id', 'name', 'validationStatus')
      
      const stats = {
        total: allProducts.length,
        pending: allProducts.filter(p => p.validationStatus === 'pending').length,
        approved: allProducts.filter(p => p.validationStatus === 'approved').length,
        rejected: allProducts.filter(p => p.validationStatus === 'rejected').length,
        null: allProducts.filter(p => p.validationStatus === null).length,
        undefined: allProducts.filter(p => p.validationStatus === undefined).length,
      }
      
      // Afficher quelques exemples
      const examples = allProducts.slice(0, 5).map(p => ({
        id: p.id,
        name: p.name,
        validationStatus: p.validationStatus,
        statusType: typeof p.validationStatus
      }))
      
      return response.json({
        stats,
        examples,
        message: 'Statut de validation des produits dans la base de données'
      })
    } catch (error) {
      return response.json({
        error: 'Erreur: ' + error.message,
        stack: error.stack
      })
    }
  }
}