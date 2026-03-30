import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class AdminCommentsService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Récupérer tous les commentaires avec relations complètes
   */
  async getAllComments() {
    try {
      const comments = await this.prisma.comment.findMany({
        include: {
          product: {
            select: {
              id: true,
              name: true,
            }
          },
          author: {
            select: {
              id: true,
              fullName: true,
              email: true,
              role: true,
            }
          },
          replies: {
            include: {
              author: {
                select: {
                  id: true,
                  fullName: true,
                  email: true,
                }
              }
            }
          }
        },
        orderBy: { createdAt: 'desc' }
      });

      return comments;
    } catch (error) {
      throw new Error('Erreur lors de la récupération des commentaires');
    }
  }

  /**
   * Récupérer les produits qui ont des commentaires
   */
  async getProductsWithComments() {
    try {
      const products = await this.prisma.product.findMany({
        where: {
          comments: {
            some: {}
          }
        },
        include: {
          _count: {
            select: { comments: true }
          },
          seller: {
            select: {
              id: true,
              fullName: true,
            }
          }
        },
        orderBy: { createdAt: 'desc' }
      });

      return products;
    } catch (error) {
      throw new Error('Erreur lors de la récupération des produits avec commentaires');
    }
  }

  /**
   * Basculer le statut d'un commentaire (actif/inactif)
   */
  async toggleCommentStatus(commentId: number, status: boolean) {
    try {
      // Vérifier si le commentaire existe
      const comment = await this.prisma.comment.findUnique({
        where: { id: commentId }
      });

      if (!comment) {
        throw new Error('Commentaire introuvable');
      }

      const updatedComment = await this.prisma.comment.update({
        where: { id: commentId },
        data: { isActive: status },
        include: {
          product: {
            select: {
              id: true,
              name: true,
            }
          },
          author: {
            select: {
              id: true,
              fullName: true,
              email: true,
              role: true,
            }
          },
          replies: {
            include: {
              author: {
                select: {
                  id: true,
                  fullName: true,
                  email: true,
                }
              }
            }
          }
        }
      });

      return updatedComment;
    } catch (error) {
      throw new Error('Erreur lors de la modification du statut du commentaire: ' + error.message);
    }
  }

  /**
   * Mettre à jour un commentaire
   */
  async updateComment(updateData: {
    id: number;
    comment?: string;
    user?: string;
    isActive?: boolean;
  }) {
    try {
      // Vérifier si le commentaire existe
      const comment = await this.prisma.comment.findUnique({
        where: { id: updateData.id }
      });

      if (!comment) {
        throw new Error('Commentaire introuvable');
      }

      const updatedComment = await this.prisma.comment.update({
        where: { id: updateData.id },
        data: {
          ...(updateData.comment && { comment: updateData.comment }),
          ...(updateData.user && { user: updateData.user }),
          ...(updateData.isActive !== undefined && { isActive: updateData.isActive }),
        },
        include: {
          product: {
            select: {
              id: true,
              name: true,
            }
          },
          author: {
            select: {
              id: true,
              fullName: true,
              email: true,
              role: true,
            }
          },
          replies: {
            include: {
              author: {
                select: {
                  id: true,
                  fullName: true,
                  email: true,
                }
              }
            }
          }
        }
      });

      return updatedComment;
    } catch (error) {
      throw new Error('Erreur lors de la mise à jour du commentaire: ' + error.message);
    }
  }

  /**
   * Supprimer un commentaire
   */
  async deleteComment(commentId: number) {
    try {
      // Vérifier si le commentaire existe
      const comment = await this.prisma.comment.findUnique({
        where: { id: commentId },
        include: {
          replies: true
        }
      });

      if (!comment) {
        throw new Error('Commentaire introuvable');
      }

      // Supprimer le commentaire (les réponses seront supprimées en cascade par Prisma si configuré)
      await this.prisma.comment.delete({
        where: { id: commentId }
      });

      return { success: true, message: 'Commentaire supprimé avec succès' };
    } catch (error) {
      throw new Error('Erreur lors de la suppression du commentaire: ' + error.message);
    }
  }

  /**
   * Obtenir les statistiques des commentaires
   */
  async getCommentsStats() {
    try {
      const [
        totalComments,
        activeComments,
        inactiveComments,
        commentsToday,
        productsWithComments
      ] = await Promise.all([
        this.prisma.comment.count(),
        this.prisma.comment.count({ where: { isActive: true } }),
        this.prisma.comment.count({ where: { isActive: false } }),
        this.prisma.comment.count({
          where: {
            createdAt: {
              gte: new Date(new Date().setHours(0, 0, 0, 0))
            }
          }
        }),
        this.prisma.product.count({
          where: {
            comments: {
              some: {}
            }
          }
        })
      ]);

      return {
        total: totalComments,
        active: activeComments,
        inactive: inactiveComments,
        today: commentsToday,
        productsWithComments: productsWithComments
      };
    } catch (error) {
      throw new Error('Erreur lors de la récupération des statistiques');
    }
  }

  /**
   * Obtenir les commentaires par statut
   */
  async getCommentsByStatus(isActive: boolean) {
    try {
      const comments = await this.prisma.comment.findMany({
        where: { isActive },
        include: {
          product: {
            select: {
              id: true,
              name: true,
            }
          },
          author: {
            select: {
              id: true,
              fullName: true,
              email: true,
              role: true,
            }
          },
          replies: {
            include: {
              author: {
                select: {
                  id: true,
                  fullName: true,
                  email: true,
                }
              }
            }
          }
        },
        orderBy: { createdAt: 'desc' }
      });

      return comments;
    } catch (error) {
      throw new Error('Erreur lors de la récupération des commentaires par statut');
    }
  }

  /**
   * Approuver plusieurs commentaires à la fois
   */
  async approveMultipleComments(commentIds: number[]) {
    try {
      const result = await this.prisma.comment.updateMany({
        where: {
          id: { in: commentIds }
        },
        data: { isActive: true }
      });

      return { success: true, updated: result.count };
    } catch (error) {
      throw new Error('Erreur lors de l\'approbation multiple des commentaires');
    }
  }

  /**
   * Désapprouver plusieurs commentaires à la fois
   */
  async disapproveMultipleComments(commentIds: number[]) {
    try {
      const result = await this.prisma.comment.updateMany({
        where: {
          id: { in: commentIds }
        },
        data: { isActive: false }
      });

      return { success: true, updated: result.count };
    } catch (error) {
      throw new Error('Erreur lors de la désapprobation multiple des commentaires');
    }
  }
}
