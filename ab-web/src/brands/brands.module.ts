import { Module } from '@nestjs/common';
import { BrandsController } from './brands.controller';
import { BrandsService } from './brands.service';
import { PrismaModule } from '../prisma/prisma.module';
import { InertiaModule } from '../common/inertia/inertia.module';

@Module({
  imports: [PrismaModule, InertiaModule],
  providers: [BrandsService],
  controllers: [BrandsController],
  exports: [BrandsService],
})
export class BrandsModule {}
