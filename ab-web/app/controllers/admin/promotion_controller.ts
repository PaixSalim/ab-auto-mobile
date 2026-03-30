import type { HttpContext } from '@adonisjs/core/http'
import { CreatePromotionValidator, EditPromotionValidator } from '#validators/promotion_validator'
import Promotion from '#models/promotion'
import { inject } from '@adonisjs/core'
import { PromotionService } from '#services/admin/promotion_service'

@inject()
export default class PromotionController {
  constructor(private promotionService: PromotionService) {}
  async index({ inertia }: HttpContext) {
    const promos = await Promotion.query().preload('product')
    return inertia.render('admin/promotions', { promos: promos })
  }
  async create(ctx: HttpContext) {
    const payload = await ctx.request.validateUsing(CreatePromotionValidator)
    const file = ctx.request.file('image')
    
    await this.promotionService.create(payload, file)
    
    ctx.session.flash('notification', {
      type: 'success',
      message: 'Promotion créée avec succès'
    })
    
    return ctx.response.redirect().back()
  }
  async edit(ctx: HttpContext) {
    const payload = await ctx.request.validateUsing(EditPromotionValidator)
    const file = ctx.request.file('image')
    
    await this.promotionService.edit(payload, file)
    
    ctx.session.flash('notification', {
      type: 'success',
      message: 'Promotion modifiée avec succès'
    })
    
    return ctx.response.redirect().back()
  }

  async delete(ctx: HttpContext) {
    const id = await ctx.request.param('id')
    await this.promotionService.delete(id)
    
    ctx.session.flash('notification', {
      type: 'success',
      message: 'Promotion supprimée avec succès'
    })
    
    return ctx.response.redirect().back()
  }
}
