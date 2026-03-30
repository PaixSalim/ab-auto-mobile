import { 
  Controller, 
  Get, 
  UseGuards, 
  Request,
  ForbiddenException 
} from '@nestjs/common';
import { DashboardService } from './dashboard.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { UserRole } from '@prisma/client';

@Controller('dashboard')
@UseGuards(JwtAuthGuard, RolesGuard)
export class DashboardController {
  constructor(private readonly dashboardService: DashboardService) {}

  @Get()
  async index(@Request() req: any) {
    const user = req.user;
    
    if (!user) {
      throw new ForbiddenException('Utilisateur non authentifié');
    }

    const roles = user.roles || [];
    const isAdmin = roles.includes('admin') || roles.includes('superadmin');
    const isSeller = roles.includes('seller');

    if (!isAdmin && !isSeller) {
      throw new ForbiddenException('Accès non autorisé');
    }

    // Récupérer les données du dashboard
    const dashboardData = await this.dashboardService.getDashboardData(user, isAdmin, isSeller);

    return {
      auth: {
        user: {
          ...user,
          isValidated: user.isValidated || false
        },
        roles: roles
      },
      ...dashboardData
    };
  }

  @Get('admin')
  @Roles(UserRole.admin, UserRole.superadmin)
  async adminDashboard(@Request() req: any) {
    const user = req.user;
    const dashboardData = await this.dashboardService.getAdminDashboardData(user);
    
    return {
      auth: {
        user: {
          ...user,
          isValidated: user.isValidated || false
        },
        roles: user.roles || []
      },
      ...dashboardData
    };
  }

  @Get('seller')
  @Roles(UserRole.seller)
  async sellerDashboard(@Request() req: any) {
    const user = req.user;
    const dashboardData = await this.dashboardService.getSellerDashboardData(user);
    
    return {
      auth: {
        user: {
          ...user,
          isValidated: user.isValidated || false
        },
        roles: user.roles || []
      },
      ...dashboardData
    };
  }
}
