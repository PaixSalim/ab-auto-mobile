import { Module } from '@nestjs/common';
import { AdminPermissionsController } from './admin-permissions.controller';
import { AdminPermissionsService } from './admin-permissions.service';
import { PrismaModule } from '../../prisma/prisma.module';
import { InertiaModule } from '../../common/inertia/inertia.module';
import { AuthModule } from '../../auth/auth.module';

@Module({
  imports: [
    PrismaModule,
    InertiaModule,
    AuthModule,
  ],
  controllers: [AdminPermissionsController],
  providers: [AdminPermissionsService],
  exports: [AdminPermissionsService],
})
export class AdminPermissionsModule {}
