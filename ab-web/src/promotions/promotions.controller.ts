import { 
  Controller, 
  Get, 
  Post, 
  Body, 
  Patch, 
  Param, 
  Delete, 
  UseGuards, 
  Query,
  HttpStatus,
  HttpCode
} from '@nestjs/common';
import { PromotionsService } from './promotions.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { UserRole } from '@prisma/client';

@Controller('promotions')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.admin, UserRole.superadmin)
export class PromotionsController {
  constructor(private readonly promotionsService: PromotionsService) {}

  @Get()
  async getPromotions(@Query() query: any) {
    return this.promotionsService.getPromotions(query);
  }

  @Get('active')
  async getActivePromotions(@Query() query: any) {
    return this.promotionsService.getActivePromotions(query);
  }

  @Get(':id')
  async getPromotion(@Param('id') id: string) {
    return this.promotionsService.getPromotion(+id);
  }

  @Get('product/:id')
  async getPromotionsByProduct(@Param('id') id: string, @Query() query: any) {
    return this.promotionsService.getPromotionsByProduct(+id, query);
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async createPromotion(@Body() createPromotionDto: any) {
    return this.promotionsService.createPromotion(createPromotionDto);
  }

  @Patch(':id')
  async updatePromotion(@Param('id') id: string, @Body() updatePromotionDto: any) {
    return this.promotionsService.updatePromotion(+id, updatePromotionDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async deletePromotion(@Param('id') id: string) {
    return this.promotionsService.deletePromotion(+id);
  }
}
