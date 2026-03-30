import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Request, UseInterceptors, UploadedFiles } from '@nestjs/common';
import { FilesInterceptor, FileFieldsInterceptor } from '@nestjs/platform-express';
import { ProductsService } from './products.service';
import { CreateProductDto, UpdateProductDto } from './dto/create-product.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { multerOptions } from '../common/configs/multer.config';
import { MediaService } from '../media/media.service';

@Controller('products')
export class ProductsController {
  constructor(
    private readonly productsService: ProductsService,
    private readonly mediaService: MediaService,
  ) {}

  @Get()
  findAll() {
    return this.productsService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.productsService.findOne(+id);
  }

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin', 'seller')
  @UseInterceptors(FileFieldsInterceptor([
    { name: 'images[0]', maxCount: 1 },
    { name: 'images[1]', maxCount: 1 },
    { name: 'images[2]', maxCount: 1 },
    { name: 'images[3]', maxCount: 1 },
    { name: 'images[4]', maxCount: 1 },
    { name: 'images[5]', maxCount: 1 },
    { name: 'images[6]', maxCount: 1 },
    { name: 'images[7]', maxCount: 1 },
    { name: 'images[8]', maxCount: 1 },
    { name: 'images[9]', maxCount: 1 },
  ], multerOptions))
  async create(
    @Body() createProductDto: CreateProductDto,
    @Request() req: any,
    @UploadedFiles() files: { [key: string]: Express.Multer.File[] },
  ) {
    try {
      // Validation des données d'entrée
      if (!createProductDto) {
        throw new Error('Product data is required');
      }
      
      if (!req.user || !req.user.id) {
        throw new Error('User authentication required');
      }

      const product = await this.productsService.create(createProductDto, req.user.id);
      
      // Traiter les fichiers avec la nouvelle structure
      if (files) {
        const allFiles: Express.Multer.File[] = [];
        
        // Collecter tous les fichiers de tous les champs images[index]
        Object.keys(files).forEach(key => {
          if (files[key] && files[key].length > 0) {
            allFiles.push(...files[key]);
          }
        });
        
        if (allFiles.length > 0) {
          for (const file of allFiles) {
            if (!file || !file.filename) {
              continue;
            }
            const filePath = `/uploads/products/${file.filename}`; 
            await this.mediaService.createMedia(product.id, filePath);
          }
        }
      }
      
      return product;
    } catch (error) {
      throw error;
    }
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin', 'seller')
  update(@Param('id') id: string, @Body() updateProductDto: UpdateProductDto) {
    return this.productsService.update(+id, updateProductDto);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  remove(@Param('id') id: string) {
    return this.productsService.remove(+id);
  }
}
