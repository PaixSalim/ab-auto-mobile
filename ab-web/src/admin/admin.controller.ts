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
  HttpCode,
  Res
} from '@nestjs/common';
import { AdminService } from './admin.service';
import { InertiaService } from '../common/inertia/inertia.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { UserRole } from '@prisma/client';
import type { Response } from 'express';

@Controller('admin')
// @UseGuards(JwtAuthGuard, RolesGuard)
// @Roles(UserRole.admin, UserRole.superadmin)
export class AdminController {
  constructor(
  private readonly adminService: AdminService,
  private readonly inertia: InertiaService
) {}

  @Get('products')
  async products(@Query() query: any) {
    return this.adminService.getProducts(query);
  }

  @Post('product/create')
  async createProduct(@Body() createProductDto: any, @Request() req: any) {
    return this.adminService.createProduct(createProductDto, req.user);
  }

  @Patch('product/edit')
  async updateProduct(@Body() updateProductDto: any) {
    return this.adminService.updateProduct(updateProductDto);
  }

  @Post('product/delete/:id')
  async deleteProduct(@Param('id') id: string, @Body() body: any, @Request() req: any, @Res() res: Response) {
    console.log('🗑️ ADMIN DELETE PRODUCT - ID:', id);
    console.log('🗑️ ADMIN DELETE PRODUCT - Body:', body);
    
    try {
      // Utilisateur mock pour le test
      const mockUser = {
        id: 1, // ID de l'admin de test
        fullName: 'Admin Test',
        email: 'admin@uvatis.com',
        role: 'admin'
      };
      
      console.log('🗑️ ADMIN DELETE PRODUCT - Calling service...');
      await this.adminService.deleteProduct(+id);
      console.log('🗑️ ADMIN DELETE PRODUCT - Service completed successfully');
      
      // Récupérer la liste mise à jour des produits
      const updatedProducts = await this.adminService.getProducts();
      
      // Retourner une redirection Inertia vers la page admin
      return this.inertia.render('admin/products', {
        products: updatedProducts.data || [],
        auth: req.user || mockUser,
        success: 'Produit supprimé avec succès'
      });
    } catch (error) {
      console.error('🗑️ ADMIN DELETE PRODUCT - Error:', error);
      
      // Récupérer la liste des produits même en cas d'erreur
      const products = await this.adminService.getProducts();
      
      return this.inertia.render('admin/products', {
        products: products.data || [],
        auth: req.user || {
          id: 1,
          fullName: 'Admin Test',
          email: 'admin@uvatis.com',
          role: 'admin'
        },
        error: 'Erreur lors de la suppression: ' + error.message
      });
    }
  }

  @Get('users')
  async users(@Query() query: any) {
    return this.adminService.getUsers(query);
  }

  @Get('sellers')
  async sellers(@Query() query: any) {
    return this.adminService.getSellers(query);
  }

  @Get('customers')
  async customers(@Query() query: any) {
    return this.adminService.getCustomers(query);
  }

  @Get('orders')
  async orders(@Query() query: any) {
    return this.adminService.getOrders(query);
  }

  @Post('order/cancel')
  @HttpCode(HttpStatus.OK)
  async cancelOrder(@Body() body: { id: number }) {
    return this.adminService.cancelOrder(body.id);
  }

  @Post('order/delete')
  @HttpCode(HttpStatus.OK)
  async deleteOrder(@Body() body: { id: number }) {
    return this.adminService.deleteOrder(body.id);
  }

  @Post('order/delivered')
  @HttpCode(HttpStatus.OK)
  async markOrderDelivered(@Body() body: { id: number }) {
    return this.adminService.markOrderDelivered(body.id);
  }
}
