import { BaseSeeder } from '@adonisjs/lucid/seeders'
import Role from '#models/role'

export default class extends BaseSeeder {
  async run() {
    await Role.updateOrCreate({ slug: 'superadmin' }, { name: 'Super Administrateur', slug: 'superadmin' })
    await Role.updateOrCreate({ slug: 'admin' }, { name: 'Administrateur', slug: 'admin' })
    await Role.updateOrCreate({ slug: 'seller' }, { name: 'Vendeur', slug: 'seller' })
    await Role.updateOrCreate({ slug: 'customer' }, { name: 'Client', slug: 'customer' })
  }
}