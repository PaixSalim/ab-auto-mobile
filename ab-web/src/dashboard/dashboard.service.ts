import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UserRole, ValidationStatus } from '@prisma/client';

@Injectable()
export class DashboardService {
  constructor(private readonly prisma: PrismaService) {}

  async getDashboardData(user: any, isAdmin: boolean, isSeller: boolean) {
    // Fetch Stats
    let productsCount = 0;
    let ordersCount = 0;
    let pendingSellersCount = 0;
    let recentProducts: any[] = [];
    let pendingSellersList: any[] = [];
    let categoriesCount = 0;
    let brandsCount = 0;
    let customersCount = 0;
    let validatedSellersCount = 0;
    let pendingProductsCount = 0;
    let validatedProductsCount = 0;
    let commentsCount = 0;
    let recentOrders: any[] = [];

    if (isAdmin) {
      // Statistiques générales
      productsCount = await this.prisma.product.count();
      ordersCount = await this.prisma.order.count();
      categoriesCount = await this.prisma.category.count();
      brandsCount = await this.prisma.brand.count();

      // Statistiques utilisateurs
      customersCount = await this.prisma.user.count({
        where: { role: UserRole.customer }
      });
      pendingSellersCount = await this.prisma.user.count({
        where: { 
          role: UserRole.seller,
          isValidated: false 
        }
      });
      validatedSellersCount = await this.prisma.user.count({
        where: { 
          role: UserRole.seller,
          isValidated: true 
        }
      });

      // Statistiques produits
      pendingProductsCount = await this.prisma.product.count({
        where: { validationStatus: ValidationStatus.pending }
      });
      validatedProductsCount = await this.prisma.product.count({
        where: { validationStatus: ValidationStatus.approved }
      });
      
      // Statistiques commentaires
      commentsCount = await this.prisma.comment.count();

      // Données récentes
      recentProducts = await this.prisma.product.findMany({
        include: {
          category: true,
          brand: true,
        },
        orderBy: { createdAt: 'desc' },
        take: 5
      });

      recentOrders = await this.prisma.order.findMany({
        include: {
          customer: true,
          product: true,
        },
        orderBy: { createdAt: 'desc' },
        take: 5
      });

      pendingSellersList = await this.prisma.user.findMany({
        where: { 
          role: UserRole.seller,
          isValidated: false 
        },
        take: 5
      });
    } else if (isSeller) {
      productsCount = await this.prisma.product.count({
        where: { sellerId: user.id }
      });

      ordersCount = await this.prisma.order.count({
        where: {
          product: {
            sellerId: user.id
          }
        }
      });
      
      // Statistiques commentaires pour les vendeurs
      commentsCount = await this.prisma.comment.count({
        where: {
          product: {
            sellerId: user.id
          }
        }
      });

      recentProducts = await this.prisma.product.findMany({
        where: { sellerId: user.id },
        include: {
          category: true,
          brand: true,
        },
        orderBy: { createdAt: 'desc' },
        take: 5
      });

      recentOrders = await this.prisma.order.findMany({
        where: {
          product: {
            sellerId: user.id
          }
        },
        include: {
          customer: true,
          product: true,
        },
        orderBy: { createdAt: 'desc' },
        take: 5
      });
    }

    return {
      stats: {
        products: productsCount,
        orders: ordersCount,
        pendingSellers: pendingSellersCount,
        categories: categoriesCount,
        brands: brandsCount,
        customers: customersCount,
        validatedSellers: validatedSellersCount,
        pendingProducts: pendingProductsCount,
        validatedProducts: validatedProductsCount,
        comments: commentsCount
      },
      recentProducts,
      recentOrders,
      pendingSellersList
    };
  }

  async getAdminDashboardData(user: any) {
    return this.getDashboardData(user, true, false);
  }

  async getSellerDashboardData(user: any) {
    return this.getDashboardData(user, false, true);
  }
}
