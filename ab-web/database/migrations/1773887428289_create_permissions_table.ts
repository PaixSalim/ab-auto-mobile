import { BaseSchema } from '@adonisjs/lucid/schema'

export default class extends BaseSchema {
  protected tableName = 'permissions'

  public async up() {
    this.schema.createTable(this.tableName, (table) => {
      table.increments('id')
      table.string('name').notNullable()
      table.string('slug').notNullable().unique()
      table.string('group').notNullable()
      table.timestamp('created_at')
      table.timestamp('updated_at')
    })

    this.schema.createTable('permission_role', (table) => {
      table.increments('id')
      table.integer('role_id').unsigned().references('roles.id').onDelete('CASCADE')
      table.integer('permission_id').unsigned().references('permissions.id').onDelete('CASCADE')
      table.unique(['role_id', 'permission_id'])
    })
  }

  public async down() {
    this.schema.dropTable('permission_role')
    this.schema.dropTable(this.tableName)
  }
}