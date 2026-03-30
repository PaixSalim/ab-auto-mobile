import { Controller, Get, Post, Put, Delete, Patch, Body, Param, Query, Res, HttpStatus } from '@nestjs/common';
import { CommentsService } from './comments.service';
import { CreateCommentDto, UpdateCommentDto, ToggleCommentStatusDto } from '../dto/comments.dto';

@Controller('comments')
export class CommentsController {
  constructor(private readonly commentsService: CommentsService) {}

  @Post()
  async createComment(@Body() createCommentDto: CreateCommentDto, @Res() res: any) {
    try {
      const comment = await this.commentsService.create(createCommentDto);
      return res.status(HttpStatus.CREATED).json({
        message: 'Commentaire créé avec succès',
        data: comment
      });
    } catch (error) {
      return res.status(HttpStatus.INTERNAL_SERVER_ERROR).json({
        message: 'Erreur lors de la création du commentaire',
        error: error.message
      });
    }
  }

  @Get('product/:productId')
  async getCommentsByProduct(@Param('productId') productId: number) {
    return await this.commentsService.findByProduct(productId);
  }

  @Get('admin/all')
  async getAllComments() {
    return await this.commentsService.findAll();
  }

  @Patch(':id/toggle')
  async toggleCommentStatus(@Param('id') id: number, @Body() toggleDto: ToggleCommentStatusDto, @Res() res: any) {
    try {
      const comment = await this.commentsService.toggleStatus(id, toggleDto.status);
      return res.status(HttpStatus.OK).json({
        message: toggleDto.status ? 'Commentaire activé avec succès' : 'Commentaire désactivé avec succès',
        data: comment
      });
    } catch (error) {
      return res.status(HttpStatus.INTERNAL_SERVER_ERROR).json({
        message: 'Erreur lors du changement de statut',
        error: error.message
      });
    }
  }

  @Put(':id')
  async updateComment(@Param('id') id: number, @Body() updateCommentDto: UpdateCommentDto, @Res() res: any) {
    try {
      const comment = await this.commentsService.update(id, updateCommentDto);
      return res.status(HttpStatus.OK).json({
        message: 'Commentaire modifié avec succès',
        data: comment
      });
    } catch (error) {
      return res.status(HttpStatus.INTERNAL_SERVER_ERROR).json({
        message: 'Erreur lors de la modification du commentaire',
        error: error.message
      });
    }
  }

  @Delete(':id')
  async deleteComment(@Param('id') id: number, @Res() res: any) {
    try {
      await this.commentsService.delete(id);
      return res.status(HttpStatus.OK).json({
        message: 'Commentaire supprimé avec succès'
      });
    } catch (error) {
      return res.status(HttpStatus.INTERNAL_SERVER_ERROR).json({
        message: 'Erreur lors de la suppression du commentaire',
        error: error.message
      });
    }
  }
}
