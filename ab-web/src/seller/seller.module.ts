import { Module } from '@nestjs/common';
import { SellerController } from './seller.controller';
import { SellerService } from './seller.service';
import { SellerDashboardModule } from './dashboard/seller-dashboard.module';
import { PrismaModule } from '../prisma/prisma.module';
import { ProductsModule } from '../products/products.module';
import { OrdersModule } from '../orders/orders.module';
import { CommentsModule } from '../comments/comments.module';

@Module({
  imports: [PrismaModule, ProductsModule, OrdersModule, CommentsModule, SellerDashboardModule],
  controllers: [SellerController],
  providers: [SellerService],
  exports: [SellerService],
})
export class SellerModule {}
