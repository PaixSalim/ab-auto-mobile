import { DateTime } from 'luxon'
import { BaseModel, belongsTo, column } from '@adonisjs/lucid/orm'
import type { BelongsTo } from '@adonisjs/lucid/types/relations'
import Product from '#models/product'
import User from '#models/user'
import { OrderStatus } from '#utils/enum'

export default class Order extends BaseModel {
  @column({ isPrimary: true })
  declare id: number

  @column({ columnName: 'product_id' })
  declare productId: number

  @column({ columnName: 'user_id' })
  declare userId: number | null

  @column({ columnName: 'customer_name' })
  declare customerName: string

  @column()
  declare city: string | null

  @column({ columnName: 'phone_number' })
  declare phoneNumber: string

  @column()
  declare status: OrderStatus

  @column()
  declare quantity: number

  @column.dateTime({ autoCreate: true })
  declare createdAt: DateTime

  @column.dateTime({ autoCreate: true, autoUpdate: true })
  declare updatedAt: DateTime

  @belongsTo(() => Product, { foreignKey: 'productId' })
  declare product: BelongsTo<typeof Product>

  @belongsTo(() => User, { foreignKey: 'userId' })
  declare customer: BelongsTo<typeof User>
}
