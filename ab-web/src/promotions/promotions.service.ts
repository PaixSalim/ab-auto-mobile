import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class PromotionsService {
  constructor(private readonly prisma: PrismaService) {}

  async getPromotions(query: any = {}) {
    const { page = 1, limit = 10, search, active } = query;
    const skip = (page - 1) * limit;

    const where: any = {};
    
    if (search) {
      where.OR = [
        { promoLabel: { contains: search, mode: 'insensitive' } },
        { url: { contains: search, mode: 'insensitive' } }
      ];
    }

    if (active !== undefined) {
      where.isActive = active === 'true';
    }

    const [promotions, total] = await Promise.all([
      this.prisma.promotion.findMany({
        where,
        include: {
          product: {
            include: {
              category: true,
              brand: true,
            }
          }
        },
        orderBy: { createdAt: 'desc' },
        skip,
        take: +limit,
      }),
      this.prisma.promotion.count({ where })
    ]);

    return {
      data: promotions,
      total,
      page: +page,
      limit: +limit,
      totalPages: Math.ceil(total / limit)
    };
  }

  async getPromotion(id: number) {
    return this.prisma.promotion.findUnique({
      where: { id },
      include: {
        product: {
          include: {
            category: true,
            brand: true,
          }
        }
      },
    });
  }

  async createPromotion(createPromotionDto: any) {
    const { productId, discountPercent, url, promoLabel, promoStartDate, promoEndDate } = createPromotionDto;

    return this.prisma.promotion.create({
      data: {
        productId: +productId,
        discountPercent: +discountPercent,
        url,
        promoLabel,
        promoStartDate: promoStartDate ? new Date(promoStartDate) : null,
        promoEndDate: promoEndDate ? new Date(promoEndDate) : null,
      },
      include: {
        product: {
          include: {
            category: true,
            brand: true,
          }
        }
      },
    });
  }

  async updatePromotion(id: number, updatePromotionDto: any) {
    const { productId, discountPercent, url, promoLabel, promoStartDate, promoEndDate } = updatePromotionDto;

    return this.prisma.promotion.update({
      where: { id },
      data: {
        productId: productId ? +productId : undefined,
        discountPercent: discountPercent ? +discountPercent : undefined,
        url,
        promoLabel,
        promoStartDate: promoStartDate ? new Date(promoStartDate) : undefined,
        promoEndDate: promoEndDate ? new Date(promoEndDate) : undefined,
      },
    });
  }

  async deletePromotion(id: number) {
    return this.prisma.promotion.delete({
      where: { id }
    });
  }

  async getActivePromotions(query: any = {}) {
    return this.getPromotions({ ...query, active: 'true' });
  }

  async getPromotionsByProduct(productId: number, query: any = {}) {
    const { page = 1, limit = 10 } = query;
    const skip = (page - 1) * limit;

    const where: any = { productId: +productId };

    const [promotions, total] = await Promise.all([
      this.prisma.promotion.findMany({
        where,
        include: {
          product: {
            include: {
              category: true,
              brand: true,
            }
          }
        },
        orderBy: { createdAt: 'desc' },
        skip,
        take: +limit,
      }),
      this.prisma.promotion.count({ where })
    ]);

    return {
      data: promotions,
      total,
      page: +page,
      limit: +limit,
      totalPages: Math.ceil(total / limit)
    };
  }
}
