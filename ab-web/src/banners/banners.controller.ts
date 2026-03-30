import { 
  Controller, 
  Get, 
  Post, 
  Body, 
  Patch, 
  Param, 
  Delete, 
  Request,
  Res,
  UploadedFile,
  UseInterceptors,
  BadRequestException,
  HttpStatus,
  HttpCode
} from '@nestjs/common';
import type { Response } from 'express';
import { FileInterceptor } from '@nestjs/platform-express';
import { BannersService } from './banners.service';
import { multerImageOptions } from '../common/configs/upload-storage';
import { InertiaService } from '../common/inertia/inertia.service';
import { PrismaService } from '../prisma/prisma.service';
import { redirectWithFlash } from '../common/inertia/flash';

// Étendre l'interface Request pour inclure nos propriétés personnalisées
declare global {
  namespace Express {
    interface Request {
      session?: any;
    }
  }
}

@Controller('dashboard/banners')
export class BannersController {
  constructor(
    private readonly bannersService: BannersService,
    private readonly inertiaService: InertiaService,
    private readonly prisma: PrismaService
  ) {}

  @Get()
  async index(@Request() req: any) {
    const user = req.user;
    if (!user) {
      throw new Error('Utilisateur non authentifié');
    }

    const banners = await this.bannersService.findAll();
    
    // Formatter les URLs pour les images
    const formattedBanners = banners.map(banner => ({
      ...banner,
      image: banner.image || '/uploads/banners/default-banner.jpg'
    }));

    // Récupérer les rôles de l'utilisateur exactement comme dans l'AppController
    const userWithRoles = await this.prisma.user.findUnique({
      where: { id: user.id },
      include: { roles: true }
    });

    const roles = userWithRoles?.roles.map((r: any) => r.slug) || [];
    

    return this.inertiaService.render('admin/banners/index', {
      banners: formattedBanners,
      auth: {
        user: user,
        roles: roles
      }
    });
  }

  @Get('create')
  async createForm(@Request() req: any) {
    // Récupérer les rôles de l'utilisateur comme dans l'AppController
    const userWithRoles = await this.prisma.user.findUnique({
      where: { id: req.user.id },
      include: { roles: true }
    });

    const roles = userWithRoles?.roles.map((r: any) => r.slug) || [];

    return this.inertiaService.render('admin/banners/create', {
      auth: {
        user: req.user,
        roles: roles
      }
    });
  }

  @Post('create')
  @UseInterceptors(FileInterceptor('image', multerImageOptions('banners')))
  async create(
    @Body() createBannerDto: any,
    @UploadedFile() file: Express.Multer.File,
    @Request() req: Express.Request,
    @Res() res: Response
  ) {
    try {

      // Si un fichier est uploadé, utiliser son URL
      if (file) {
        createBannerDto.image = `/uploads/banners/${file.filename}`;
      }

      // Nettoyer les données avant de les sauvegarder
      const bannerData = {
        title: createBannerDto.title,
        description: createBannerDto.description,
        image: createBannerDto.image || '/uploads/banners/default-banner.jpg',
        link: createBannerDto.link || '#'
      };


      const banner = await this.bannersService.create(bannerData);

      return redirectWithFlash(res, '/dashboard/banners', {
        type: 'success',
        message: 'Bannière créée.',
      });
    } catch (error) {

      return redirectWithFlash(res, '/dashboard/banners', {
        type: 'error',
        message:
          (error as Error).message || 'Erreur lors de la création de la bannière.',
      });
    }
  }

  @Get('edit/:id')
  async editForm(@Param('id') id: string, @Request() req: any, @Res() res: Response) {
    const banner = await this.bannersService.findOne(+id);
    
    if (!banner) {
      return redirectWithFlash(res, '/dashboard/banners', {
        type: 'warning',
        message: 'Bannière introuvable.',
      });
    }

    // Formatter l'URL de l'image
    const bannerWithUrl = {
      ...banner,
      image: banner.image || '/uploads/banners/default-banner.jpg'
    };

    // Récupérer les rôles de l'utilisateur comme dans l'AppController
    const userWithRoles = await this.prisma.user.findUnique({
      where: { id: req.user.id },
      include: { roles: true }
    });

    const roles = userWithRoles?.roles.map((r: any) => r.slug) || [];

    return this.inertiaService.render('admin/banners/edit', {
      banner: bannerWithUrl,
      auth: {
        user: req.user,
        roles: roles
      }
    });
  }

  @Post('edit/:id')
  @UseInterceptors(FileInterceptor('image', multerImageOptions('banners')))
  async update(
    @Param('id') id: string,
    @Body() updateBannerDto: any,
    @UploadedFile() file: Express.Multer.File,
    @Request() req: Express.Request,
    @Res() res: Response
  ) {
    try {

      const existingBanner = await this.bannersService.findOne(+id);
      if (!existingBanner) {
        return redirectWithFlash(res, '/dashboard/banners', {
          type: 'error',
          message: 'Bannière introuvable.',
        });
      }
      
      let imageUrl = existingBanner.image;
      
      // Traiter l'upload d'image si fourni
      if (file && file.filename) {
        imageUrl = `/uploads/banners/${file.filename}`;
      }

      // Nettoyer les données avant de les sauvegarder
      const bannerData = {
        title: updateBannerDto.title,
        description: updateBannerDto.description,
        image: imageUrl,
        link: updateBannerDto.link || '#'
      };


      const banner = await this.bannersService.update(+id, bannerData);

      return redirectWithFlash(res, '/dashboard/banners', {
        type: 'success',
        message: 'Bannière mise à jour.',
      });
    } catch (error) {

      return redirectWithFlash(res, '/dashboard/banners', {
        type: 'error',
        message:
          (error as Error).message || 'Erreur lors de la modification de la bannière.',
      });
    }
  }

  @Post('delete/:id')
  async remove(@Param('id') id: string, @Request() req: Express.Request, @Res() res: Response) {
    try {

      const banner = await this.bannersService.findOne(+id);
      if (!banner) {
        return redirectWithFlash(res, '/dashboard/banners', {
          type: 'warning',
          message: 'Bannière introuvable.',
        });
      }

      await this.bannersService.remove(+id);

      return redirectWithFlash(res, '/dashboard/banners', {
        type: 'success',
        message: 'Bannière supprimée.',
      });
    } catch (error) {

      return redirectWithFlash(res, '/dashboard/banners', {
        type: 'error',
        message:
          (error as Error).message || 'Erreur lors de la suppression de la bannière.',
      });
    }
  }
}
