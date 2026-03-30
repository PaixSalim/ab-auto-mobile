import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class CategoriesService {
  constructor(private prisma: PrismaService) {}

  async findAll() {
    return this.prisma.category.findMany({
      include: {
        subCategories: true,
      },
      orderBy: {
        name: 'asc'
      }
    });
  }

  async findOne(id: number) {
    return this.prisma.category.findUnique({
      where: { id },
      include: {
        subCategories: true,
        products: true,
      },
    });
  }

  async create(data: any) {
    // Si parentId est fourni comme chaîne vide, le convertir en null
    if (data.parentId === '') {
      data.parentId = null;
    }
    
    return this.prisma.category.create({
      data,
      include: {
        subCategories: true,
      }
    });
  }

  async update(id: number, data: any) {
    // Si parentId est fourni comme chaîne vide, le convertir en null
    if (data.parentId === '') {
      data.parentId = null;
    }
    
    return this.prisma.category.update({
      where: { id },
      data,
      include: {
        subCategories: true,
      }
    });
  }

  async remove(id: number) {
    // Vérifier si la catégorie a des sous-catégories
    const hasSubCategories = await this.prisma.category.count({
      where: { parentId: id }
    });

    if (hasSubCategories > 0) {
      throw new Error('Impossible de supprimer une catégorie qui contient des sous-catégories');
    }

    // Vérifier si la catégorie a des produits
    const hasProducts = await this.prisma.product.count({
      where: { categoryId: id }
    });

    if (hasProducts > 0) {
      throw new Error('Impossible de supprimer une catégorie qui contient des produits');
    }

    return this.prisma.category.delete({
      where: { id },
    });
  }

  async getMainCategories() {
    return this.prisma.category.findMany({
      where: { parentId: null },
      include: {
        subCategories: true,
      },
      orderBy: {
        name: 'asc'
      }
    });
  }
}
