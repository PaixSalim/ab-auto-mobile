import User from '#models/user'
import { BaseSeeder } from '@adonisjs/lucid/seeders'

export default class extends BaseSeeder {
  async run() {
    const users = await User.query().select('id', 'fullName', 'password').orderBy('id', 'desc').limit(5)
    console.log('--- PASSWORD CHECK ---')
    users.forEach(u => {
      console.log(`ID: ${u.id} | Name: ${u.fullName} | PWD Starts with $scrypt: ${u.password?.startsWith('$scrypt$') || 'NO!'}`)
    })
    console.log('--- END PASSWORD CHECK ---')
  }
}
