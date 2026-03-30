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
  HttpCode
} from '@nestjs/common';
import { AuthService } from '../auth/auth.service';
import { ProductsService } from '../products/products.service';
import { CategoriesService } from '../categories/categories.service';
import { BrandsService } from '../brands/brands.service';
import { CommentsService } from '../comments/comments.service';
import { OrdersService } from '../orders/orders.service';
import { PromotionsService } from '../promotions/promotions.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { CreateCommentDto } from '../dto/comments.dto';

@Controller('api/v1')
export class ApiController {
  constructor(
    private readonly authService: AuthService,
    private readonly productsService: ProductsService,
    private readonly categoriesService: CategoriesService,
    private readonly brandsService: BrandsService,
    private readonly commentsService: CommentsService,
    private readonly ordersService: OrdersService,
    private readonly promotionsService: PromotionsService,
  ) {}

  // Authentication endpoints (mobile)
  @Post('auth/login')
  async login(@Body() loginDto: any) {
    const user = await this.authService.validateUser(loginDto.email, loginDto.password);
    if (user) {
      return this.authService.login(user);
    }
    return { error: 'Invalid credentials' };
  }

  @Post('auth/register')
  async register(@Body() registerDto: any) {
    return this.authService.register(registerDto);
  }

  @Get('auth/me')
  @UseGuards(JwtAuthGuard)
  async getMe(@Request() req: any) {
    return req.user;
  }

  @Post('auth/logout')
  @UseGuards(JwtAuthGuard)
  async logout(@Request() req: any) {
    return { message: 'Logged out successfully' };
  }

  // Products endpoints
  @Get('products')
  async getProducts(@Query() query: any, @Request() req: any) {
    return this.productsService.findAll();
  }

  @Get('products/:id')
  async getProduct(@Param('id') id: string, @Request() req: any) {
    return this.productsService.findOne(+id);
  }

  @Get('products/search')
  async searchProducts(@Query() query: any, @Request() req: any) {
    const { search } = query;
    if (!search) return this.productsService.findAll();
    return this.productsService.findAll();
  }

  @Get('products/featured')
  async getFeaturedProducts(@Query() query: any, @Request() req: any) {
    return this.productsService.findAll();
  }

  @Get('products/by-category/:id')
  async getProductsByCategory(@Param('id') id: string, @Query() query: any, @Request() req: any) {
    return this.productsService.findAll();
  }

  @Get('products/by-brand/:id')
  async getProductsByBrand(@Param('id') id: string, @Query() query: any, @Request() req: any) {
    return this.productsService.findAll();
  }

  // Categories endpoints
  @Get('categories')
  async getCategories(@Query() query: any, @Request() req: any) {
    return this.categoriesService.findAll();
  }

  @Get('categories/:id')
  async getCategory(@Param('id') id: string, @Request() req: any) {
    return this.categoriesService.findOne(+id);
  }

  @Get('categories/tree')
  async getCategoryTree(@Query() query: any, @Request() req: any) {
    return this.categoriesService.findAll();
  }

  // Brands endpoints
  @Get('brands')
  async getBrands(@Query() query: any, @Request() req: any) {
    return this.brandsService.findAll();
  }

  @Get('brands/:id')
  async getBrand(@Param('id') id: string, @Request() req: any) {
    return this.brandsService.findOne(+id);
  }

  @Get('brands/featured')
  async getFeaturedBrands(@Query() query: any, @Request() req: any) {
    return this.brandsService.findAll();
  }

  // Comments endpoints
  @Post('comments')
  async createComment(@Body() createCommentDto: CreateCommentDto) {
    return this.commentsService.create(createCommentDto);
  }

  @Get('comments')
  async getComments(@Query() query: any, @Request() req: any) {
    return this.commentsService.findAll();
  }

  @Get('comments/:id')
  async getComment(@Param('id') id: string, @Request() req: any) {
    return this.commentsService.findByProduct(+id);
  }

  @Get('comments/by-product/:id')
  async getCommentsByProduct(@Param('id') id: string, @Query() query: any, @Request() req: any) {
    return this.commentsService.findAll();
  }

  // Orders endpoints (public)
  @Get('orders')
  async getOrders(@Query() query: any, @Request() req: any) {
    return { data: [], total: 0 };
  }

  @Get('orders/:id')
  async getOrder(@Param('id') id: string, @Request() req: any) {
    return null;
  }

  // Banners endpoints
  @Get('banners')
  async getBanners(@Query() query: any, @Request() req: any) {
    return this.brandsService.findAll();
  }

  @Get('banners/active')
  async getActiveBanners(@Query() query: any, @Request() req: any) {
    return this.brandsService.findAll();
  }

  // Chatbot IA endpoint
  @Post('chatbot')
  async chatWithBot(@Body() chatDto: any, @Request() req: any) {
    return { response: 'Chatbot not implemented yet' };
  }

  // Health check
  @Get('health')
  async healthCheck() {
    return { status: 'ok', timestamp: new Date().toISOString() };
  }

  // Promotions endpoints (public)
  @Get('promotions')
  async getPromotions(@Query() query: any, @Request() req: any) {
    return this.promotionsService.getActivePromotions(query);
  }
}
