import { 
  Controller, 
  Get, 
  Post, 
  Put, 
  Body, 
  Param, 
  Query,
  UseGuards,
  Req,
  Res,
  ForbiddenException,
  BadRequestException
} from '@nestjs/common';
import { Response } from 'express';
import { ProductValidationService } from './product-validation.service';
import { InertiaService } from '../../common/inertia/inertia.service';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/decorators/roles.decorator';
import { UserRole } from '@prisma/client';
import { redirectWithFlash } from '../../common/inertia/flash';

@Controller('admin/product-validation')
// @UseGuards(JwtAuthGuard, RolesGuard)
// @Roles(UserRole.admin, UserRole.superadmin)
export class ProductValidationController {
  constructor(
    private readonly productValidationService: ProductValidationService,
    private readonly inertia: InertiaService,
  ) {}

  /**
   * Route de test pour vérifier si le contrôleur est bien chargé
   */
  @Get('test')
  async test() {
    return { message: 'ProductValidationController is working!' };
  }

  /**
   * Afficher les produits en attente de validation
   */
  @Get()
  async index(@Res() res: Response, @Req() req: any) {
    try {
      
      const products = await this.productValidationService.getPendingProducts();
      const stats = await this.productValidationService.getValidationStats();


      return this.inertia.render('admin/product_validation/simple', {
        products,
        stats,
        auth: {
          user: req.user,
        },
      });
    } catch (error) {
      
      return this.inertia.render('admin/product_validation/simple', {
        products: [],
        stats: {},
        error: 'Erreur: ' + error.message,
        auth: {
          user: req.user,
        },
      });
    }
  }

  /**
   * Afficher tous les produits avec leur statut
   */
  @Get('all')
  async all(@Res() res: Response, @Req() req: any) {
    try {
      const products = await this.productValidationService.getAllProducts();
      const stats = await this.productValidationService.getValidationStats();

      return this.inertia.render('admin/product_validation/simple', {
        products,
        stats,
        auth: {
          user: req.user,
        },
      });
    } catch (error) {
      return this.inertia.render('admin/product_validation/simple', {
        products: [],
        stats: {},
        error: 'Erreur: ' + error.message,
        auth: {
          user: req.user,
        },
      });
    }
  }

  /**
   * Approuver un produit
   */
  @Post('approve')
  async approve(@Body() body: { productId: number }, @Req() req: any, @Res({ passthrough: true }) res: Response) {
    const { productId } = body;
    
    if (!productId) {
      throw new BadRequestException('ID du produit requis');
    }

    try {
      await this.productValidationService.approveProduct(productId);

      return redirectWithFlash(res, '/admin/product-validation', {
        type: 'success',
        message: 'Produit approuvé.',
      });
    } catch (error) {
      return redirectWithFlash(res, '/admin/product-validation', {
        type: 'error',
        message:
          'Erreur lors de l’approbation : ' + (error as Error).message,
      });
    }
  }

  /**
   * Rejeter un produit
   */
  @Post('reject')
  async reject(@Body() body: { productId: number; reason: string }, @Req() req: any, @Res({ passthrough: true }) res: Response) {
    const { productId, reason } = body;
    
    if (!productId) {
      throw new BadRequestException('ID du produit requis');
    }

    if (!reason || reason.trim() === '') {
      throw new BadRequestException('Veuillez fournir une raison de rejet');
    }

    try {
      await this.productValidationService.rejectProduct(productId, reason);

      return redirectWithFlash(res, '/admin/product-validation', {
        type: 'success',
        message: 'Produit rejeté.',
      });
    } catch (error) {
      return redirectWithFlash(res, '/admin/product-validation', {
        type: 'error',
        message: 'Erreur lors du rejet : ' + (error as Error).message,
      });
    }
  }

  /**
   * API endpoint pour obtenir les statistiques
   */
  @Get('stats')
  async getStats() {
    try {
      const stats = await this.productValidationService.getValidationStats();
      return {
        success: true,
        stats,
      };
    } catch (error) {
      return {
        success: false,
        message: 'Erreur lors de la récupération des statistiques: ' + error.message,
      };
    }
  }

  /**
   * API endpoint pour obtenir les produits en attente
   */
  @Get('pending')
  async getPendingProducts() {
    try {
      const products = await this.productValidationService.getPendingProducts();
      return {
        success: true,
        products,
      };
    } catch (error) {
      return {
        success: false,
        message: 'Erreur lors de la récupération des produits: ' + error.message,
      };
    }
  }
}
