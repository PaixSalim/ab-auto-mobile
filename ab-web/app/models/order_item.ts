import { DateTime } from 'luxon'
import { BaseModel, belongsTo, column } from '@adonisjs/lucid/orm'
import Order from '#models/order'
import Product from '#models/product'
import type { BelongsTo } from '@adonisjs/lucid/types/relations'

export default class OrderItem extends BaseModel {
  @column({ isPrimary: true })
  declare id: number

  @column({ columnName: 'order_id' })
  declare orderId: string

  @column({ columnName: 'product_id' })
  declare productId: string

  @column()
  declare quantity: number

  @column()
  declare price: number

  @belongsTo(() => Order, { foreignKey: 'order_id' })
  declare order: BelongsTo<typeof Order>

  @belongsTo(() => Product, { foreignKey: 'product_id' })
  declare product: BelongsTo<typeof Product>

  @column.dateTime({ autoCreate: true })
  declare createdAt: DateTime

  @column.dateTime({ autoCreate: true, autoUpdate: true })
  declare updatedAt: DateTime
}
