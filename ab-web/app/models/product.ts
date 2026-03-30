import { DateTime } from 'luxon'
import { BaseModel, belongsTo, column, hasMany } from '@adonisjs/lucid/orm'
import type { BelongsTo, HasMany } from '@adonisjs/lucid/types/relations'
import Brand from '#models/brand'
import Category from '#models/category'
import Media from '#models/media'
import { ProductState } from '#dto/products_interface'
import Promotion from '#models/promotion'
import Comment from '#models/comment'
import User from '#models/user'

export default class Product extends BaseModel {
  @column({ isPrimary: true })
  declare id: number

  @column()
  declare name: string

  @column()
  declare cta: string | null

  @column()
  declare slug: string

  @column()
  declare state: ProductState

  @column({ columnName: 'validation_status' })
  declare validationStatus: 'pending' | 'approved' | 'rejected'

  @column({ columnName: 'rejection_reason' })
  declare rejectionReason: string | null

  @column()
  declare discount: number

  @column({
    prepare: (value: string[]) => JSON.stringify(value),
    consume: (value: string) => JSON.parse(value || '[]'),
  })
  declare features: string[]

  @column({ columnName: 'category_id' })
  declare categoryId: number

  @column({ columnName: 'brand_id' })
  declare brandId: number

  @column({ columnName: 'seller_id' })
  declare sellerId: number | null

  @column()
  declare warranty: string | null

  @column()
  declare description: string

  @column()
  declare price: number

  @column.dateTime({ autoCreate: true })
  declare createdAt: DateTime

  @column.dateTime({ autoCreate: true, autoUpdate: true })
  declare updatedAt: DateTime

  @belongsTo(() => Category, { foreignKey: 'categoryId' })
  declare category: BelongsTo<typeof Category>

  @belongsTo(() => Brand, { foreignKey: 'brandId' })
  declare brand: BelongsTo<typeof Brand>

  @belongsTo(() => User, { foreignKey: 'sellerId' })
  declare seller: BelongsTo<typeof User>

  @hasMany(() => Media, { foreignKey: 'productId' })
  declare medias: HasMany<typeof Media>

  @hasMany(() => Comment, { foreignKey: 'productId' })
  declare comments: HasMany<typeof Comment>

  @hasMany(() => Promotion, { foreignKey: 'productId' })
  declare promotions: HasMany<typeof Promotion>
}
