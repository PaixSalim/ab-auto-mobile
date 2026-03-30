import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class BrandsService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.brand.findMany({
      include: {
        products: true,
      },
      orderBy: {
        name: 'asc'
      }
    });
  }

  async findOne(id: number) {
    return this.prisma.brand.findUnique({
      where: { id },
      include: {
        products: true,
      },
    });
  }

  async create(data: any) {
    return this.prisma.brand.create({
      data,
      include: {
        products: true,
      }
    });
  }

  async update(id: number, data: any) {
    return this.prisma.brand.update({
      where: { id },
      data,
      include: {
        products: true,
      }
    });
  }

  async remove(id: number) {
    // Vérifier si la marque a des produits
    const hasProducts = await this.prisma.product.count({
      where: { brandId: id }
    });

    if (hasProducts > 0) {
      throw new Error('Impossible de supprimer une marque qui contient des produits');
    }

    return this.prisma.brand.delete({
      where: { id },
    });
  }
}
