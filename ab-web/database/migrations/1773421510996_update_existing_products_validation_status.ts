import { BaseSchema } from '@adonisjs/lucid/schema'

export default class extends BaseSchema {
  protected tableName = 'products'

  async up() {
    // Mettre à jour tous les produits existants pour qu'ils soient approuvés
    this.db.from(this.tableName).whereNull('validation_status').update({
      'validation_status': 'approved'
    })
  }

  async down() {
    // Remettre les produits existants en NULL
    this.db.from(this.tableName).where('validation_status', 'approved').update({
      'validation_status': null
    })
  }
}
