import { 
  Controller, 
  Get, 
  Post, 
  Put, 
  Delete, 
  Body, 
  Param, 
  Res,
  Req,
  BadRequestException,
  NotFoundException
} from '@nestjs/common';
import { Response } from 'express';
import { AdminSellersService } from './admin-sellers.service';
import { InertiaService } from '../../common/inertia/inertia.service';
import { redirectWithFlash } from '../../common/inertia/flash';

@Controller('sellers-admin')
export class AdminSellersController {
  constructor(
    private readonly adminSellersService: AdminSellersService,
    private readonly inertia: InertiaService,
  ) {
  }

  /**
   * Liste des vendeurs
   */
  @Get()
  async index(@Res() res: Response, @Req() req: any) {
    try {
      
      const page = parseInt(req.query.page) || 1;
      const sellersData = await this.adminSellersService.getAllSellersPaginated(page);
      const stats = await this.adminSellersService.getSellersStats();

      // Forcer toujours la réponse Inertia pour cette route
      return this.inertia.render('admin/sellers/index', {
        sellers: sellersData,
        stats,
      });
    } catch (error) {
      
      return this.inertia.render('admin/sellers/index', {
        sellers: { data: [], meta: { total: 0, per_page: 10, current_page: 1, last_page: 1, first_page: 1, from: 0, to: 0, links: [] } },
        stats: { total: 0, validated: 0, pending: 0, recent: [] },
      });
    }
  }

  /**
   * Créer un nouveau vendeur
   */
  @Post('create')
  async create(@Body() createSellerDto: {
    fullName: string;
    email: string;
    password: string;
    phone?: string;
  }, @Res({ passthrough: true }) res: Response) {
    // Validation basique
    if (!createSellerDto.fullName || createSellerDto.fullName.length < 3) {
      throw new BadRequestException('Le nom complet doit contenir au moins 3 caractères');
    }

    if (!createSellerDto.email || !this.isValidEmail(createSellerDto.email)) {
      throw new BadRequestException('Email invalide');
    }

    if (!createSellerDto.password || createSellerDto.password.length < 8) {
      throw new BadRequestException('Le mot de passe doit contenir au moins 8 caractères');
    }

    try {
      await this.adminSellersService.createSeller(createSellerDto);
      return redirectWithFlash(res, '/admin/sellers', {
        type: 'success',
        message: 'Vendeur créé.',
      });
    } catch (error) {
      return redirectWithFlash(res, '/admin/sellers', {
        type: 'error',
        message: 'Impossible de créer le vendeur.',
      });
    }
  }

  /**
   * Mettre à jour un vendeur
   */
  @Put(':id')
  async update(
    @Param('id') id: string,
    @Body() updateSellerDto: {
      fullName: string;
      email: string;
      phone?: string;
      password?: string;
    },
    @Res({ passthrough: true }) res: Response
  ) {
    // Validation basique
    if (!updateSellerDto.fullName || updateSellerDto.fullName.length < 3) {
      throw new BadRequestException('Le nom complet doit contenir au moins 3 caractères');
    }

    if (!updateSellerDto.email || !this.isValidEmail(updateSellerDto.email)) {
      throw new BadRequestException('Email invalide');
    }

    if (updateSellerDto.password && updateSellerDto.password.length < 8) {
      throw new BadRequestException('Le mot de passe doit contenir au moins 8 caractères');
    }

    try {
      await this.adminSellersService.updateSeller(parseInt(id), updateSellerDto);
      return redirectWithFlash(res, '/admin/sellers', {
        type: 'success',
        message: 'Vendeur mis à jour.',
      });
    } catch (error) {
      return redirectWithFlash(res, '/admin/sellers', {
        type: 'error',
        message: 'Impossible de mettre à jour le vendeur.',
      });
    }
  }

  /**
   * Supprimer un vendeur
   */
  @Delete(':id')
  async delete(@Param('id') id: string, @Res({ passthrough: true }) res: Response) {
    try {
      await this.adminSellersService.deleteSeller(parseInt(id));
      return redirectWithFlash(res, '/admin/sellers', {
        type: 'success',
        message: 'Vendeur supprimé.',
      });
    } catch (error) {
      return redirectWithFlash(res, '/admin/sellers', {
        type: 'error',
        message: 'Impossible de supprimer le vendeur.',
      });
    }
  }

  /**
   * Valider un vendeur
   */
  @Post(':id/validate')
  async validate(@Param('id') id: string, @Res({ passthrough: true }) res: Response) {
    try {
      await this.adminSellersService.validateSeller(parseInt(id), true);
      return redirectWithFlash(res, '/admin/sellers', {
        type: 'success',
        message: 'Vendeur validé.',
      });
    } catch (error) {
      return redirectWithFlash(res, '/admin/sellers', {
        type: 'error',
        message: 'Impossible de valider le vendeur.',
      });
    }
  }

  /**
   * Rejeter un vendeur
   */
  @Post(':id/reject')
  async reject(@Param('id') id: string, @Res({ passthrough: true }) res: Response) {
    try {
      await this.adminSellersService.validateSeller(parseInt(id), false);
      return redirectWithFlash(res, '/admin/sellers', {
        type: 'success',
        message: 'Validation du vendeur révoquée.',
      });
    } catch (error) {
      return redirectWithFlash(res, '/admin/sellers', {
        type: 'error',
        message: 'Impossible de mettre à jour le statut.',
      });
    }
  }

  /**
   * API endpoint pour obtenir les statistiques
   */
  @Get('stats')
  async getStats() {
    try {
      const stats = await this.adminSellersService.getSellersStats();
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
   * API endpoint pour obtenir un vendeur spécifique
   */
  @Get(':id')
  async getOne(@Param('id') id: string) {
    try {
      const sellersData = await this.adminSellersService.getAllSellersPaginated(1, 1000); // Beaucoup de résultats pour trouver
      const seller = sellersData.data.find(s => s.id === parseInt(id));
      
      if (!seller) {
        throw new NotFoundException('Vendeur introuvable');
      }

      return {
        success: true,
        seller,
      };
    } catch (error) {
      return {
        success: false,
        message: 'Erreur lors de la récupération du vendeur: ' + error.message,
      };
    }
  }

  /**
   * Basculer la validation d'un vendeur
   */
  @Put('toggle-validation/:id')
  async toggleValidation(@Param('id') id: string) {
    try {
      const seller = await this.adminSellersService.toggleValidation(parseInt(id));
      return {
        success: true,
        message: 'Validation du vendeur mise à jour avec succès',
        seller,
      };
    } catch (error) {
      return {
        success: false,
        message: 'Erreur lors de la mise à jour de la validation: ' + error.message,
      };
    }
  }

  /**
   * Helper pour valider un email
   */
  private isValidEmail(email: string): boolean {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }
}
