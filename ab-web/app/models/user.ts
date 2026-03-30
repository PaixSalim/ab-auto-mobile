import { DateTime } from 'luxon'
import hash from '@adonisjs/core/services/hash'
import { compose } from '@adonisjs/core/helpers'
import { BaseModel, column, hasMany } from '@adonisjs/lucid/orm'
import { withAuthFinder } from '@adonisjs/auth/mixins/lucid'
import { UserStatus } from '#dto/user_types'
import type { HasMany, ManyToMany } from '@adonisjs/lucid/types/relations'
import Product from '#models/product'
import Comment from '#models/comment'
import Role from '#models/role'
import { manyToMany } from '@adonisjs/lucid/orm'

const AuthFinder = withAuthFinder(() => hash.use('scrypt'), {
  uids: ['email', 'phone'],
  passwordColumnName: 'password',
})

export default class User extends compose(BaseModel, AuthFinder) {
  @column({ isPrimary: true })
  declare id: number

  @column()
  declare fullName: string | null

  @column()
  declare email: string | null

  @column()
  declare phone: string | null

  @column()
  declare city: string | null

  @column()
  declare registrationNumber: string | null

  @column()
  declare country: string | null

  @column()
  declare companyName: string | null

  @column()
  declare neighborhood: string | null

  @column()
  declare isValidated: boolean

  @column()
  declare role: UserStatus

  @column({ serializeAs: null })
  declare password: string

  @column.dateTime({ autoCreate: true })
  declare createdAt: DateTime

  @column.dateTime({ autoCreate: true, autoUpdate: true })
  declare updatedAt: DateTime | null

  @manyToMany(() => Role, {
    pivotTable: 'role_user',
  })
  declare roles: ManyToMany<typeof Role>

  @hasMany(() => Product, { foreignKey: 'seller_id' })
  declare products: HasMany<typeof Product>

  @hasMany(() => Comment, { foreignKey: 'user_id' })
  declare comments: HasMany<typeof Comment>

  async isAdmin() {
    await this.load('roles' as any)
    return this.roles.some((role) => role.slug === 'admin' || role.slug === 'superadmin')
  }

  async isSeller() {
    await this.load('roles' as any)
    return this.roles.some((role) => role.slug === 'seller')
  }

  async hasPermission(slug: string) {
    await this.load('roles' as any, (roleQuery: any) => {
      roleQuery.preload('permissions')
    })
    return this.roles.some((role) => role.permissions.some((permission) => permission.slug === slug))
  }

  async isSuperAdmin() {
    await this.load('roles' as any)
    return this.roles.some((role) => role.slug === 'superadmin')
  }
}
