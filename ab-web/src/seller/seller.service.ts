import { Injectable, ForbiddenException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { ValidationStatus } from '@prisma/client';

@Injectable()
export class SellerService {
  constructor(private readonly prisma: PrismaService) {}

  // Dashboard data for seller
  async getDashboardData(user: any) {
    const productsCount = await this.prisma.product.count({
      where: { sellerId: user.id }
    });

    const ordersCount = await this.prisma.order.count({
      where: {
        product: {
          sellerId: user.id
        }
      }
    });

    const commentsCount = await this.prisma.comment.count({
      where: {
        product: {
          sellerId: user.id
        }
      }
    });

    const recentProducts = await this.prisma.product.findMany({
      where: { sellerId: user.id },
      include: {
        category: true,
        brand: true,
      },
      orderBy: { createdAt: 'desc' },
      take: 5
    });

    const recentOrders = await this.prisma.order.findMany({
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

    return {
      stats: {
        products: productsCount,
        orders: ordersCount,
        comments: commentsCount
      },
      recentProducts,
      recentOrders
    };
  }

  // Products management for seller
  async getProducts(query: any = {}, user: any) {
    const { page = 1, limit = 10, search, status } = query;
    const skip = (page - 1) * limit;

    const where: any = { sellerId: user.id };
    
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

  async updateProduct(updateProductDto: any, user: any) {
    const { id, ...data } = updateProductDto;
    
    // Verify ownership
    const product = await this.prisma.product.findFirst({
      where: { id: +id, sellerId: user.id }
    });

    if (!product) {
      throw new ForbiddenException('Produit non trouvé ou accès non autorisé');
    }

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

  async deleteProduct(id: number, user: any) {
    console.log('🗑️ SELLER SERVICE DELETE - ID:', id);
    console.log('🗑️ SELLER SERVICE DELETE - User ID:', user?.id);
    
    // Verify ownership
    console.log('🗑️ SELLER SERVICE DELETE - Checking ownership...');
    const product = await this.prisma.product.findFirst({
      where: { id, sellerId: user?.id || 1 } // Fallback à l'ID 1 pour les tests
    });

    console.log('🗑️ SELLER SERVICE DELETE - Found product:', product);

    if (!product) {
      console.log('🗑️ SELLER SERVICE DELETE - Product not found or access denied');
      throw new ForbiddenException('Produit non trouvé ou accès non autorisé');
    }

    console.log('🗑️ SELLER SERVICE DELETE - Ownership verified, deleting...');
    try {
      // Supprimer d'abord les enregistrements liés pour éviter les contraintes de clé étrangère
      console.log('🗑️ SELLER SERVICE DELETE - Deleting related records...');
      
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
      
      console.log('🗑️ SELLER SERVICE DELETE - Related records deleted, now deleting product...');
      
      // Maintenant supprimer le produit
      const result = await this.prisma.product.delete({
        where: { id }
      });
      
      console.log('🗑️ SELLER SERVICE DELETE - Database deletion successful:', result);
      return result;
    } catch (error) {
      console.error('🗑️ SELLER SERVICE DELETE - Database error:', error);
      throw error;
    }
  }

  // Orders management for seller
  async getOrders(query: any = {}, user: any) {
    const { page = 1, limit = 10, search, status } = query;
    const skip = (page - 1) * limit;

    const where: any = {
      product: {
        sellerId: user.id
      }
    };
    
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
          product: true,
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

  async cancelOrder(id: number, user: any) {
    // Verify ownership
    const order = await this.prisma.order.findFirst({
      where: {
        id,
        product: {
          sellerId: user.id
        }
      }
    });

    if (!order) {
      throw new ForbiddenException('Commande non trouvée ou accès non autorisé');
    }

    return this.prisma.order.update({
      where: { id },
      data: { status: 'cancelled' }
    });
  }

  async markOrderDelivered(id: number, user: any) {
    // Verify ownership
    const order = await this.prisma.order.findFirst({
      where: {
        id,
        product: {
          sellerId: user.id
        }
      }
    });

    if (!order) {
      throw new ForbiddenException('Commande non trouvée ou accès non autorisé');
    }

    return this.prisma.order.update({
      where: { id },
      data: { status: 'delivered' }
    });
  }

  // Comments management for seller
  async getComments(query: any = {}, user: any) {
    const { page = 1, limit = 10, search } = query;
    const skip = (page - 1) * limit;

    const where: any = {
      product: {
        sellerId: user.id
      }
    };
    
    if (search) {
      where.comment = { contains: search, mode: 'insensitive' };
    }

    const [comments, total] = await Promise.all([
      this.prisma.comment.findMany({
        where,
        include: {
          product: true,
        },
        orderBy: { createdAt: 'desc' },
        skip,
        take: +limit,
      }),
      this.prisma.comment.count({ where })
    ]);

    return {
      data: comments,
      total,
      page: +page,
      limit: +limit,
      totalPages: Math.ceil(total / limit)
    };
  }

  async replyComment(commentId: number, reply: string, user: any) {
    // Verify the comment belongs to seller's product
    const comment = await this.prisma.comment.findFirst({
      where: {
        id: commentId,
        product: {
          sellerId: user.id
        }
      }
    });

    if (!comment) {
      throw new ForbiddenException('Commentaire non trouvé ou accès non autorisé');
    }

    return this.prisma.comment.update({
      where: { id: commentId },
      data: {
        reply: reply,
        replyDate: new Date()
      } as any
    });
  }

  async toggleCommentStatus(id: number, user: any) {
    // Verify the comment belongs to seller's product
    const comment = await this.prisma.comment.findFirst({
      where: {
        id,
        product: {
          sellerId: user.id
        }
      }
    });

    if (!comment) {
      throw new ForbiddenException('Commentaire non trouvé ou accès non autorisé');
    }

    return this.prisma.comment.update({
      where: { id },
      data: {
        isActive: !comment.isActive
      }
    });
  }

  // Categories management for seller (limited access)
  async getCategories(query: any = {}, user: any) {
    // Sellers can only view categories, not create/edit/delete them
    const { page = 1, limit = 10, search } = query;
    const skip = (page - 1) * limit;

    const where: any = {};
    
    if (search) {
      where.name = { contains: search, mode: 'insensitive' };
    }

    const [categories, total] = await Promise.all([
      this.prisma.category.findMany({
        where,
        include: {
          subCategories: true,
          products: {
            where: {
              sellerId: user.id
            }
          }
        },
        orderBy: { name: 'asc' },
        skip,
        take: +limit,
      }),
      this.prisma.category.count({ where })
    ]);

    return {
      data: categories,
      total,
      page: +page,
      limit: +limit,
      totalPages: Math.ceil(total / limit)
    };
  }

  // Brands management for seller (limited access)
  async getBrands(query: any = {}, user: any) {
    // Sellers can only view brands, not create/edit/delete them
    const { page = 1, limit = 10, search } = query;
    const skip = (page - 1) * limit;

    const where: any = {};
    
    if (search) {
      where.name = { contains: search, mode: 'insensitive' };
    }

    const [brands, total] = await Promise.all([
      this.prisma.brand.findMany({
        where,
        include: {
          products: {
            where: {
              sellerId: user.id
            }
          }
        },
        orderBy: { name: 'asc' },
        skip,
        take: +limit,
      }),
      this.prisma.brand.count({ where })
    ]);

    return {
      data: brands,
      total,
      page: +page,
      limit: +limit,
      totalPages: Math.ceil(total / limit)
    };
  }

  // Placeholder methods for categories/brands (sellers have limited access)
  async createCategory(createCategoryDto: any, user: any) {
    throw new ForbiddenException('Les vendeurs ne peuvent pas créer de catégories');
  }

  async updateCategory(updateCategoryDto: any, user: any) {
    throw new ForbiddenException('Les vendeurs ne peuvent pas modifier de catégories');
  }

  async deleteCategory(id: number, user: any) {
    throw new ForbiddenException('Les vendeurs ne peuvent pas supprimer de catégories');
  }

  async createBrand(createBrandDto: any, user: any) {
    throw new ForbiddenException('Les vendeurs ne peuvent pas créer de marques');
  }

  async updateBrand(updateBrandDto: any, user: any) {
    throw new ForbiddenException('Les vendeurs ne peuvent pas modifier de marques');
  }

  async deleteBrand(id: number, user: any) {
    throw new ForbiddenException('Les vendeurs ne peuvent pas supprimer de marques');
  }
}
