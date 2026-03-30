import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { UserRole } from '@prisma/client';
import * as bcrypt from 'bcryptjs';

@Injectable()
export class AdminSellersService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Récupérer tous les vendeurs (avec pagination)
   */
  async getAllSellersPaginated(page: number = 1, limit: number = 10) {
    try {
      const skip = (page - 1) * limit;
      
      const [sellers, total] = await Promise.all([
        this.prisma.user.findMany({
          where: { role: UserRole.seller },
          orderBy: { createdAt: 'desc' },
          skip,
          take: limit,
          include: {
            products: {
              select: { id: true }
            },
            orders: {
              select: { id: true }
            }
          }
        }),
        this.prisma.user.count({
          where: { role: UserRole.seller }
        })
      ]);

      const totalPages = Math.ceil(total / limit);
      
      // Formater comme la pagination AdonisJS
      return {
        data: sellers.map(seller => ({
          ...seller,
          password: undefined, // Ne pas exposer le mot de passe
          productsCount: seller.products.length,
          ordersCount: seller.orders.length,
        })),
        meta: {
          total,
          per_page: limit,
          current_page: page,
          last_page: totalPages,
          first_page: 1,
          from: skip + 1,
          to: Math.min(skip + limit, total),
          links: this.generatePaginationLinks(page, totalPages, limit)
        }
      };
    } catch (error) {
      throw new Error('Erreur lors de la récupération des vendeurs paginés');
    }
  }

  /**
   * Générer les liens de pagination (format AdonisJS)
   */
  private generatePaginationLinks(currentPage: number, totalPages: number, limit: number) {
    const links = [];
    
    // Lien première page
    links.push({
      url: currentPage > 1 ? `/admin/sellers?page=1` : null,
      label: '&laquo; Previous',
      active: false
    });
    
    // Pages numérotées
    for (let i = 1; i <= totalPages; i++) {
      if (i === 1 || i === totalPages || (i >= currentPage - 2 && i <= currentPage + 2)) {
        links.push({
          url: i === currentPage ? null : `/admin/sellers?page=${i}`,
          label: i.toString(),
          active: i === currentPage
        });
      } else if (i === currentPage - 3 || i === currentPage + 3) {
        links.push({
          url: null,
          label: '...',
          active: false
        });
      }
    }
    
    // Lien dernière page
    links.push({
      url: currentPage < totalPages ? `/admin/sellers?page=${totalPages}` : null,
      label: 'Next &raquo;',
      active: false
    });
    
    return links;
  }

  /**
   * Créer un nouveau vendeur
   */
  async createSeller(createSellerDto: {
    fullName: string;
    email: string;
    password: string;
    phone?: string;
  }) {
    try {
      // Vérifier si l'email existe déjà
      const existingUser = await this.prisma.user.findUnique({
        where: { email: createSellerDto.email }
      });

      if (existingUser) {
        throw new Error('Un utilisateur avec cet email existe déjà');
      }

      // Hasher le mot de passe
      const hashedPassword = await bcrypt.hash(createSellerDto.password, 10);

      const seller = await this.prisma.user.create({
        data: {
          fullName: createSellerDto.fullName,
          email: createSellerDto.email,
          password: hashedPassword,
          phone: createSellerDto.phone || null,
          role: UserRole.seller,
          isValidated: false, // Les vendeurs doivent être validés par défaut
        },
        include: {
          products: {
            select: { id: true }
          },
          orders: {
            select: { id: true }
          }
        }
      });

      return {
        ...seller,
        password: undefined,
        _count: {
          products: seller.products.length,
          orders: seller.orders.length
        }
      };
    } catch (error) {
      throw new Error('Erreur lors de la création du vendeur: ' + error.message);
    }
  }

  /**
   * Basculer la validation d'un vendeur
   */
  async toggleValidation(sellerId: number) {
    try {
      const seller = await this.prisma.user.findUnique({
        where: { id: sellerId, role: UserRole.seller }
      });

      if (!seller) {
        throw new Error('Vendeur introuvable');
      }

      const updatedSeller = await this.prisma.user.update({
        where: { id: sellerId },
        data: {
          isValidated: !seller.isValidated
        },
        include: {
          products: {
            select: { id: true }
          },
          orders: {
            select: { id: true }
          }
        }
      });

      return {
        ...updatedSeller,
        password: undefined,
        productsCount: updatedSeller.products.length,
        ordersCount: updatedSeller.orders.length,
      };
    } catch (error) {
      throw new Error('Erreur lors de la mise à jour de la validation');
    }
  }

  /**
   * Mettre à jour un vendeur
   */
  async updateSeller(id: number, updateSellerDto: {
    fullName: string;
    email: string;
    phone?: string;
    password?: string;
  }) {
    try {
      // Vérifier si le vendeur existe
      const seller = await this.prisma.user.findUnique({
        where: { id }
      });

      if (!seller || seller.role !== UserRole.seller) {
        throw new Error('Vendeur introuvable');
      }

      // Vérifier si l'email est déjà utilisé par un autre utilisateur
      if (updateSellerDto.email !== seller.email) {
        const existingUser = await this.prisma.user.findUnique({
          where: { email: updateSellerDto.email }
        });

        if (existingUser) {
          throw new Error('Un utilisateur avec cet email existe déjà');
        }
      }

      const updateData: any = {
        fullName: updateSellerDto.fullName,
        email: updateSellerDto.email,
        phone: updateSellerDto.phone || null,
      };

      // Ajouter le mot de passe seulement s'il est fourni
      if (updateSellerDto.password) {
        updateData.password = await bcrypt.hash(updateSellerDto.password, 10);
      }

      const updatedSeller = await this.prisma.user.update({
        where: { id },
        data: updateData,
        include: {
          products: {
            select: { id: true }
          },
          orders: {
            select: { id: true }
          }
        }
      });

      return {
        ...updatedSeller,
        password: undefined,
        _count: {
          products: updatedSeller.products.length,
          orders: updatedSeller.orders.length
        }
      };
    } catch (error) {
      throw new Error('Erreur lors de la modification du vendeur: ' + error.message);
    }
  }

  /**
   * Supprimer un vendeur
   */
  async deleteSeller(id: number) {
    try {
      // Vérifier si le vendeur existe
      const seller = await this.prisma.user.findUnique({
        where: { id },
        include: {
          products: true,
          orders: true
        }
      });

      if (!seller || seller.role !== UserRole.seller) {
        throw new Error('Vendeur introuvable');
      }

      // Vérifier si le vendeur a des produits ou des commandes
      if (seller.products.length > 0 || seller.orders.length > 0) {
        throw new Error('Impossible de supprimer un vendeur avec des produits ou des commandes associées');
      }

      await this.prisma.user.delete({
        where: { id }
      });

      return { success: true, message: 'Vendeur supprimé avec succès' };
    } catch (error) {
      throw new Error('Erreur lors de la suppression du vendeur: ' + error.message);
    }
  }

  /**
   * Valider/rejeter un vendeur
   */
  async validateSeller(id: number, isValidated: boolean) {
    try {
      const seller = await this.prisma.user.findUnique({
        where: { id }
      });

      if (!seller || seller.role !== UserRole.seller) {
        throw new Error('Vendeur introuvable');
      }

      const updatedSeller = await this.prisma.user.update({
        where: { id },
        data: { isValidated },
        include: {
          products: {
            select: { id: true }
          },
          orders: {
            select: { id: true }
          }
        }
      });

      return {
        ...updatedSeller,
        password: undefined,
        _count: {
          products: updatedSeller.products.length,
          orders: updatedSeller.orders.length
        }
      };
    } catch (error) {
      throw new Error('Erreur lors de la validation du vendeur: ' + error.message);
    }
  }

  /**
   * Obtenir les statistiques des vendeurs
   */
  async getSellersStats() {
    try {
      const [
        totalSellers,
        validatedSellers,
        pendingSellers,
        sellersWithProducts
      ] = await Promise.all([
        this.prisma.user.count({ where: { role: UserRole.seller } }),
        this.prisma.user.count({ where: { role: UserRole.seller, isValidated: true } }),
        this.prisma.user.count({ where: { role: UserRole.seller, isValidated: false } }),
        this.prisma.user.count({
          where: {
            role: UserRole.seller,
            products: {
              some: {}
            }
          }
        })
      ]);

      return {
        total: totalSellers,
        validated: validatedSellers,
        pending: pendingSellers,
        withProducts: sellersWithProducts
      };
    } catch (error) {
      throw new Error('Erreur lors de la récupération des statistiques');
    }
  }
}
