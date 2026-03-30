import { 
  Controller, 
  Get, 
  Post, 
  Put, 
  Delete, 
  Body, 
  Param, 
  Res,
  Req,
  BadRequestException,
  NotFoundException
} from '@nestjs/common';
import { Response } from 'express';
import { AdminCommentsService } from './admin-comments.service';
import { InertiaService } from '../../common/inertia/inertia.service';
import { redirectWithFlash } from '../../common/inertia/flash';

@Controller('admin/comments')
export class AdminCommentsController {
  constructor(
    private readonly adminCommentsService: AdminCommentsService,
    private readonly inertia: InertiaService,
  ) {}

  /**
   * Page principale de modération des commentaires
   */
  @Get()
  async index(@Res() res: Response, @Req() req: any) {
    try {
      const [comments, products, stats] = await Promise.all([
        this.adminCommentsService.getAllComments(),
        this.adminCommentsService.getProductsWithComments(),
        this.adminCommentsService.getCommentsStats()
      ]);

      return this.inertia.render('admin/comments', {
        comments,
        products,
        stats,
        auth: {
          user: req.user,
        },
      });
    } catch (error) {
      return this.inertia.render('admin/comments', {
        comments: [],
        products: [],
        stats: {
          total: 0,
          active: 0,
          inactive: 0,
          today: 0,
          productsWithComments: 0
        },
        error: 'Erreur: ' + error.message,
        auth: {
          user: req.user,
        },
      });
    }
  }

  /**
   * Basculer le statut d'un commentaire
   */
  @Post('toggle-status')
  async toggleStatus(
    @Body() body: { commentId: number; status: boolean },
    @Res({ passthrough: true }) res: Response
  ) {
    if (!body.commentId) {
      throw new BadRequestException('ID du commentaire requis');
    }

    if (typeof body.status !== 'boolean') {
      throw new BadRequestException('Statut invalide');
    }

    try {
      await this.adminCommentsService.toggleCommentStatus(body.commentId, body.status);
      return redirectWithFlash(res, '/admin/comments', {
        type: 'success',
        message: 'Statut du commentaire mis à jour.',
      });
    } catch (error) {
      return redirectWithFlash(res, '/admin/comments', {
        type: 'error',
        message: 'Impossible de modifier le statut.',
      });
    }
  }

  /**
   * Mettre à jour un commentaire
   */
  @Put(':id')
  async update(
    @Param('id') id: string,
    @Body() updateData: {
      comment?: string;
      user?: string;
      isActive?: boolean;
    },
    @Res({ passthrough: true }) res: Response
  ) {
    // Validation basique
    if (updateData.comment && updateData.comment.length > 500) {
      throw new BadRequestException('Le commentaire ne peut pas dépasser 500 caractères');
    }

    if (updateData.user && updateData.user.length < 2) {
      throw new BadRequestException('Le nom d\'utilisateur doit contenir au moins 2 caractères');
    }

    try {
      await this.adminCommentsService.updateComment({
        id: parseInt(id),
        ...updateData
      });
      return redirectWithFlash(res, '/admin/comments', {
        type: 'success',
        message: 'Commentaire mis à jour.',
      });
    } catch (error) {
      return redirectWithFlash(res, '/admin/comments', {
        type: 'error',
        message: 'Impossible de mettre à jour le commentaire.',
      });
    }
  }

  /**
   * Supprimer un commentaire
   */
  @Delete(':id')
  async delete(@Param('id') id: string, @Res({ passthrough: true }) res: Response) {
    try {
      await this.adminCommentsService.deleteComment(parseInt(id));
      return redirectWithFlash(res, '/admin/comments', {
        type: 'success',
        message: 'Commentaire supprimé.',
      });
    } catch (error) {
      return redirectWithFlash(res, '/admin/comments', {
        type: 'error',
        message: 'Impossible de supprimer le commentaire.',
      });
    }
  }

  /**
   * Approuver plusieurs commentaires
   */
  @Post('approve-multiple')
  async approveMultiple(
    @Body() body: { commentIds: number[] },
    @Res({ passthrough: true }) res: Response
  ) {
    if (!Array.isArray(body.commentIds) || body.commentIds.length === 0) {
      throw new BadRequestException('Liste d\'IDs de commentaires requise');
    }

    try {
      await this.adminCommentsService.approveMultipleComments(body.commentIds);
      return redirectWithFlash(res, '/admin/comments', {
        type: 'success',
        message: 'Commentaires approuvés.',
      });
    } catch (error) {
      return redirectWithFlash(res, '/admin/comments', {
        type: 'error',
        message: 'Action impossible.',
      });
    }
  }

  /**
   * Désapprouver plusieurs commentaires
   */
  @Post('disapprove-multiple')
  async disapproveMultiple(
    @Body() body: { commentIds: number[] },
    @Res({ passthrough: true }) res: Response
  ) {
    if (!Array.isArray(body.commentIds) || body.commentIds.length === 0) {
      throw new BadRequestException('Liste d\'IDs de commentaires requise');
    }

    try {
      await this.adminCommentsService.disapproveMultipleComments(body.commentIds);
      return redirectWithFlash(res, '/admin/comments', {
        type: 'success',
        message: 'Commentaires désapprouvés.',
      });
    } catch (error) {
      return redirectWithFlash(res, '/admin/comments', {
        type: 'error',
        message: 'Action impossible.',
      });
    }
  }

  /**
   * API endpoint pour obtenir les statistiques
   */
  @Get('stats')
  async getStats() {
    try {
      const stats = await this.adminCommentsService.getCommentsStats();
      return {
        success: true,
        stats,
      };
    } catch (error) {
      return {
        success: false,
        message: 'Erreur lors de la récupération des statistiques: ' + error.message,
      };
    }
  }

  /**
   * API endpoint pour obtenir les commentaires actifs
   */
  @Get('active')
  async getActiveComments() {
    try {
      const comments = await this.adminCommentsService.getCommentsByStatus(true);
      return {
        success: true,
        comments,
      };
    } catch (error) {
      return {
        success: false,
        message: 'Erreur lors de la récupération des commentaires actifs: ' + error.message,
      };
    }
  }

  /**
   * API endpoint pour obtenir les commentaires inactifs
   */
  @Get('inactive')
  async getInactiveComments() {
    try {
      const comments = await this.adminCommentsService.getCommentsByStatus(false);
      return {
        success: true,
        comments,
      };
    } catch (error) {
      return {
        success: false,
        message: 'Erreur lors de la récupération des commentaires inactifs: ' + error.message,
      };
    }
  }

  /**
   * API endpoint pour obtenir un commentaire spécifique
   */
  @Get(':id')
  async getOne(@Param('id') id: string) {
    try {
      const comments = await this.adminCommentsService.getAllComments();
      const comment = comments.find(c => c.id === parseInt(id));
      
      if (!comment) {
        throw new NotFoundException('Commentaire introuvable');
      }

      return {
        success: true,
        comment,
      };
    } catch (error) {
      return {
        success: false,
        message: 'Erreur lors de la récupération du commentaire: ' + error.message,
      };
    }
  }
}
