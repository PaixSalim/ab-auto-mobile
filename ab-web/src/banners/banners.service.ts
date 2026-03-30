import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class BannersService {
  constructor(private prisma: PrismaService) {}

  async findAll() {
    return this.prisma.banner.findMany({
      orderBy: {
        createdAt: 'desc',
      },
    });
  }

  async findOne(id: number) {
    return this.prisma.banner.findUnique({
      where: { id },
    });
  }

  async create(data: {
    title: string;
    description: string;
    image: string;
    link?: string;
  }) {
    return this.prisma.banner.create({
      data: {
        title: data.title,
        description: data.description,
        image: data.image,
        link: data.link || '#',
      },
    });
  }

  async update(id: number, data: {
    title?: string;
    description?: string;
    image?: string;
    link?: string;
  }) {
    return this.prisma.banner.update({
      where: { id },
      data: {
        title: data.title,
        description: data.description,
        image: data.image,
        link: data.link || '#',
      },
    });
  }

  async remove(id: number) {
    return this.prisma.banner.delete({
      where: { id },
    });
  }
}
