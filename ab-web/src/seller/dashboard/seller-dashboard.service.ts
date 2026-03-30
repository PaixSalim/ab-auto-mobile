import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class SellerDashboardService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Obtenir les statistiques du vendeur
   */
  async getSellerStats(sellerId: number) {
    try {

      // Nombre de produits du vendeur
      const productsCount = await this.prisma.product.count({
        where: { sellerId }
      });

      // Nombre de commandes pour les produits du vendeur
      const ordersCount = await this.prisma.order.count({
        where: {
          product: {
            sellerId
          }
        }
      });

      // Nombre de commentaires sur les produits du vendeur
      const productsWithComments = await this.prisma.product.findMany({
        where: { sellerId },
        include: {
          comments: true
        }
      });

      const commentsCount = productsWithComments.reduce(
        (total, product) => total + (product.comments?.length || 0),
        0
      );


      return {
        products: productsCount,
        orders: ordersCount,
        comments: commentsCount,
      };
    } catch (error) {
      return {
        products: 0,
        orders: 0,
        comments: 0,
      };
    }
  }
}
