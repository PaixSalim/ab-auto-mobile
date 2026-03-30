import vine from '@vinejs/vine'

export const OrderValidator = vine.compile(
  vine.object({
    orderId: vine.number().unique(async (db, value) => {
      return await db.from('orders').where('id', value).first()
    }),
  })
)

export const CreateOrderValidator = vine.compile(
  vine.object({
    customerName: vine.string().minLength(3).maxLength(50),
    city: vine.string().minLength(3).maxLength(50),
    phoneNumber: vine.string().minLength(8).maxLength(15),
    productId: vine.number().unique(async (db, value) => {
      return await db.from('products').where('id', value).first()
    }),
    quantity: vine.number(),
    userId: vine.number().optional(),
  })
)
