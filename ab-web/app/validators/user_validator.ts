import vine from '@vinejs/vine'

export const registerUserValidator = vine.compile(
  vine.object({
    name: vine.string().minLength(2).maxLength(25),
    email: vine
      .string()
      .email()
      .unique(async (db, value) => {
        const user = await db
          .from('users')
          .where('email', value)
          .andWhere('is_activated', true)
          .first()
        return !user
      }),
    password: vine.string().minLength(6),
  })
)

