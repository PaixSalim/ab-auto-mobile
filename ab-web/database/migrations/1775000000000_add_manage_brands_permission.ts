import { BaseSchema } from '@adonisjs/lucid/schema'

export default class extends BaseSchema {
  protected tableName = 'permissions'

  public async up() {
    // Vérifier si la permission manage_brands existe déjà
    const existingPermission = await this.db
      .from(this.tableName)
      .where('slug', 'manage_brands')
      .first()

    if (!existingPermission) {
      await this.db.table(this.tableName).insert({
        name: 'Gérer les marques',
        slug: 'manage_brands',
        group: 'brands',
        created_at: new Date(),
        updated_at: new Date()
      })
      // console.log('✅ Permission manage_brands créée')
    } else {
      console.log('ℹ️ Permission manage_brands existe déjà')
    }
  }

  public async down() {
    // Supprimer la permission manage_brands si elle existe
    await this.db
      .from(this.tableName)
        .where('slug', 'manage_brands')
        .delete()
      console.log('❌ Permission manage_brands supprimée')
  }
}
