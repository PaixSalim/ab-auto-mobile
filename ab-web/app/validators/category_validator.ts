import vine from '@vinejs/vine'

export const getBrandsByCategoryValidator = vine.compile(
  vine.object({
    categoryId: vine.number().unique(async (db, value) => {
      return await db.from('categories').where('id', value).first()
    }),
  })
)
