import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateCommentDto, UpdateCommentDto, ToggleCommentStatusDto } from '../dto/comments.dto';

@Injectable()
export class CommentsService {
  constructor(private readonly prisma: PrismaService) {}

  async create(createCommentDto: CreateCommentDto) {
    return await this.prisma.comment.create({
      data: {
        productId: createCommentDto.productId,
        userId: createCommentDto.userId,
        user: createCommentDto.user,
        comment: createCommentDto.comment,
        ip: createCommentDto.ip || '',
        isActive: false,
      },
      include: {
        author: {
          select: {
            id: true,
            fullName: true,
          },
        },
        product: {
          select: {
            id: true,
            name: true,
          },
        },
        replies: {
          include: {
            author: {
              select: {
                id: true,
                fullName: true,
              },
            },
          },
        },
      },
    });
  }

  async findByProduct(productId: number) {
    return await this.prisma.comment.findMany({
      where: {
        productId,
        isActive: true,
      },
      include: {
        author: {
          select: {
            id: true,
            fullName: true,
          },
        },
        replies: {
          where: {
            isActive: true,
          },
          include: {
            author: {
              select: {
                id: true,
                fullName: true,
              },
            },
          },
          orderBy: {
            createdAt: 'asc',
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });
  }

  async findAll() {
    return await this.prisma.comment.findMany({
      include: {
        author: {
          select: {
            id: true,
            fullName: true,
          },
        },
        product: {
          select: {
            id: true,
            name: true,
          },
        },
        replies: {
          include: {
            author: {
              select: {
                id: true,
                fullName: true,
              },
            },
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });
  }

  async toggleStatus(id: number, status: boolean) {
    return await this.prisma.comment.update({
      where: { id },
      data: { isActive: status },
      include: {
        author: {
          select: {
            id: true,
            fullName: true,
          },
        },
        product: {
          select: {
            id: true,
            name: true,
          },
        },
      },
    });
  }

  async update(id: number, updateCommentDto: UpdateCommentDto) {
    return await this.prisma.comment.update({
      where: { id },
      data: updateCommentDto,
      include: {
        author: {
          select: {
            id: true,
            fullName: true,
          },
        },
        product: {
          select: {
            id: true,
            name: true,
          },
        },
      },
    });
  }

  async delete(id: number) {
    return await this.prisma.comment.delete({
      where: { id },
    });
  }

  async getProductComments() {
    return await this.prisma.product.findMany({
      select: {
        id: true,
        name: true,
      },
      orderBy: {
        name: 'asc',
      },
    });
  }
}
