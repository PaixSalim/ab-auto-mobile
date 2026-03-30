import factory from '@adonisjs/lucid/factories'
import Comment from '#models/comment'

export const CommentFactory = factory
  .define(Comment, async ({ faker }) => {
    return {
      comment: faker.lorem.sentence(),
      productId: faker.number.int({ min: 1, max: 17 }),
      isActive: Math.random() > 0.3,
      user: faker.person.firstName(),
      ip: faker.internet.ip(),
    }
  })
  .build()
