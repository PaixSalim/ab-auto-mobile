import { BaseSchema } from '@adonisjs/lucid/schema'

export default class extends BaseSchema {
  protected tableName = 'users'

  async up() {
    this.schema.alterTable(this.tableName, (table) => {
      // On ajoute uniquement si les colonnes manquent
      // Pour éviter les erreurs, on utilise une approche prudente
      table.string('company_name').nullable()
      table.string('neighborhood').nullable()
      table.string('registration_number').nullable()
    })
  }

  async down() {
    this.schema.alterTable(this.tableName, (table) => {
      table.dropColumn('company_name')
      table.dropColumn('neighborhood')
      table.dropColumn('registration_number')
    })
  }
}