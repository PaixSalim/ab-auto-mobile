import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateProductDto, UpdateProductDto } from './dto/create-product.dto';

@Injectable()
export class ProductsService {
  constructor(private prisma: PrismaService) {}

  async findAll() {
    return this.prisma.product.findMany({
      include: {
        category: true,
        brand: true,
        medias: true,
      },
    });
  }

  async findAllApproved() {
    return this.prisma.product.findMany({
      where: {
        validationStatus: 'approved'
      },
      include: {
        category: true,
        brand: true,
        medias: true,
      },
    });
  }

  async findOne(id: number) {
    const product = await this.prisma.product.findUnique({
      where: { id },
      include: {
        category: true,
        brand: true,
        medias: true,
        comments: {
          include: {
            author: true,
            replies: true,
          },
        },
      },
    });
    if (!product) throw new NotFoundException('Product not found');
    return product;
  }

  async findBySlug(slug: string) {
    const product = await this.prisma.product.findUnique({
      where: { slug },
      include: {
        category: true,
        brand: true,
        medias: true,
        comments: {
          include: {
            author: true,
            replies: true,
          },
        },
      },
    });
    if (!product) throw new NotFoundException('Product not found');
    return product;
  }

  async create(data: CreateProductDto, sellerId?: number) {
    if (!data || !data.name) {
      throw new Error('Product name is required');
    }

    return this.prisma.product.create({
      data: {
        ...data,
        sellerId,
        slug: data.name.toLowerCase().replace(/ /g, '-').replace(/[^a-z0-9-]/g, ''), // Improved slugifier
      },
    });
  }

  async update(id: number, data: UpdateProductDto) {
    return this.prisma.product.update({
      where: { id },
      data,
    });
  }

  async remove(id: number) {
    return this.prisma.product.delete({
      where: { id },
    });
  }
}
