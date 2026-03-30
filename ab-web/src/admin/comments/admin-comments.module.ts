import { Module } from '@nestjs/common';
import { AdminCommentsController } from './admin-comments.controller';
import { AdminCommentsService } from './admin-comments.service';
import { PrismaModule } from '../../prisma/prisma.module';
import { InertiaModule } from '../../common/inertia/inertia.module';
import { AuthModule } from '../../auth/auth.module';

@Module({
  imports: [
    PrismaModule,
    InertiaModule,
    AuthModule,
  ],
  controllers: [AdminCommentsController],
  providers: [AdminCommentsService],
  exports: [AdminCommentsService],
})
export class AdminCommentsModule {}
