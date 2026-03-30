import { Module } from '@nestjs/common';
import { ProductValidationController } from './product-validation.controller';
import { ProductValidationService } from './product-validation.service';
import { PrismaModule } from '../../prisma/prisma.module';
import { InertiaModule } from '../../common/inertia/inertia.module';
import { AuthModule } from '../../auth/auth.module';

@Module({
  imports: [
    PrismaModule,
    InertiaModule,
    AuthModule,
  ],
  controllers: [ProductValidationController],
  providers: [ProductValidationService],
  exports: [ProductValidationService],
})
export class ProductValidationModule {}
