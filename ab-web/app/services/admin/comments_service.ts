import Comment from '#models/comment'
import { CommentRequest, CommentUpdateRequest } from '#dto/comments_interface'
import { inject } from '@adonisjs/core'
import Product from '#models/product'

@inject()
export class CommentsService {
  async createComments(payload: CommentRequest) {
    return await Comment.create(payload)
  }
  async getCommentsById(productId: number) {
    return Comment.query().where('product_id', productId).andWhere('is_active', true)
  }
  async getAllComments() {
    return Comment.all()
  }

  async getProductComments() {
    return Product.query().has('comments')
  }

  async toggleCommentStatus(id: number, status: boolean) {
    return Comment.query().where('id', id).update({ isActive: status })
  }

  async updateComment(payload: CommentUpdateRequest) {
    const comment = await Comment.findOrFail(payload.id)
    return await comment
      .merge({
        user: payload.user,
        comment: payload.comment,
        isActive: payload.isActive,
      })
      .save()
  }

  async deleteComment(id: number) {
    const comment = await Comment.findOrFail(id)
    return await comment.delete()
  }
}
