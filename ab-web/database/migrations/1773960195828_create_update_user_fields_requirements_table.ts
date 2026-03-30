import { BaseSchema } from '@adonisjs/lucid/schema'

export default class extends BaseSchema {
  protected tableName = 'users'

  async up() {
    this.schema.alterTable(this.tableName, (table) => {
      // Le téléphone devient obligatoire et doit être unique
      table.string('phone').notNullable().unique().alter()
      
      // L'email devient optionnel (s'il ne l'était pas déjà)
      table.string('email').nullable().alter()
    })
  }

  async down() {
    this.schema.alterTable(this.tableName, (table) => {
      table.string('phone').nullable().alter()
      table.string('email').notNullable().alter()
    })
  }
}