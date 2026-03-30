import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { ValidationStatus } from '@prisma/client';

@Injectable()
export class ProductValidationService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Récupérer tous les produits en attente de validation
   */
  async getPendingProducts() {
    try {
      const products = await this.prisma.product.findMany({
        where: {
          validationStatus: ValidationStatus.pending,
        },
        include: {
          seller: {
            select: {
              id: true,
              fullName: true,
              email: true,
              phone: true,
              isValidated: true,
            },
          },
          category: true,
          brand: true,
          medias: true,
        },
        orderBy: {
          createdAt: 'desc',
        },
      });

      return products;
    } catch (error) {
      throw new Error('Erreur lors de la récupération des produits en attente');
    }
  }

  /**
   * Récupérer tous les produits avec leur statut de validation
   */
  async getAllProducts() {
    try {
      const products = await this.prisma.product.findMany({
        include: {
          seller: {
            select: {
              id: true,
              fullName: true,
              email: true,
              phone: true,
              isValidated: true,
            },
          },
          category: true,
          brand: true,
          medias: true,
        },
        orderBy: {
          createdAt: 'desc',
        },
      });

      return products;
    } catch (error) {
      throw new Error('Erreur lors de la récupération des produits');
    }
  }

  /**
   * Approuver un produit
   */
  async approveProduct(productId: number) {
    try {
      const product = await this.prisma.product.findUnique({
        where: { id: productId },
      });

      if (!product) {
        throw new Error('Produit non trouvé');
      }

      const updatedProduct = await this.prisma.product.update({
        where: { id: productId },
        data: {
          validationStatus: ValidationStatus.approved,
          rejectionReason: null,
        },
        include: {
          seller: {
            select: {
              id: true,
              fullName: true,
              email: true,
              phone: true,
              isValidated: true,
            },
          },
          category: true,
          brand: true,
          medias: true,
        },
      });

      return updatedProduct;
    } catch (error) {
      throw new Error('Erreur lors de l\'approbation du produit');
    }
  }

  /**
   * Rejeter un produit avec une raison
   */
  async rejectProduct(productId: number, reason: string) {
    if (!reason || reason.trim() === '') {
      throw new Error('Veuillez fournir une raison de rejet');
    }

    try {
      const product = await this.prisma.product.findUnique({
        where: { id: productId },
      });

      if (!product) {
        throw new Error('Produit non trouvé');
      }

      const updatedProduct = await this.prisma.product.update({
        where: { id: productId },
        data: {
          validationStatus: ValidationStatus.rejected,
          rejectionReason: reason.trim(),
        },
        include: {
          seller: {
            select: {
              id: true,
              fullName: true,
              email: true,
              phone: true,
              isValidated: true,
            },
          },
          category: true,
          brand: true,
          medias: true,
        },
      });

      return updatedProduct;
    } catch (error) {
      throw new Error('Erreur lors du rejet du produit');
    }
  }

  /**
   * Obtenir les statistiques de validation
   */
  async getValidationStats() {
    try {
      const stats = await this.prisma.product.groupBy({
        by: ['validationStatus'],
        _count: {
          id: true,
        },
      });

      return stats.reduce((acc, stat) => {
        acc[stat.validationStatus] = stat._count.id;
        return acc;
      }, {} as Record<ValidationStatus, number>);
    } catch (error) {
      throw new Error('Erreur lors de la récupération des statistiques');
    }
  }
}
