import User from '#models/user'
import { BaseSeeder } from '@adonisjs/lucid/seeders'

export default class extends BaseSeeder {
  async run() {
    const users = await User.all()
    for (const user of users) {
      if (user.phone) {
        const clean = user.phone.replace(/[^\d+]/g, '')
        if (clean !== user.phone) {
          user.phone = clean
          await user.save()
          console.log(`✅ Normalized phone for User ${user.id}: ${clean}`)
        }
      }
    }
    console.log('✅ All phones normalized.')
  }
}
