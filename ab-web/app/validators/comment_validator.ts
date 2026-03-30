import vine from '@vinejs/vine'

export const PostCommentValidator = vine.compile(
  vine.object({
    productId: vine.number().unique(async (db, value) => {
      return await db.from('products').where('id', value).first()
    }),
    comment: vine.string().maxLength(500),
    user: vine.string(),
    userId: vine.number().optional(),
  })
)

export const GetCommentValidator = vine.compile(
  vine.object({
    productId: vine.number().unique(async (db, value) => {
      return await db.from('products').where('id', value).first()
    }),
  })
)

export const ToggleCommentStatusValidator = vine.compile(
  vine.object({
    commentId: vine.number().unique(async (db, value) => {
      return await db.from('comments').where('id', value).first()
    }),
    status: vine.boolean(),
  })
)
export const DeleteCommentValidator = vine.compile(
  vine.object({
    commentId: vine.number().unique(async (db, value) => {
      return await db.from('comments').where('id', value).first()
    }),
  })
)

export const UpdateCommentValidator = vine.compile(
  vine.object({
    id: vine.number().unique(async (db, value) => {
      return await db.from('comments').where('id', value).first()
    }),
    comment: vine.string().maxLength(500),
    user: vine.string(),
    isActive: vine.boolean(),
  })
)
