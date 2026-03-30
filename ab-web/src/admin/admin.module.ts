import { Module } from '@nestjs/common';
import { AdminController } from './admin.controller';
import { AdminService } from './admin.service';
import { PrismaModule } from '../prisma/prisma.module';
import { ProductsModule } from '../products/products.module';
import { UsersModule } from '../users/users.module';
import { OrdersModule } from '../orders/orders.module';
import { ProductValidationModule } from './product-validation/product-validation.module';
import { AdminSellersModule } from './sellers/admin-sellers.module';
import { AdminCommentsModule } from './comments/admin-comments.module';
import { AdminPermissionsModule } from './permissions/admin-permissions.module';

@Module({
  imports: [PrismaModule, ProductsModule, UsersModule, OrdersModule, ProductValidationModule, AdminSellersModule, AdminCommentsModule, AdminPermissionsModule],
  controllers: [AdminController],
  providers: [AdminService],
  exports: [AdminService],
})
export class AdminModule {}
