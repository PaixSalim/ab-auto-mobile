import { BaseSchema } from '@adonisjs/lucid/schema'

export default class extends BaseSchema {
  protected tableName = 'products'

  async up() {
    this.schema.createTable(this.tableName, (table) => {
      table.increments('id')
      table.string('name').notNullable()
      table.string('state').nullable().defaultTo('new')
      table.text('description').nullable()
      table.string('slug').nullable()
      table.string('warranty').nullable().defaultTo('1 mois')
      table.decimal('price', 10, 2).notNullable()
      table.decimal('discount', 10, 2).nullable().defaultTo(0)
      table.text('features').nullable()
      table
        .integer('category_id')
        .unsigned()
        .references('id')
        .inTable('categories')
        .onDelete('CASCADE')
      table.integer('brand_id').unsigned().references('id').inTable('brands').onDelete('CASCADE')

      table.timestamp('created_at')
      table.timestamp('updated_at')
    })
  }

  async down() {
    this.schema.dropTable(this.tableName)
  }
}
