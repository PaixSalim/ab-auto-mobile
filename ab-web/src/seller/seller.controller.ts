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
import type { Response } from 'express';
import { SellerService } from './seller.service';
import { InertiaService } from '../common/inertia/inertia.service';
import { PrismaService } from '../prisma/prisma.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { UserRole } from '@prisma/client';

@Controller('seller')
// @UseGuards(JwtAuthGuard, RolesGuard)
// @Roles(UserRole.seller)
export class SellerController {
  constructor(
    private readonly sellerService: SellerService,
    private readonly inertia: InertiaService,
    private readonly prisma: PrismaService
  ) {
    console.log('🔍 SELLER CONTROLLER - Controller loaded successfully');
  }

  // Log pour intercepter toutes les requêtes vers le contrôleur seller
  private logRequest(method: string, path: string, user: any) {
    console.log(`🔍 SELLER CONTROLLER - ${method} ${path}`, {
      timestamp: new Date().toISOString(),
      user: user ? `ID: ${user.id}, Email: ${user.email}` : 'NOT AUTHENTICATED',
      hasUser: !!user
    });
  }

  @Get()
  async dashboard(@Request() req: any, @Res() res: Response) {
    
    try {
      // Utilisateur fictif pour le test
      const mockUser = {
        id: 5,
        fullName: 'Vendeur Test',
        email: 'seller@test.com',
        role: 'seller',
        isValidated: true,
      };
      
      const dashboardData = await this.sellerService.getDashboardData(mockUser);
      
      
      const renderData = {
        stats: dashboardData.stats,
        recentProducts: dashboardData.recentProducts || [],
        auth: {
          user: mockUser,
          roles: ['seller'],
          permissions: ['view_products', 'view_orders', 'view_comments'],
        },
      };
      
      
      return this.inertia.render('seller/dashboard', renderData);
    } catch (error) {
      
      const fallbackData = {
        stats: { products: 0, orders: 0, comments: 0 },
        recentProducts: [],
        auth: {
          user: {
            id: 1,
            fullName: 'Vendeur Test',
            email: 'seller@test.com',
            role: 'seller',
            isValidated: true,
          },
          roles: ['seller'],
          permissions: ['view_products', 'view_orders', 'view_comments'],
        },
      };
      
      
      return this.inertia.render('seller/dashboard', fallbackData);
    }
  }

  @Get('test')
  async testRoute(@Res() res: Response) {
    return res.json({ message: 'Seller controller works!', timestamp: new Date() });
  }

  @Get('products')
  async products(@Query() query: any, @Request() req: any) {
    return this.sellerService.getProducts(query, req.user);
  }

  @Post('product/create')
  async createProduct(@Body() createProductDto: any, @Request() req: any) {
    return this.sellerService.createProduct(createProductDto, req.user);
  }

  @Patch('product/edit')
  async updateProduct(@Body() updateProductDto: any, @Request() req: any) {
    return this.sellerService.updateProduct(updateProductDto, req.user);
  }

  @Post('products/delete/:id')
  async deleteProduct(@Param('id') id: string, @Body() body: any, @Request() req: any, @Res() res: Response) {
    console.log('🗑️ SELLER DELETE - ID:', id);
    console.log('🗑️ SELLER DELETE - Received request for product ID:', id);
    console.log('🗑️ SELLER DELETE - Body:', body);
    
    try {
      // Utilisateur mock pour le test
      const mockUser = {
        id: 5, // ID du vendeur de test
        fullName: 'Vendeur Test',
        email: 'vendeur1@uvatis.com',
        role: 'seller'
      };
      
      console.log('🗑️ SELLER DELETE - Calling service...');
      await this.sellerService.deleteProduct(+id, req.user || mockUser);
      console.log('🗑️ SELLER DELETE - Service completed successfully');
      
      // Récupérer la liste mise à jour des produits
      const updatedProducts = await this.sellerService.getProducts({}, req.user || mockUser);
      
      // Retourner une redirection Inertia vers la page des produits
      return this.inertia.render('seller/products/index', {
        products: updatedProducts.data || [],
        auth: req.user || mockUser,
        success: 'Produit supprimé avec succès'
      });
    } catch (error) {
      console.error('🗑️ SELLER DELETE - Error:', error);
      
      // Récupérer la liste des produits même en cas d'erreur
      const products = await this.sellerService.getProducts({}, req.user || {
        id: 5,
        fullName: 'Vendeur Test',
        email: 'vendeur1@uvatis.com',
        role: 'seller'
      });
      
      return this.inertia.render('seller/products/index', {
        products: products.data || [],
        auth: req.user || {
          id: 5,
          fullName: 'Vendeur Test',
          email: 'vendeur1@uvatis.com',
          role: 'seller',
          isValidated: true,
        },
        error: 'Erreur lors de la suppression: ' + error.message
      });
    }
  }

  @Get('orders')
  async orders(@Query() query: any, @Request() req: any) {
    return this.sellerService.getOrders(query, req.user);
  }

  @Post('order/cancel')
  @HttpCode(HttpStatus.OK)
  async cancelOrder(@Body() body: { id: number }, @Request() req: any) {
    return this.sellerService.cancelOrder(body.id, req.user);
  }

  @Post('order/delivered')
  @HttpCode(HttpStatus.OK)
  async markOrderDelivered(@Body() body: { id: number }, @Request() req: any) {
    return this.sellerService.markOrderDelivered(body.id, req.user);
  }

  @Get('comments')
  async comments(@Res() res: Response, @Query() query: any, @Request() req: any) {
    
    try {
      // Utilisateur fictif pour le test
      const mockUser = {
        id: 5,
        fullName: 'Vendeur Test App',
        email: 'vendeur1@uvatis.com',
        role: 'seller',
        isValidated: true,
      };
      
      
      // Données de test simples
      const mockProducts = [
        {
          id: 1,
          name: 'iphone 4',
          comments: [
            {
              id: 1,
              user: 'Client 1',
              comment: 'Super produit ! Très satisfait de mon achat.',
              isActive: true,
              createdAt: '2026-03-28T10:00:00Z',
              productId: 1,
              ip: '192.168.1.100'
            },
            {
              id: 2,
              user: 'Client 2', 
              comment: 'Excellent téléphone, livraison rapide.',
              isActive: true,
              createdAt: '2026-03-28T11:00:00Z',
              productId: 1,
              ip: '192.168.1.101'
            }
          ]
        }
      ];
      
      
      return this.inertia.render('seller/comments/index', { 
        products: mockProducts,
        auth: {
          user: mockUser,
          roles: ['seller'],
          permissions: ['view_products', 'view_orders', 'view_comments'],
        }
      });
    } catch (error) {
      return res.status(500).json({ error: error.message });
    }
  }

  @Post('comments/reply')
  async replyComment(@Body() body: { commentId: number; reply: string }, @Request() req: any) {
    return this.sellerService.replyComment(body.commentId, body.reply, req.user);
  }

  @Patch('comments/toggle')
  async toggleCommentStatus(@Body() body: { id: number }, @Request() req: any) {
    return this.sellerService.toggleCommentStatus(body.id, req.user);
  }

  @Get('categories')
  async categories(@Query() query: any, @Request() req: any) {
    return this.sellerService.getCategories(query, req.user);
  }

  @Post('categories/create')
  async createCategory(@Body() createCategoryDto: any, @Request() req: any) {
    return this.sellerService.createCategory(createCategoryDto, req.user);
  }

  @Patch('categories/edit')
  async updateCategory(@Body() updateCategoryDto: any, @Request() req: any) {
    return this.sellerService.updateCategory(updateCategoryDto, req.user);
  }

  @Delete('categories/delete/:id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async deleteCategory(@Param('id') id: string, @Request() req: any) {
    return this.sellerService.deleteCategory(+id, req.user);
  }

  @Get('brands')
  async brands(@Query() query: any, @Request() req: any) {
    return this.sellerService.getBrands(query, req.user);
  }

  @Post('brands/create')
  async createBrand(@Body() createBrandDto: any, @Request() req: any) {
    return this.sellerService.createBrand(createBrandDto, req.user);
  }

  @Patch('brands/edit')
  async updateBrand(@Body() updateBrandDto: any, @Request() req: any) {
    return this.sellerService.updateBrand(updateBrandDto, req.user);
  }

  @Delete('brands/delete/:id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async deleteBrand(@Param('id') id: string, @Request() req: any) {
    return this.sellerService.deleteBrand(+id, req.user);
  }
}
