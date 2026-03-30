import { BaseSeeder } from '@adonisjs/lucid/seeders'
import Role from '#models/role'
import User from '#models/user'
import { UserStatus } from '#dto/user_types'

export default class extends BaseSeeder {
  async run() {
    // 1. Create Roles
    const roles = [
      { name: 'Super Administrateur', slug: 'superadmin' },
      { name: 'Administrateur', slug: 'admin' },
      { name: 'Vendeur', slug: 'seller' },
      { name: 'Client', slug: 'customer' },
    ]

    for (const roleData of roles) {
      await Role.updateOrCreate({ slug: roleData.slug }, roleData)
    }

    const superAdminRole = await Role.findByOrFail('slug', 'superadmin')

    const superadmin = await User.updateOrCreate(
      { email: 'superadmin@ab-auto.com' },
      {
        fullName: 'Super Administrateur',
        phone: '691112233',
        password: 'superpassword123',
        role: UserStatus.ADMIN,
        isValidated: true,
      }
    )

    // 3. Attach Superadmin Role
    await superadmin.related('roles').sync([superAdminRole.id])

    console.log('✅ System Setup: Roles created and Superadmin user initialized.')
  }
}
