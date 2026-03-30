import { BaseSeeder } from '@adonisjs/lucid/seeders'
import { CommentFactory } from '#database/factories/comment_factory'

export default class extends BaseSeeder {
  async run() {
    await CommentFactory.createMany(15)
  }
}
