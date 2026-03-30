import { BaseSchema } from '@adonisjs/lucid/schema'

export default class extends BaseSchema {
  protected tableName = 'add_slug_to_products'

  async up() {
    this.schema.alterTable('products', (table) => {
      table.string('slug').notNullable().defaultTo('slug').alter()
    })
  }

  async down() {
    this.schema.alterTable('products', (table) => {
      table.string('slug').nullable().alter()
    })
  }
}
