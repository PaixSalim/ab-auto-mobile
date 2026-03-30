import { 
  Controller, 
  Get, 
  Post, 
  Body, 
  Patch, 
  Param, 
  Delete, 
  UseGuards, 
  Request,
  Query,
  HttpStatus,
  HttpCode
} from '@nestjs/common';
import { CustomerService } from './customer.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { UserRole } from '@prisma/client';

@Controller('customer')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.customer)
export class CustomerController {
  constructor(private readonly customerService: CustomerService) {}

  @Get('orders')
  async orders(@Query() query: any, @Request() req: any) {
    return this.customerService.getOrders(query, req.user);
  }

  @Get('orders/:id')
  async getOrder(@Param('id') id: string, @Request() req: any) {
    return this.customerService.getOrder(+id, req.user);
  }

  @Get('comments')
  async comments(@Query() query: any, @Request() req: any) {
    return this.customerService.getComments(query, req.user);
  }

  @Get('comments/:id')
  async getComment(@Param('id') id: string, @Request() req: any) {
    return this.customerService.getComment(+id, req.user);
  }

  @Post('comments')
  async createComment(@Body() createCommentDto: any, @Request() req: any) {
    return this.customerService.createComment(createCommentDto, req.user);
  }

  @Patch('comments/:id')
  async updateComment(@Param('id') id: string, @Body() updateCommentDto: any, @Request() req: any) {
    return this.customerService.updateComment(+id, updateCommentDto, req.user);
  }

  @Delete('comments/:id')
  async deleteComment(@Param('id') id: string, @Request() req: any) {
    return this.customerService.deleteComment(+id, req.user);
  }

  @Get('profile')
  async getProfile(@Request() req: any) {
    return this.customerService.getProfile(req.user);
  }

  @Patch('profile')
  async updateProfile(@Body() updateProfileDto: any, @Request() req: any) {
    return this.customerService.updateProfile(updateProfileDto, req.user);
  }
}
