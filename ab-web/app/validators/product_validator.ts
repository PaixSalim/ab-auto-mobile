import vine from '@vinejs/vine'

export const createProductValidator = vine.compile(
  vine.object({
    name: vine.string(),
    cta: vine.string().nullable(),
    categoryId: vine.number(),
    brandId: vine.number().nullable(),
    state: vine.string().in(['new', 'old']),
    description: vine.string(),
    price: vine.number(),
    features: vine.any().nullable(),
    video: vine.string().nullable(),
  })
)
export const editProductValidator = vine.compile(
  vine.object({
    id: vine.number().unique(async (db, value) => {
      return await db.from('products').where('id', value).first()
    }),
    name: vine.string(),
    cta: vine.string().nullable(),
    brandId: vine.number().nullable(),
    categoryId: vine.number(),
    description: vine.string(),
    price: vine.number(),
    features: vine.any().nullable(),
    remove: vine.any().nullable(),
    video: vine.string().nullable(),
  })
)

export const removeProductValidator = vine.compile(
  vine.object({
    id: vine.string().unique(async (db, value) => {
      return await db.from('products').where('id', value).first()
    }),
  })
)
