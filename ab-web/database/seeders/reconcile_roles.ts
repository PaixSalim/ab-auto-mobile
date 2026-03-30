import User from '#models/user'
import Role from '#models/role'
import { BaseSeeder } from '@adonisjs/lucid/seeders'
import { UserStatus } from '#dto/user_types'

export default class extends BaseSeeder {
  async run() {
    const users = await User.all()
    const roles = await Role.all()

    for (const user of users) {
      // Find what role they should have based on their 'role' column
      let targetSlug = 'customer'
      if (user.role === UserStatus.ADMIN) {
        // Admin column maps to admin role (or if was superadmin keep it)
        // Check if already has a role
        await user.load('roles' as any)
        if (user.roles.length > 0) continue // Skip if already has roles in pivot

        targetSlug = 'admin'
      } else if (user.role === UserStatus.SELLER) {
        targetSlug = 'seller'
      }

      const role = roles.find(r => r.slug === targetSlug)
      if (role) {
        await user.related('roles').attach([role.id])
        console.log(`✅ Fixed role for User ${user.fullName} (ID: ${user.id}) -> ${targetSlug}`)
      }
    }
    console.log('✅ Reconciliation finished.')
  }
}
