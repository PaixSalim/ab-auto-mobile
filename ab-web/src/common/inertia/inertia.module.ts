import { Module, Global, forwardRef } from '@nestjs/common';
import { InertiaService } from './inertia.service';
import { AuthModule } from '../../auth/auth.module';

@Global()
@Module({
  imports: [forwardRef(() => AuthModule)],
  providers: [InertiaService],
  exports: [InertiaService],
})
export class InertiaModule {}
