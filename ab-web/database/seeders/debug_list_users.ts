import User from '#models/user'
import { BaseSeeder } from '@adonisjs/lucid/seeders'

export default class extends BaseSeeder {
  async run() {
    const users = await User.query().select('id', 'email', 'phone', 'fullName', 'isValidated', 'role').orderBy('id', 'desc').limit(10)
    console.log('--- USERS LIST ---')
    users.forEach(u => {
      console.log(`ID: ${u.id} | Name: ${u.fullName} | Email: ${u.email} | Phone: ${u.phone} | Valid: ${u.isValidated} | Role: ${u.role}`)
    })
    console.log('--- END USERS LIST ---')
  }
}
