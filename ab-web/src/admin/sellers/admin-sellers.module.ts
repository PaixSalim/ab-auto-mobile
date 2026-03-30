import { Module } from '@nestjs/common';
import { AdminSellersController } from './admin-sellers.controller';
import { AdminSellersService } from './admin-sellers.service';
import { PrismaModule } from '../../prisma/prisma.module';
import { InertiaModule } from '../../common/inertia/inertia.module';
import { AuthModule } from '../../auth/auth.module';

@Module({
  imports: [
    PrismaModule,
    InertiaModule,
    AuthModule,
  ],
  controllers: [AdminSellersController],
  providers: [AdminSellersService],
  exports: [AdminSellersService],
})
export class AdminSellersModule {
  constructor() {
  }
}
