import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Res, Req, BadRequestException } from '@nestjs/common';
import { Request, Response } from 'express';
import { BrandsService } from './brands.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { FileInterceptor } from '@nestjs/platform-express';
import { UseInterceptors, UploadedFile } from '@nestjs/common';
import { InertiaService } from '../common/inertia/inertia.service';
import { multerImageOptions } from '../common/configs/upload-storage';
import { redirectWithFlash, setFlashCookie } from '../common/inertia/flash';

interface SessionRequest extends Request {
  session: any;
}

@Controller('dashboard/brands')
@UseGuards(JwtAuthGuard, RolesGuard)
export class BrandsController {
  constructor(
    private readonly brandsService: BrandsService,
    private readonly inertiaService: InertiaService
  ) {}

  @Get()
  @Roles('admin', 'superadmin')
  async findAll(@Req() req: Request, @Res({ passthrough: true }) res: Response) {
    this.inertiaService.init(req, res);
    
    const brands = await this.brandsService.findAll();
    
    return this.inertiaService.render('admin/brands/index', { brands });
  }

  @Get(':id')
  @Roles('admin', 'superadmin')
  async findOne(@Param('id') id: string) {
    return this.brandsService.findOne(+id);
  }

  @Post('create')
  @Roles('admin', 'superadmin')
  @UseInterceptors(FileInterceptor('image', multerImageOptions('brands')))
  async create(
    @Body() createBrandDto: any,
    @UploadedFile() file: Express.Multer.File,
    @Req() req: SessionRequest,
    @Res({ passthrough: true }) res: Response
  ) {
    try {

      // Si un fichier est uploadé, utiliser son URL
      if (file) {
        createBrandDto.url = `/uploads/brands/${file.filename}`;
      }

      // Nettoyer les données avant de les sauvegarder
      const brandData: any = {
        name: createBrandDto.name,
        url: createBrandDto.url || null
      };

      // Ajouter categoryId seulement s'il est fourni
      if (createBrandDto.categoryId) {
        brandData.categoryId = parseInt(createBrandDto.categoryId);
      }


      const brand = await this.brandsService.create(brandData);

      setFlashCookie(res, {
        type: 'success',
        message: 'Marque créée.',
      });
      return {
        success: true,
        message: 'Marque créée avec succès',
        data: brand
      };
    } catch (error) {
      
      // Flash message d'erreur pour Inertia
      if (!req.session) req.session = {};
      if (!req.session.flash) req.session.flash = {};
      req.session.flash.notification = {
        type: 'error',
        message: error.message || 'Erreur lors de la création de la marque'
      };
      
      throw new BadRequestException(error.message || 'Erreur lors de la création de la marque');
    }
  }

  @Post('edit/:id')
  @Roles('admin', 'superadmin')
  @UseInterceptors(FileInterceptor('image', multerImageOptions('brands')))
  async update(
    @Param('id') id: string,
    @Body() updateBrandDto: any,
    @UploadedFile() file: Express.Multer.File,
    @Req() req: SessionRequest,
    @Res({ passthrough: true }) res: Response
  ) {
    try {

      // Si un fichier est uploadé, utiliser son URL
      if (file) {
        updateBrandDto.url = `/uploads/brands/${file.filename}`;
      }

      const brand = await this.brandsService.update(+id, updateBrandDto);

      return redirectWithFlash(res, '/dashboard/brands', {
        type: 'success',
        message: 'Marque mise à jour.',
      });
    } catch (error) {
      
      // Flash message d'erreur pour Inertia
      if (!req.session) req.session = {};
      if (!req.session.flash) req.session.flash = {};
      req.session.flash.notification = {
        type: 'error',
        message: error.message || 'Erreur lors de la modification de la marque'
      };
      
      throw new BadRequestException(error.message || 'Erreur lors de la modification de la marque');
    }
  }

  @Post('delete/:id')
  @Roles('admin', 'superadmin')
  async remove(@Param('id') id: string, @Req() req: SessionRequest, @Res({ passthrough: true }) res: Response) {
    try {
      
      await this.brandsService.remove(+id);

      return redirectWithFlash(res, '/dashboard/brands', {
        type: 'success',
        message: 'Marque supprimée.',
      });
    } catch (error) {
      
      // Flash message d'erreur pour Inertia
      if (!req.session) req.session = {};
      if (!req.session.flash) req.session.flash = {};
      req.session.flash.notification = {
        type: 'error',
        message: error.message || 'Erreur lors de la suppression de la marque'
      };
      
      throw new BadRequestException(error.message || 'Erreur lors de la suppression de la marque');
    }
  }
}
