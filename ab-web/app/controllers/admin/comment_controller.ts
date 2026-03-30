import { HttpContext } from '@adonisjs/core/http'
import { inject } from '@adonisjs/core'
import { CommentsService } from '#services/admin/comments_service'
import { ToggleCommentStatusValidator, UpdateCommentValidator } from '#validators/comment_validator'
import { canViewComments, canManageComments, canDeleteComments } from '#abilities/main'

@inject()
export default class CommentController {
  constructor(private commentService: CommentsService) {}

  async index(ctx: HttpContext) {
    await ctx.bouncer.authorize(canViewComments)
    return ctx.inertia.render('admin/comments', {
      comments: await this.commentService.getAllComments(),
      products: await this.commentService.getProductComments(),
    })
  }

  async toggleCommentStatus(ctx: HttpContext) {
    await ctx.bouncer.authorize(canManageComments)
    const payload = await ctx.request.validateUsing(ToggleCommentStatusValidator)
    await this.commentService.toggleCommentStatus(payload.commentId, payload.status)
    
    ctx.session.flash('notification', {
      type: 'success',
      message: payload.status ? 'Commentaire activé avec succès' : 'Commentaire désactivé avec succès'
    })
    
    return ctx.response.redirect().back()
  }

  async updateComment(ctx: HttpContext) {
    await ctx.bouncer.authorize(canManageComments)
    const payload = await ctx.request.validateUsing(UpdateCommentValidator)
    await this.commentService.updateComment(payload)
    
    ctx.session.flash('notification', {
      type: 'success',
      message: 'Commentaire modifié avec succès'
    })
    
    return ctx.response.redirect().back()
  }

  async deleteComment(ctx: HttpContext) {
    await ctx.bouncer.authorize(canDeleteComments)
    const id = await ctx.request.param('id')
    await this.commentService.deleteComment(id)
    
    ctx.session.flash('notification', {
      type: 'success',
      message: 'Commentaire supprimé avec succès'
    })
    
    return ctx.response.redirect().back()
  }
}
