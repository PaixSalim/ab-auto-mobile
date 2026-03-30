import { Injectable, ForbiddenException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class CustomerService {
  constructor(private readonly prisma: PrismaService) {}

  // Orders management for customer
  async getOrders(query: any = {}, user: any) {
    const { page = 1, limit = 10, search } = query;
    const skip = (page - 1) * limit;

    const where: any = { userId: user.id };
    
    if (search) {
      where.OR = [
        { product: { name: { contains: search, mode: 'insensitive' } } },
        { product: { description: { contains: search, mode: 'insensitive' } } }
      ];
    }

    const [orders, total] = await Promise.all([
      this.prisma.order.findMany({
        where,
        include: {
          product: true,
          customer: true,
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

  async getOrder(id: number, user: any) {
    const order = await this.prisma.order.findFirst({
      where: { 
        id,
        userId: user.id 
      },
      include: {
        product: true,
        customer: true,
      },
    });

    if (!order) {
      throw new NotFoundException('Commande non trouvée');
    }

    // Verify ownership
    if (order.userId !== user.id) {
      throw new ForbiddenException('Accès non autorisé à cette commande');
    }

    return order;
  }

  // Comments management for customer
  async getComments(query: any = {}, user: any) {
    const { page = 1, limit = 10, search } = query;
    const skip = (page - 1) * limit;

    const where: any = { userId: user.id };
    
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

  async getComment(id: number, user: any) {
    const comment = await this.prisma.comment.findFirst({
      where: { 
        id,
        userId: user.id 
      },
      include: {
        product: true,
      },
    });

    if (!comment) {
      throw new NotFoundException('Commentaire non trouvé');
    }

    // Verify ownership
    if (comment.userId !== user.id) {
      throw new ForbiddenException('Accès non autorisé à ce commentaire');
    }

    return comment;
  }

  async createComment(createCommentDto: any, user: any) {
    return this.prisma.comment.create({
      data: {
        comment: createCommentDto.comment,
        productId: Number(createCommentDto.productId),
        userId: Number(user.id),
        isActive: true,
      } as any,
      include: {
        product: true,
        author: true,
      },
    });
  }

  async updateComment(id: number, updateCommentDto: any, user: any) {
    // Verify ownership
    const comment = await this.prisma.comment.findFirst({
      where: { 
        id,
        userId: user.id 
      },
    });

    if (!comment) {
      throw new NotFoundException('Commentaire non trouvé');
    }

    if (comment.userId !== user.id) {
      throw new ForbiddenException('Accès non autorisé à ce commentaire');
    }

    return this.prisma.comment.update({
      where: { id },
      data: {
        comment: updateCommentDto.comment,
      },
    });
  }

  async deleteComment(id: number, user: any) {
    // Verify ownership
    const comment = await this.prisma.comment.findFirst({
      where: { 
        id,
        userId: user.id 
      },
    });

    if (!comment) {
      throw new NotFoundException('Commentaire non trouvé');
    }

    if (comment.userId !== user.id) {
      throw new ForbiddenException('Accès non autorisé à ce commentaire');
    }

    return this.prisma.comment.delete({
      where: { id }
    });
  }

  // Profile management
  async getProfile(user: any) {
    const profile = await this.prisma.user.findUnique({
      where: { id: user.id },
      select: {
        id: true,
        fullName: true,
        email: true,
        phone: true,
        city: true,
        neighborhood: true,
        createdAt: true,
      },
    });

    if (!profile) {
      throw new NotFoundException('Profil non trouvé');
    }

    return profile;
  }

  async updateProfile(updateProfileDto: any, user: any) {
    const { phone, city, neighborhood, ...otherData } = updateProfileDto;

    return this.prisma.user.update({
      where: { id: user.id },
      data: {
        phone,
        city,
        neighborhood,
        ...otherData,
      },
    });
  }
}
