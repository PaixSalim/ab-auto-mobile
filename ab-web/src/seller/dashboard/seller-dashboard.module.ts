import { Module } from '@nestjs/common';
import { SellerDashboardController } from './seller-dashboard.controller';
import { SellerDashboardService } from './seller-dashboard.service';
import { PrismaModule } from '../../prisma/prisma.module';
import { InertiaModule } from '../../common/inertia/inertia.module';
import { AuthModule } from '../../auth/auth.module';

@Module({
  imports: [
    PrismaModule,
    InertiaModule,
    AuthModule,
  ],
  controllers: [SellerDashboardController],
  providers: [SellerDashboardService],
  exports: [SellerDashboardService],
})
export class SellerDashboardModule {
  constructor() {
  }
}
