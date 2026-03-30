import factory from '@adonisjs/lucid/factories'
import User from '#models/user'
import { UserStatus } from '#dto/user_types'

export const UserFactory = factory
  .define(User, async () => {
    return {
      fullName: 'Auto Administrador',
      role: UserStatus.ADMIN,
      email: 'autopro@uvatis.com',
      //email: faker.internet.email(),
      //password: faker.internet.password(),
      password: 'YHs45*%92M9JiH72pII^RK4rh',
    }
  })
  .build()
