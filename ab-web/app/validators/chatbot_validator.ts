import vine from '@vinejs/vine'

export const chatbotValidator = vine.compile(
  vine.object({
    prompt: vine.string().maxLength(500),
    type: vine.string().in(['description', 'features', 'chat']),
  })
)
