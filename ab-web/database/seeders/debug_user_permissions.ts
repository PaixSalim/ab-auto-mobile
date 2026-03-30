import User from '#models/user'
import { BaseSeeder } from '@adonisjs/lucid/seeders'

export default class extends BaseSeeder {
  async run() {
    const user = await User.find(5)
    if (!user) {
      console.log('User 5 not found')
      return
    }
    await user.load('roles' as any)
    for (const role of user.roles) {
      await role.load('permissions' as any)
      console.log(`Role: ${role.slug} | Permissions: ${role.permissions.map((p: any) => p.slug).join(', ')}`)
    }
  }
}
