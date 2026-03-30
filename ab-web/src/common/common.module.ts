import { Module } from '@nestjs/common';
import { ValidationPipe } from './pipes/validation.pipe';

@Module({
  providers: [ValidationPipe],
  exports: [ValidationPipe],
})
export class CommonModule {}
