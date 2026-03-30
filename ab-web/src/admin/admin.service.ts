import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UserRole, ValidationStatus } from '@prisma/client';

@Injectable()
export class AdminService {
  constructor(private readonly prisma: PrismaService) {}

  // Products management
  async getProducts(query: any = {}) {
    const { page = 1, limit = 10, search, status } = query;
    const skip = (page - 1) * limit;

    const where: any = {};
    
    if (search) {
      where.OR = [
        { name: { contains: search, mode: 'insensitive' } },
        { description: { contains: search, mode: 'insensitive' } }
      ];
    }

    if (status) {
      where.validationStatus = status;
    }

    const [products, total] = await Promise.all([
      this.prisma.product.findMany({
        where,
        include: {
          category: true,
          brand: true,
          seller: true,
          medias: true,
        },
        orderBy: { createdAt: 'desc' },
        skip,
        take: +limit,
      }),
      this.prisma.product.count({ where })
    ]);

    return {
      data: products,
      total,
      page: +page,
      limit: +limit,
      totalPages: Math.ceil(total / limit)
    };
  }

  async createProduct(createProductDto: any, user: any) {
    return this.prisma.product.create({
      data: {
        ...createProductDto,
        sellerId: user.id,
        slug: createProductDto.name.toLowerCase().replace(/ /g, '-'),
        validationStatus: ValidationStatus.pending,
      },
      include: {
        category: true,
        brand: true,
        seller: true,
      }
    });
  }

  async updateProduct(updateProductDto: any) {
    const { id, ...data } = updateProductDto;
    
    return this.prisma.product.update({
      where: { id: +id },
      data: {
        ...data,
        slug: data.name ? data.name.toLowerCase().replace(/ /g, '-') : undefined,
      },
      include: {
        category: true,
        brand: true,
        seller: true,
      }
    });
  }

  async deleteProduct(id: number) {
    console.log('🗑️ ADMIN SERVICE DELETE - ID:', id);
    console.log('🗑️ ADMIN SERVICE DELETE - Starting database deletion...');
    
    try {
      // Supprimer d'abord les enregistrements liés pour éviter les contraintes de clé étrangère
      console.log('🗑️ ADMIN SERVICE DELETE - Deleting related records...');
      
      // Supprimer les médias liés au produit
      await this.prisma.media.deleteMany({
        where: { productId: id }
      });
      
      // Supprimer les commentaires liés au produit
      await this.prisma.comment.deleteMany({
        where: { productId: id }
      });
      
      // Supprimer les commandes liées au produit
      await this.prisma.order.deleteMany({
        where: { productId: id }
      });
      
      // Supprimer les promotions liées au produit
      await this.prisma.promotion.deleteMany({
        where: { productId: id }
      });
      
      console.log('🗑️ ADMIN SERVICE DELETE - Related records deleted, now deleting product...');
      
      // Maintenant supprimer le produit
      const result = await this.prisma.product.delete({
        where: { id }
      });
      
      console.log('🗑️ ADMIN SERVICE DELETE - Database deletion successful:', result);
      return result;
    } catch (error) {
      console.error('🗑️ ADMIN SERVICE DELETE - Database error:', error);
      throw error;
    }
  }

  // Users management
  async getUsers(query: any = {}) {
    const { page = 1, limit = 10, search, role } = query;
    const skip = (page - 1) * limit;

    const where: any = {};
    
    if (search) {
      where.OR = [
        { fullName: { contains: search, mode: 'insensitive' } },
        { email: { contains: search, mode: 'insensitive' } }
      ];
    }

    if (role) {
      where.role = role;
    }

    const [users, total] = await Promise.all([
      this.prisma.user.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip,
        take: +limit,
        select: {
          id: true,
          fullName: true,
          email: true,
          role: true,
          isValidated: true,
          createdAt: true,
        }
      }),
      this.prisma.user.count({ where })
    ]);

    return {
      data: users,
      total,
      page: +page,
      limit: +limit,
      totalPages: Math.ceil(total / limit)
    };
  }

  async getSellers(query: any = {}) {
    return this.getUsers({ ...query, role: UserRole.seller });
  }

  async getCustomers(query: any = {}) {
    return this.getUsers({ ...query, role: UserRole.customer });
  }

  // Orders management
  async getOrders(query: any = {}) {
    const { page = 1, limit = 10, search, status } = query;
    const skip = (page - 1) * limit;

    const where: any = {};
    
    if (search) {
      where.OR = [
        { customer: { fullName: { contains: search, mode: 'insensitive' } } },
        { product: { name: { contains: search, mode: 'insensitive' } } }
      ];
    }

    if (status) {
      where.status = status;
    }

    const [orders, total] = await Promise.all([
      this.prisma.order.findMany({
        where,
        include: {
          customer: true,
          product: {
            include: {
              seller: true
            }
          }
        },
        orderBy: { createdAt: 'desc' },
        skip,
        take: +limit,
      }),
      this.prisma.order.count({ where })
    ]);

    return {
      data: orders,
      total,
      page: +page,
      limit: +limit,
      totalPages: Math.ceil(total / limit)
    };
  }

  async cancelOrder(id: number) {
    return this.prisma.order.update({
      where: { id },
      data: { status: 'cancelled' }
    });
  }

  async deleteOrder(id: number) {
    return this.prisma.order.delete({
      where: { id }
    });
  }

  async markOrderDelivered(id: number) {
    return this.prisma.order.update({
      where: { id },
      data: { status: 'delivered' }
    });
  }
}
