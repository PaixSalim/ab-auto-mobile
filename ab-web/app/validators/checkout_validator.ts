import vine from '@vinejs/vine'

export const checkoutValidator = vine.compile(
  vine.object({
    orderId: vine.string().unique(async (db, value) => {
      return await db
        .from('orders')
        .where('id', value)
        .andWhere('status', 'Paiement en attente')
        .first()
    }),
  })
)
