import { BaseSeeder } from '@adonisjs/lucid/seeders'
import User from '#models/user'
import Role from '#models/role'
import { UserStatus } from '#dto/user_types'

export default class extends BaseSeeder {
  async run() {
    const superadminRole = await Role.findBy('slug', 'superadmin')

    await User.updateOrCreate(
      { email: 'superadmin@ab-auto.com' },
      {
        fullName: 'Super Administrateur',
        phone: '691112233',
        password: 'superpassword123',
        role: UserStatus.ADMIN,
        isValidated: true,
      }
    )

    const superadmin = await User.findByOrFail('email', 'superadmin@ab-auto.com')
    if (superadminRole) {
      await superadmin.related('roles').sync([superadminRole.id])
    }
  }
}
