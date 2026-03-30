import { BaseSchema } from '@adonisjs/lucid/schema'

export default class extends BaseSchema {
  protected tableName = 'promotions'

  async up() {
    this.schema.createTable(this.tableName, (table) => {
      table.increments('id')
      table.integer('product_id').unsigned().references('id').inTable('products').onDelete('CASCADE')
      table.decimal('discount_percent', 5, 2).notNullable()
      table.string('promo_label', 255).nullable()
      table.string('url', 255).notNullable()
      table.timestamp('promo_start_date').notNullable()
      table.timestamp('promo_end_date').notNullable()

      table.timestamp('created_at')
      table.timestamp('updated_at')
    })
  }

  async down() {
    this.schema.dropTable(this.tableName)
  }
}
