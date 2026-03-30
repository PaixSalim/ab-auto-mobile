import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class OrdersService {
  constructor(private prisma: PrismaService) {}

  async findAll() {
    return this.prisma.order.findMany({
      include: {
        product: true,
        customer: true,
      },
    });
  }

  async findBySeller(sellerId: number) {
    return this.prisma.order.findMany({
      where: {
        product: {
          sellerId,
        },
      },
      include: {
        product: {
          include: {
            medias: true,
          },
        },
      },
    });
  }

  async create(data: any) {
    return this.prisma.order.create({
      data,
    });
  }

  async updateStatus(id: number, status: string) {
    return this.prisma.order.update({
      where: { id },
      data: { status },
    });
  }
}
