import { BaseSchema } from '@adonisjs/lucid/schema'

export default class extends BaseSchema {
  protected tableName = 'products'

  async up() {
    this.schema.alterTable(this.tableName, (table) => {
      table.enum('validation_status', ['pending', 'approved', 'rejected']).defaultTo('pending').after('state')
      table.text('rejection_reason').nullable().after('validation_status')
    })
  }

  async down() {
    this.schema.alterTable(this.tableName, (table) => {
      table.dropColumn('validation_status')
      table.dropColumn('rejection_reason')
    })
  }
}
