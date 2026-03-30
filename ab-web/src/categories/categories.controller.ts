import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Res, Req, HttpStatus, BadRequestException } from '@nestjs/common';
import { Request, Response } from 'express';
import { CategoriesService } from './categories.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { FileInterceptor } from '@nestjs/platform-express';
import { UseInterceptors, UploadedFile } from '@nestjs/common';
import { InertiaService } from '../common/inertia/inertia.service';
import { multerImageOptions } from '../common/configs/upload-storage';
import { redirectWithFlash } from '../common/inertia/flash';

interface SessionRequest extends Request {
  session: any;
}

@Controller('dashboard/categories')
@UseGuards(JwtAuthGuard, RolesGuard)
export class CategoriesController {
  constructor(
    private readonly categoriesService: CategoriesService,
    private readonly inertiaService: InertiaService
  ) {}

  @Get()
  @Roles('admin', 'superadmin')
  async findAll(@Req() req: Request, @Res({ passthrough: true }) res: Response) {
    this.inertiaService.init(req, res);
    
    const categories = await this.categoriesService.findAll();
    
    return this.inertiaService.render('admin/categories/index', { categories });
  }

  @Get(':id')
  @Roles('admin', 'superadmin')
  async findOne(@Param('id') id: string) {
    return this.categoriesService.findOne(+id);
  }

  @Post('create')
  @Roles('admin', 'superadmin')
  @UseInterceptors(FileInterceptor('image', multerImageOptions('categories')))
  async create(
    @Body() createCategoryDto: any,
    @UploadedFile() file: Express.Multer.File,
    @Req() req: SessionRequest,
    @Res({ passthrough: true }) res: Response
  ) {

    try {
      // Si un fichier est uploadé, utiliser son URL
      if (file) {
        createCategoryDto.url = `/uploads/categories/${file.filename}`;
      }

      const category = await this.categoriesService.create(createCategoryDto);

      return redirectWithFlash(res, '/dashboard/categories', {
        type: 'success',
        message: 'Catégorie créée.',
      });
    } catch (error) {
      
      // Flash message d'erreur pour Inertia
      if (!req.session) req.session = {};
      if (!req.session.flash) req.session.flash = {};
      req.session.flash.notification = {
        type: 'error',
        message: error.message || 'Erreur lors de la création de la catégorie'
      };
      
      throw new BadRequestException(error.message || 'Erreur lors de la création de la catégorie');
    }
  }

  @Post('edit/:id')
  @Roles('admin', 'superadmin')
  @UseInterceptors(FileInterceptor('image', multerImageOptions('categories')))
  async update(
    @Param('id') id: string,
    @Body() updateCategoryDto: any,
    @UploadedFile() file: Express.Multer.File,
    @Req() req: SessionRequest,
    @Res({ passthrough: true }) res: Response
  ) {
    try {

      // Si un fichier est uploadé, utiliser son URL
      if (file) {
        updateCategoryDto.url = `/uploads/categories/${file.filename}`;
      }

      const category = await this.categoriesService.update(+id, updateCategoryDto);

      return redirectWithFlash(res, '/dashboard/categories', {
        type: 'success',
        message: 'Catégorie mise à jour.',
      });
    } catch (error) {
      
      // Flash message d'erreur pour Inertia
      if (!req.session) req.session = {};
      if (!req.session.flash) req.session.flash = {};
      req.session.flash.notification = {
        type: 'error',
        message: error.message || 'Erreur lors de la modification de la catégorie'
      };
      
      throw new BadRequestException(error.message || 'Erreur lors de la modification de la catégorie');
    }
  }

  @Post('delete/:id')
  @Roles('admin', 'superadmin')
  async remove(@Param('id') id: string, @Req() req: SessionRequest, @Res({ passthrough: true }) res: Response) {
    try {
      
      await this.categoriesService.remove(+id);

      return redirectWithFlash(res, '/dashboard/categories', {
        type: 'success',
        message: 'Catégorie supprimée.',
      });
    } catch (error) {
      
      // Flash message d'erreur pour Inertia
      if (!req.session) req.session = {};
      if (!req.session.flash) req.session.flash = {};
      req.session.flash.notification = {
        type: 'error',
        message: error.message || 'Erreur lors de la suppression de la catégorie'
      };
      
      throw new BadRequestException(error.message || 'Erreur lors de la suppression de la catégorie');
    }
  }

  @Get('main')
  @Roles('admin', 'superadmin')
  async getMainCategories() {
    return this.categoriesService.getMainCategories();
  }
}
