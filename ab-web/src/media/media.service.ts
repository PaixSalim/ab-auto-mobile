import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { MediaType } from '../products/products_interface';

@Injectable()
export class MediaService {
  constructor(private prisma: PrismaService) {}

  async createMedia(productId: number, url: string, type: string = 'image') {
    return this.prisma.media.create({
      data: {
        productId,
        url,
        type,
      },
    });
  }

  async removeMedia(id: number) {
    return this.prisma.media.delete({
      where: { id },
    });
  }
}
