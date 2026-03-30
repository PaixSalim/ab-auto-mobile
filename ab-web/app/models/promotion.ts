import { DateTime } from 'luxon'
import { BaseModel, belongsTo, column } from '@adonisjs/lucid/orm'
import Product from '#models/product'
import type { BelongsTo } from '@adonisjs/lucid/types/relations'

export default class Promotion extends BaseModel {
  @column({ isPrimary: true })
  declare id: number

  @column({ columnName: 'product_id' })
  declare productId: number

  @column({ columnName: 'discount_percent' })
  declare discountPercent: number

  @column()
  declare url: string

  @column({ columnName: 'promo_label' })
  declare promoLabel: string | null

  @column.dateTime({ columnName: 'promo_start_date' })
  declare promoStartDate: DateTime

  @column.dateTime({ columnName: 'promo_end_date' })
  declare promoEndDate: DateTime

  @column.dateTime({ autoCreate: true })
  declare createdAt: DateTime

  @column.dateTime({ autoCreate: true, autoUpdate: true })
  declare updatedAt: DateTime

  @belongsTo(() => Product)
  declare product: BelongsTo<typeof Product>
}
