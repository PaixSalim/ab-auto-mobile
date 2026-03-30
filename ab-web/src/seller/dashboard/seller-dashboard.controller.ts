import { 
  Controller, 
  Get, 
  Res, 
  Req,
  UseGuards,
  SetMetadata
} from '@nestjs/common';
import { Response } from 'express';
import { SellerDashboardService } from './seller-dashboard.service';
import { InertiaService } from '../../common/inertia/inertia.service';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/decorators/roles.decorator';
import { UserRole } from '@prisma/client';

// Décorateur pour marquer les routes publiques
export const Public = () => SetMetadata('isPublic', true);

@Controller('seller-dashboard')
// @UseGuards(JwtAuthGuard, RolesGuard)
// @Roles(UserRole.seller)
export class SellerDashboardController {
  constructor(
    private readonly sellerDashboardService: SellerDashboardService,
    private readonly inertia: InertiaService,
  ) {
  }

  /**
   * Dashboard vendeur
   */
  @Get()
  async dashboard(@Res() res: Response, @Req() req: any) {
    try {
      
      // Utilisateur fictif pour le test
      const mockUser = {
        id: 1,
        fullName: 'Vendeur Test',
        email: 'seller@test.com',
        role: 'seller',
        isValidated: true,
        createdAt: new Date()
      };
      
      const stats = await this.sellerDashboardService.getSellerStats(mockUser.id);

      
      // Forcer toujours la réponse Inertia pour cette route
      return this.inertia.render('seller/test', {
        stats,
        auth: {
          user: mockUser,
          roles: ['seller'],
          permissions: ['view_products', 'view_orders', 'view_comments'],
        },
      });
    } catch (error) {
      
      // Utilisateur fictif pour le test
      const mockUser = {
        id: 1,
        fullName: 'Vendeur Test',
        email: 'seller@test.com',
        role: 'seller',
        isValidated: true,
        createdAt: new Date()
      };
      
      return this.inertia.render('seller/test', {
        stats: {
          products: 0,
          orders: 0,
          comments: 0,
        },
        auth: {
          user: mockUser,
          roles: ['seller'],
          permissions: ['view_products', 'view_orders', 'view_comments'],
        },
      });
    }
  }
}
