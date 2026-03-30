import { Module } from '@nestjs/common';
import { ApiController } from './api.controller';
import { PrismaModule } from '../prisma/prisma.module';
import { ProductsModule } from '../products/products.module';
import { CategoriesModule } from '../categories/categories.module';
import { BrandsModule } from '../brands/brands.module';
import { CommentsModule } from '../comments/comments.module';
import { OrdersModule } from '../orders/orders.module';
import { PromotionsModule } from '../promotions/promotions.module';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [
    PrismaModule,
    ProductsModule,
    CategoriesModule,
    BrandsModule,
    CommentsModule,
    OrdersModule,
    PromotionsModule,
    AuthModule,
  ],
  controllers: [ApiController],
  providers: [],
  exports: [],
})
export class ApiModule {}
