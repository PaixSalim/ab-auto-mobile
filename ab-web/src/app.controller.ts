import {
  Controller,
  Get,
  Post,
  Delete,
  Put,
  Param,
  Body,
  Res,
  Req,
  UseGuards,
  UseInterceptors,
  UploadedFiles,
  UploadedFile,
  Query,
  HttpCode,
  HttpStatus,
  HttpException,
} from '@nestjs/common';
import { FileInterceptor, FileFieldsInterceptor } from '@nestjs/platform-express';
import type { Response, Request } from 'express';
import { File } from 'buffer';

// Interface pour étendre Request avec les fichiers parsés par multer
interface MulterRequest extends Request {
  uploadedFiles?: MulterFile[];
}

interface MulterFile {
  fieldname: string;
  originalname: string;
  encoding: string;
  mimetype: string;
  size: number;
  destination: string;
  filename: string;
  path: string;
  buffer: Buffer;
}

// Déclaration de type pour éviter le conflit avec le type File de TypeScript
declare global {
  namespace Express {
    interface Multer {
      File: MulterFile;
    }
  }
}

import { InertiaService } from './common/inertia/inertia.service';
import { ProductsService } from './products/products.service';
import { CategoriesService } from './categories/categories.service';
import { BrandsService } from './brands/brands.service';
import { CommentsService } from './comments/comments.service';
import { OrdersService } from './orders/orders.service';
import { PromotionsService } from './promotions/promotions.service';
import { PrismaService } from './prisma/prisma.service';
import { AppService } from './app.service';
import { AuthService } from './auth/auth.service';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { UserRole } from '@prisma/client';
import { canonicalRoleSlug } from './auth/role-slug.util';
import { multerOptions } from './common/configs/multer.config';
import { multerImageOptions } from './common/configs/upload-storage';
import { redirectWithFlash, type FlashPayload } from './common/inertia/flash';

@Controller()
export class AppController {
  constructor(
    private readonly appService: AppService,
    private readonly authService: AuthService,
    private jwtService: JwtService,
    private readonly inertia: InertiaService,
    private readonly productsService: ProductsService,
    private readonly categoriesService: CategoriesService,
    private readonly brandsService: BrandsService,
    private readonly commentsService: CommentsService,
    private readonly ordersService: OrdersService,
    private readonly promotionsService: PromotionsService,
    private readonly prisma: PrismaService,
  ) {
  }

  // ─── Public pages ─────────────────────────────────────────────────────────

  @Get()
  async index(@Res() res: Response) {
    try {
      const [products, categories, banners, partners] = await Promise.all([
        this.productsService.findAllApproved(), // Récupérer seulement les produits approuvés
        this.categoriesService.findAll(),
        this.prisma.banner.findMany(),
        this.prisma.partner.findMany(),
      ]);

      // Ne pas passer `auth` ici : il est déjà fusionné depuis InertiaMiddleware (JWT cookie).
      // L’ancien code utilisait req.authenticatedUser (souvent vide car AuthMiddleware est désactivé)
      // et écrasait l’auth partagée avec user: null → la navbar affichait toujours Connexion / S’inscrire.

      const testData = {
        products: products.length > 0 ? products : [
          {
            id: 1,
            name: "Produit test 1",
            price: 1000,
            description: "Description du produit test",
            category: { id: 1, name: "Catégorie test" },
            brand: { id: 1, name: "Marque test" },
            medias: []
          }
        ],
        categories: categories.length > 0 ? categories : [
          { id: 1, name: "Catégorie test", subCategories: [] }
        ],
        banners: banners.length > 0 ? banners : [
          {
            id: 1,
            title: "Bannière test",
            description: "Description de la bannière test",
            image: "https://auto-cdn.uvatis.com/logo.png"
          }
        ],
        partners: partners.length > 0 ? partners : [
          { id: 1, name: "Partenaire test", logo: "https://auto-cdn.uvatis.com/logo.png" }
        ],
      };

      return this.inertia.render('home', testData);
    } catch (error) {
      return this.inertia.render('home', {
        products: [],
        categories: [],
        banners: [],
        partners: [],
      });
    }
  }

  @Get('login')
  async loginPage(@Res() res: Response) {
    return this.inertia.render('auth/login');
  }

  @Get('auth/login')
  async authLoginPage(@Res() res: Response) {
    return this.inertia.render('auth/login');
  }

  @Get('register')
  async registerPage(@Res() res: Response) {
    return this.inertia.render('auth/register');
  }

  @Get('auth/register')
  async authRegisterPage(@Res() res: Response) {
    return this.inertia.render('auth/register');
  }

  @Post('/auth/logout')
  async logout(@Res() res: Response) {
    res.clearCookie('access_token', {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'lax',
      path: '/'
    });
    return redirectWithFlash(res, '/', {
      type: 'success',
      title: 'Déconnexion',
      message: 'À bientôt.',
    });
  }

  @Get('/auth/logout')
  async logoutGet(@Res() res: Response) {
    res.clearCookie('access_token', {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'lax',
      path: '/'
    });
    return redirectWithFlash(res, '/', {
      type: 'success',
      title: 'Déconnexion',
      message: 'À bientôt.',
    });
  }

  @Get('privacy')
  async privacy(@Res() res: Response) {
    return this.inertia.render('privacy');
  }

  @Get('catalogue')
  async catalogue(@Res() res: Response, @Query() query: any) {
    const [products, categories, banners, partners] = await Promise.all([
      this.productsService.findAll(),
      this.categoriesService.findAll(),
      this.prisma.banner.findMany(),
      this.prisma.partner.findMany(),
    ]);
    return this.inertia.render('catalogue', { products, categories, banners, partners, query });
  }

  @Get('cart')
  async cart(@Res() res: Response) {
    return this.inertia.render('cart');
  }

  @Get('view/:id')
  async view(@Res() res: Response, @Param('id') id: string) {
    const product = await this.productsService.findOne(+id);
    const similarProducts = await this.prisma.product.findMany({
      where: {
        categoryId: product.categoryId,
        id: { not: product.id },
        validationStatus: 'approved',
      },
      include: { category: true, brand: true, medias: true },
      take: 8,
      orderBy: { createdAt: 'desc' },
    });
    const comments = await this.prisma.comment.findMany({
      where: { productId: product.id, isActive: true },
      include: {
        author: { select: { id: true, fullName: true } },
      },
      orderBy: { createdAt: 'desc' },
    });
    return this.inertia.render('view', {
      product,
      similarProducts,
      comments,
    });
  }

  @Get('catalogue/product/:slug')
  async viewProductBySlug(@Res() res: Response, @Param('slug') slug: string) {
    const product = await this.prisma.product.findUnique({
      where: { slug },
      include: {
        category: true,
        brand: true,
        medias: true,
        seller: {
          select: {
            id: true,
            fullName: true,
            email: true,
            phone: true,
            city: true
          }
        },
        comments: {
          where: {
            isActive: true
          },
          include: {
            author: {
              select: {
                id: true,
                fullName: true
              }
            }
          },
          orderBy: {
            createdAt: 'desc'
          }
        }
      }
    });
    
    if (!product) {
      return res.redirect('/catalogue');
    }

    // Récupérer les produits similaires (même catégorie, exclure le produit actuel)
    const similarProducts = await this.prisma.product.findMany({
      where: {
        categoryId: product.categoryId,
        id: { not: product.id },
        validationStatus: 'approved'
      },
      include: {
        category: true,
        brand: true,
        medias: true,
        seller: {
          select: {
            id: true,
            fullName: true,
            email: true,
            phone: true,
            city: true
          }
        }
      },
      take: 8, // Limiter à 8 produits similaires
      orderBy: {
        createdAt: 'desc'
      }
    });

    // Récupérer les commentaires séparément pour éviter les problèmes de type
    const comments = await this.prisma.comment.findMany({
      where: {
        productId: product.id,
        isActive: true
      },
      include: {
        author: {
          select: {
            id: true,
            fullName: true
          }
        }
      },
      orderBy: {
        createdAt: 'desc'
      }
    });

    return this.inertia.render('view', { 
      product, 
      similarProducts, 
      comments 
    });
  }

  private paginate(data: any[]) {
    return {
      data,
      meta: {
        total: data.length,
        per_page: Math.max(1, data.length),
        current_page: 1,
        last_page: 1,
        first_page: 1,
        from: data.length ? 1 : 0,
        to: data.length,
        links: []
      }
    };
  }

  /** Données page « Mes produits » (vendeur). */
  private async sellerProductsIndexPayload(sellerId: number) {
    const products = await this.prisma.product.findMany({
      where: { sellerId },
      include: { category: true, brand: true, medias: true },
      orderBy: { id: 'desc' },
    });
    const categories = await this.prisma.category.findMany({
      where: { parentId: null },
    });
    const brands = await this.prisma.brand.findMany();
    return { products, categories, brands };
  }

  // ─── Admin pages (Prefix: /dashboard) ───────────────────────────────────

  @Get('/dashboard')
  async adminDashboard(@Res() res: Response, @Req() req: any) {
    try {
      const user = req.user;
      if (!user) {
        return res.redirect('/login');
      }

      // Récupérer les rôles de l'utilisateur
      const userWithRoles = await this.prisma.user.findUnique({
        where: { id: user.id },
        include: { roles: true }
      });

      let roles =
        userWithRoles?.roles.map((r: any) => canonicalRoleSlug(r.slug)) ?? [];
      if (roles.length === 0 && userWithRoles?.role) {
        roles = [userWithRoles.role];
      }
      const isAdmin = roles.includes('admin') || roles.includes('superadmin');
      const isSeller = roles.includes('seller');

      // Initialiser les statistiques
      let productsCount = 0;
      let ordersCount = 0;
      let pendingSellersCount = 0;
      let recentProducts: any[] = [];
      let pendingSellersList: any[] = [];
      let categoriesCount = 0;
      let brandsCount = 0;
      let customersCount = 0;
      let validatedSellersCount = 0;
      let pendingProductsCount = 0;
      let validatedProductsCount = 0;
      let commentsCount = 0;
      let recentOrders: any[] = [];

      if (isAdmin) {
        // Statistiques générales
        productsCount = await this.prisma.product.count();
        ordersCount = await this.prisma.order.count();
        categoriesCount = await this.prisma.category.count();
        brandsCount = await this.prisma.brand.count();

        // Statistiques utilisateurs
        customersCount = await this.prisma.user.count({ where: { role: 'customer' } });
        pendingSellersCount = await this.prisma.user.count({ 
          where: { role: 'seller', isValidated: false } 
        });
        validatedSellersCount = await this.prisma.user.count({ 
          where: { role: 'seller', isValidated: true } 
        });

        // Statistiques produits
        pendingProductsCount = await this.prisma.product.count({ 
          where: { validationStatus: 'pending' } 
        });
        validatedProductsCount = await this.prisma.product.count({ 
          where: { validationStatus: 'approved' } 
        });
        
        // Statistiques commentaires
        commentsCount = await this.prisma.comment.count();

        // Données récentes
        recentProducts = await this.prisma.product.findMany({
          include: { category: true, brand: true },
          orderBy: { createdAt: 'desc' },
          take: 5
        });
        recentOrders = await this.prisma.order.findMany({
          include: { 
            customer: true, 
            product: true 
          },
          orderBy: { createdAt: 'desc' },
          take: 5
        });
        pendingSellersList = await this.prisma.user.findMany({
          where: { role: 'seller', isValidated: false },
          take: 5
        });
      } else if (isSeller) {
        productsCount = await this.prisma.product.count({ 
          where: { sellerId: user.id } 
        });
        ordersCount = await this.prisma.order.count({
          where: {
            product: { sellerId: user.id }
          }
        });
        
        // Statistiques commentaires pour les vendeurs
        commentsCount = await this.prisma.comment.count({
          where: {
            product: { sellerId: user.id }
          }
        });

        recentProducts = await this.prisma.product.findMany({
          where: { sellerId: user.id },
          include: { category: true, brand: true },
          orderBy: { createdAt: 'desc' },
          take: 5
        });
        recentOrders = await this.prisma.order.findMany({
          where: {
            product: { sellerId: user.id }
          },
          include: { 
            customer: true,
            product: true
          },
          orderBy: { createdAt: 'desc' },
          take: 5
        });
      }

      return this.inertia.render('dashboard', {
        stats: {
          products: productsCount,
          orders: ordersCount,
          pendingSellers: pendingSellersCount,
          categories: categoriesCount,
          brands: brandsCount,
          customers: customersCount,
          validatedSellers: validatedSellersCount,
          pendingProducts: pendingProductsCount,
          validatedProducts: validatedProductsCount,
          comments: commentsCount
        },
        recentProducts,
        recentOrders,
        pendingSellersList
      });
    } catch (error) {
      // En cas d'erreur, retourner des données par défaut
      return this.inertia.render('dashboard', {
        stats: {
          products: 0,
          orders: 0,
          pendingSellers: 0,
          categories: 0,
          brands: 0,
          customers: 0,
          validatedSellers: 0,
          pendingProducts: 0,
          validatedProducts: 0,
          comments: 0
        },
        recentProducts: [],
        recentOrders: [],
        pendingSellersList: []
      });
    }
  }

  @Get('/dashboard/products')
  async adminProducts(@Res() res: Response) {
    const products = await this.prisma.product.findMany({
      include: { category: true, brand: true, seller: true, medias: true },
      orderBy: { id: 'desc' },
    });
    const categories = await this.prisma.category.findMany();
    const brands = await this.prisma.brand.findMany();
    return this.inertia.render('admin/products', { products, categories, brands });
  }

  @Get('/dashboard/orders')
  async adminOrders(@Res() res: Response) {
    const orders = await this.prisma.order.findMany({ 
      include: { 
        product: { include: { seller: true } }, 
        customer: true 
      } 
    });
    return this.inertia.render('admin/orders', { orders });
  }

  @Get('/dashboard/customers')
  async adminCustomers(@Res() res: Response) {
    const customers = await this.prisma.user.findMany({ where: { role: 'customer' } });
    return this.inertia.render('admin/customers/index', { customers });
  }

  @Get('/test-simple')
  async testSimple(@Res() res: Response) {
    return res.json({ message: 'Route test fonctionne!', timestamp: new Date() });
  }

  @Get('/seller-dashboard')
  async sellerDashboard(@Res() res: Response) {
    
    const stats = {
      products: 5,
      orders: 12,
      comments: 8
    };
    
    return this.inertia.render('seller/test', {
      stats,
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
    });
  }

  @Get('/dashboard/sellers')
  async adminSellersRedirect(@Res() res: Response) {
    return res.redirect(302, '/sellers-admin');
  }

  // @Get('/dashboard/banners')
  // async adminBannersRedirect(@Res() res: Response) {
  //   return res.redirect(302, '/dashboard/banners');
  // }

  @Get('/dashboard/categories')
  async adminCategories(@Res() res: Response) {
    const categories = await this.prisma.category.findMany({ where: { parentId: null }, include: { subCategories: true }, orderBy: { name: 'asc' } });
    return this.inertia.render('admin/categories/index', { categories });
  }

  @Get('/dashboard/brands')
  async adminBrands(@Res() res: Response) {
    const brands = await this.prisma.brand.findMany({ 
      include: { 
        category: true,
        _count: { select: { products: true } }
      } 
    });
    const categories = await this.prisma.category.findMany({ where: { parentId: null } });
    return this.inertia.render('admin/brands/index', { brands, categories });
  }

  @Get('/dashboard/comments')
  async adminComments(@Res() res: Response) {
    const comments = await this.prisma.comment.findMany({ include: { product: true, author: true } });
    return this.inertia.render('admin/comments', { comments });
  }

  @Get('/dashboard/promotions')
  async adminPromotions(@Res() res: Response) {
    const promotions = await this.prisma.promotion.findMany({ include: { product: true } });
    return this.inertia.render('admin/promotions', { promos: promotions });
  }

  @Get('/dashboard/validation')
  async adminValidation(@Res() res: Response) {
    const products = await this.prisma.product.findMany({
      where: { validationStatus: 'pending' },
      include: { seller: true, category: true, brand: true, medias: true }
    });
    return this.inertia.render('admin/product_validation/index', { products });
  }

  @Get('/dashboard/users')
  async adminUsers(@Res() res: Response) {
    const users = await this.prisma.user.findMany({ include: { roles: true } });
    const roles = await this.prisma.role.findMany();
    return this.inertia.render('admin/users/index', { users, roles });
  }

  @Get('/dashboard/roles')
  async adminRoles(@Res() res: Response) {
    const roles = await this.prisma.role.findMany({ include: { permissions: true } });
    return this.inertia.render('admin/roles/index', { roles });
  }

  @Get('/dashboard/permissions')
  async adminPermissions(@Res() res: Response) {
    const roles = await this.prisma.role.findMany();
    const permissions = await this.prisma.permission.findMany();
    
    const groupedPermissions = permissions.reduce((acc, permission) => {
      const group = permission.group || 'Divers';
      if (!acc[group]) acc[group] = [];
      acc[group].push(permission);
      return acc;
    }, {} as Record<string, any[]>);

    return this.inertia.render('admin/permissions/index', { roles, groupedPermissions });
  }

  @Post('/dashboard/users')
  async createUser(@Res() res: Response, @Body() body: any) {
    const { fullName, email, phone, password, roleId, isValidated } = body;
    const plain = (password && String(password).trim()) || 'password';
    const hashed = await bcrypt.hash(plain, 10);
    const emailNorm = email ? String(email).trim().toLowerCase() : email;

    let roleEnum: UserRole = UserRole.customer;
    if (roleId) {
      const roleRow = await this.prisma.role.findUnique({
        where: { id: parseInt(String(roleId), 10) },
      });
      if (roleRow) {
        const s = roleRow.slug;
        if (s === 'superadmin') roleEnum = UserRole.superadmin;
        else if (s === 'admin') roleEnum = UserRole.admin;
        else if (s === 'seller') roleEnum = UserRole.seller;
        else roleEnum = UserRole.customer;
      }
    }

    await this.prisma.user.create({
      data: {
        fullName,
        email: emailNorm,
        phone,
        password: hashed,
        role: roleEnum,
        isValidated: !!isValidated,
        roles: roleId ? { connect: { id: parseInt(String(roleId), 10) } } : undefined,
      },
    });
    return redirectWithFlash(res, '/dashboard/users', {
      type: 'success',
      message: 'Utilisateur créé.',
    });
  }

  @Post('/dashboard/users/:id')
  async updateUser(@Res() res: Response, @Param('id') id: string, @Body() body: any) {
    const { fullName, email, phone, password, roleId, isValidated } = body;
    const emailNorm = email ? String(email).trim().toLowerCase() : email;

    let roleEnum: UserRole | undefined;
    if (roleId) {
      const roleRow = await this.prisma.role.findUnique({
        where: { id: parseInt(String(roleId), 10) },
      });
      if (roleRow) {
        const s = roleRow.slug;
        if (s === 'superadmin') roleEnum = UserRole.superadmin;
        else if (s === 'admin') roleEnum = UserRole.admin;
        else if (s === 'seller') roleEnum = UserRole.seller;
        else roleEnum = UserRole.customer;
      }
    }

    let hashedPassword: string | undefined;
    if (password && String(password).trim()) {
      hashedPassword = await bcrypt.hash(String(password).trim(), 10);
    }

    await this.prisma.user.update({
      where: { id: parseInt(id, 10) },
      data: {
        fullName,
        email: emailNorm,
        phone,
        ...(hashedPassword ? { password: hashedPassword } : {}),
        ...(roleEnum !== undefined ? { role: roleEnum } : {}),
        isValidated: !!isValidated,
        roles: roleId ? { set: [{ id: parseInt(String(roleId), 10) }] } : { set: [] },
      },
    });
    return redirectWithFlash(res, '/dashboard/users', {
      type: 'success',
      message: 'Utilisateur mis à jour.',
    });
  }

  @Delete('/dashboard/users/:id')
  async deleteUser(@Res() res: Response, @Param('id') id: string) {
    await this.prisma.user.delete({ where: { id: parseInt(id) } });
    return redirectWithFlash(res, '/dashboard/users', {
      type: 'success',
      message: 'Utilisateur supprimé.',
    });
  }

  @Post('/dashboard/roles')
  async createRole(@Res() res: Response, @Body() body: any) {
    await this.prisma.role.create({ data: { name: body.name, slug: body.slug } });
    return redirectWithFlash(res, '/dashboard/roles', {
      type: 'success',
      message: 'Rôle créé.',
    });
  }

  @Post('/dashboard/roles/:id')
  async updateRole(@Res() res: Response, @Param('id') id: string, @Body() body: any) {
    await this.prisma.role.update({
      where: { id: parseInt(id) },
      data: { name: body.name, slug: body.slug }
    });
    return redirectWithFlash(res, '/dashboard/roles', {
      type: 'success',
      message: 'Rôle mis à jour.',
    });
  }

  @Delete('/dashboard/roles/:id')
  async deleteRole(@Res() res: Response, @Param('id') id: string) {
    await this.prisma.role.delete({ where: { id: parseInt(id) } });
    return redirectWithFlash(res, '/dashboard/roles', {
      type: 'success',
      message: 'Rôle supprimé.',
    });
  }

  @Post('/dashboard/customers/create')
  async createCustomer(@Res() res: Response, @Body() body: any) {
    const plain = (body.password && String(body.password).trim()) || 'password';
    const hashed = await bcrypt.hash(plain, 10);
    const emailNorm = body.email
      ? String(body.email).trim().toLowerCase()
      : body.email;
    await this.prisma.user.create({
      data: {
        fullName: body.fullName,
        email: emailNorm,
        phone: body.phone,
        password: hashed,
        role: 'customer',
        isValidated: true,
      },
    });
    return redirectWithFlash(res, '/dashboard/customers', {
      type: 'success',
      message: 'Client créé.',
    });
  }

  @Post('/dashboard/customers/edit')
  async updateCustomer(@Res() res: Response, @Body() body: any) {
    const emailNorm = body.email
      ? String(body.email).trim().toLowerCase()
      : body.email;
    let hashed: string | undefined;
    if (body.password && String(body.password).trim()) {
      hashed = await bcrypt.hash(String(body.password).trim(), 10);
    }
    await this.prisma.user.update({
      where: { id: body.id },
      data: {
        fullName: body.fullName,
        email: emailNorm,
        phone: body.phone,
        ...(hashed ? { password: hashed } : {}),
      },
    });
    return redirectWithFlash(res, '/dashboard/customers', {
      type: 'success',
      message: 'Client mis à jour.',
    });
  }

  @Delete('/dashboard/customers/delete/:id')
  async deleteCustomer(@Res() res: Response, @Param('id') id: string) {
    await this.prisma.user.delete({ where: { id: parseInt(id, 10) } });
    return redirectWithFlash(res, '/dashboard/customers', {
      type: 'success',
      message: 'Client supprimé.',
    });
  }

  @Post('/dashboard/categories/create')
  @UseInterceptors(FileInterceptor('image', multerImageOptions('categories')))
  async createCategory(@Res() res: Response, @Body() body: any, @UploadedFile() file: Express.Multer.File) {
    const { name, parentId, url } = body;
    
    let imageUrl = url || '/uploads/categories/default-category.jpg';
    
    // Traiter l'upload d'image si fourni
    if (file && file.filename) {
      imageUrl = `/uploads/categories/${file.filename}`;
    }
    
    await this.prisma.category.create({
      data: {
        name,
        url: imageUrl,
        parentId: parentId ? parseInt(parentId) : null,
      }
    });
    
    return redirectWithFlash(res, '/dashboard/categories', {
      type: 'success',
      message: 'Catégorie créée.',
    });
  }

  @Post('/dashboard/categories/edit/:id')
  @UseInterceptors(FileInterceptor('image', multerImageOptions('categories')))
  async updateCategory(@Res() res: Response, @Param('id') id: string, @Body() body: any, @UploadedFile() file: Express.Multer.File) {
    const { name, parentId, url } = body;
    
    // Récupérer la catégorie existante
    const existingCategory = await this.prisma.category.findUnique({
      where: { id: parseInt(id) }
    });
    
    if (!existingCategory) {
      return redirectWithFlash(res, '/dashboard/categories', {
        type: 'warning',
        message: 'Catégorie introuvable.',
      });
    }
    
    let imageUrl = existingCategory.url;
    
    // Traiter l'upload d'image si fourni
    if (file && file.filename) {
      imageUrl = `/uploads/categories/${file.filename}`;
    } else if (url && url !== existingCategory.url) {
      // Utiliser la nouvelle URL si fournie et différente
      imageUrl = url || '/uploads/categories/default-category.jpg';
    }
    
    await this.prisma.category.update({
      where: { id: parseInt(id) },
      data: {
        name,
        url: imageUrl,
        parentId: parentId ? parseInt(parentId) : null,
      }
    });
    
    return redirectWithFlash(res, '/dashboard/categories', {
      type: 'success',
      message: 'Catégorie mise à jour.',
    });
  }

  @Delete('/dashboard/categories/delete/:id')
  async deleteCategory(@Res() res: Response, @Param('id') id: string) {
    await this.prisma.category.delete({ where: { id: parseInt(id) } });
    
    return redirectWithFlash(res, '/dashboard/categories', {
      type: 'success',
      message: 'Catégorie supprimée.',
    });
  }

  @Post('/dashboard/brands/create')
  @UseInterceptors(FileInterceptor('image', multerImageOptions('brands')))
  async createBrand(@Res() res: Response, @Body() body: any, @UploadedFile() file: Express.Multer.File) {
    try {
      const { name, categoryId } = body;
      
      // Validation : categoryId est obligatoire selon le schéma
      if (!categoryId) {
        return redirectWithFlash(res, '/dashboard/brands', {
          type: 'error',
          message: 'La catégorie est obligatoire pour créer une marque'
        });
      }
      
      let imageUrl = '/uploads/brands/default-brand.jpg';
      if (file && file.filename) {
        imageUrl = `/uploads/brands/${file.filename}`;
      }
      
      await this.prisma.brand.create({
        data: {
          name,
          url: imageUrl,
          categoryId: parseInt(categoryId)
        }
      });
      
      return redirectWithFlash(res, '/dashboard/brands', {
        type: 'success',
        message: 'Marque créée.',
      });
    } catch (error) {
      return res.status(500).json({
        success: false,
        message: `Erreur: ${error.message || 'Erreur lors de la création de la marque'}`
      });
    }
  }

  @Post('/dashboard/brands/edit/:id')
  @UseInterceptors(FileInterceptor('image', multerImageOptions('brands')))
  async updateBrand(@Res() res: Response, @Param('id') id: string, @Body() body: any, @UploadedFile() file: Express.Multer.File) {
    try {
      const { name, categoryId } = body;
      
      const existingBrand = await this.prisma.brand.findUnique({ where: { id: parseInt(id) } });
      let imageUrl = existingBrand?.url || '/uploads/brands/default-brand.jpg';
      
      if (file && file.filename) {
        imageUrl = `/uploads/brands/${file.filename}`;
      }
      
      await this.prisma.brand.update({
        where: { id: parseInt(id) },
        data: {
          name,
          url: imageUrl,
          categoryId: categoryId ? parseInt(categoryId) : undefined
        }
      });
      
      return redirectWithFlash(res, '/dashboard/brands', {
        type: 'success',
        message: 'Marque mise à jour.',
      });
    } catch (error) {
      return redirectWithFlash(res, '/dashboard/brands', {
        type: 'error',
        message: `Erreur: ${error.message || 'Erreur lors de la modification de la marque'}`
      });
    }
  }

  @Delete('/dashboard/brands/delete/:id')
  async deleteBrand(@Res() res: Response, @Param('id') id: string) {
    await this.prisma.brand.delete({ where: { id: parseInt(id) } });
    return redirectWithFlash(res, '/dashboard/brands', {
      type: 'success',
      message: 'Marque supprimée.',
    });
  }

  // ─── Product CRUD ──────────────────────────────────────────────────────────

  @Post('/dashboard/product/create')
  @UseInterceptors(
    FileFieldsInterceptor(
      [
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
      ],
      multerOptions,
    ),
  )
  async createProduct(@Res() res: Response, @Body() body: any, @Req() req: any, @UploadedFiles() files: { [key: string]: Express.Multer.File[] }) {
    const { name, description, price, categoryId, brandId, state, cta } = body;
    
    const product = await this.prisma.product.create({
      data: {
        name,
        slug: name.toLowerCase().replace(/ /g, '-') + '-' + Date.now(),
        description: description || '',
        price: parseFloat(price) || 0,
        categoryId: parseInt(categoryId),
        brandId: brandId ? parseInt(brandId) : null,
        state: state || 'new',
        cta: cta || 'none',
        sellerId: req.user?.id || null,
        validationStatus: 'approved',
      }
    });

    // Traiter les fichiers s'il y en a
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
          await this.prisma.media.create({
            data: {
              productId: product.id,
              url: `/uploads/products/${file.filename}`,
              type: 'image',
            },
          });
        }
      }
    }

    return redirectWithFlash(res, '/dashboard/products', { type: 'success', title: 'Produit créé', message: 'Le produit a été créé avec succès.' });
  }

  @Post('/dashboard/product/edit')
  @UseInterceptors(
    FileFieldsInterceptor(
      [
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
      ],
      multerOptions,
    ),
  )
  async updateProduct(@Res() res: Response, @Body() body: any, @UploadedFiles() files: { [key: string]: Express.Multer.File[] }) {
    const { id, name, description, price, categoryId, brandId, state, cta, remove } = body;
    await this.prisma.product.update({
      where: { id: parseInt(id) },
      data: {
        name,
        description,
        price: parseFloat(price),
        categoryId: parseInt(categoryId),
        brandId: brandId ? parseInt(brandId) : null,
        state,
        cta,
      }
    });

    // Supprimer les anciens médias marqués
    if (remove) {
      const removeIds: number[] = (typeof remove === 'string' ? JSON.parse(remove) : remove).map(Number).filter(Boolean);
      if (removeIds.length > 0) {
        await this.prisma.media.deleteMany({ where: { id: { in: removeIds } } });
      }
    }

    // Ajouter les nouveaux fichiers
    if (files) {
      const allFiles: Express.Multer.File[] = [];
      Object.keys(files).forEach(key => {
        if (files[key] && files[key].length > 0) allFiles.push(...files[key]);
      });
      for (const file of allFiles) {
        if (!file || !file.filename) continue;
        await this.prisma.media.create({
          data: { productId: parseInt(id), url: `/uploads/products/${file.filename}`, type: 'image' }
        });
      }
    }

    return redirectWithFlash(res, '/dashboard/products', { type: 'success', title: 'Produit modifié', message: 'Le produit a été mis à jour avec succès.' });
  }

  @Delete('/dashboard/product/delete/:id')
  async deleteProduct(@Res() res: Response, @Param('id') id: string) {
    await this.prisma.product.delete({ where: { id: parseInt(id) } });
    return redirectWithFlash(res, '/dashboard/products', { type: 'success', title: 'Produit supprimé', message: 'Le produit a été supprimé avec succès.' });
  }

  /** Réponse Inertia avec liste à jour (évite liste périmée après POST sans rechargement manuel). */
  private async renderAdminProductsList(flash?: FlashPayload) {
    if (flash) {
      this.inertia.share('flash', flash);
    }
    const products = await this.prisma.product.findMany({
      include: { category: true, brand: true, seller: true, medias: true },
      orderBy: { id: 'desc' },
    });
    const categories = await this.prisma.category.findMany();
    const brands = await this.prisma.brand.findMany();
    return this.inertia.render(
      'admin/products',
      { products, categories, brands },
      '/dashboard/products',
    );
  }

  // ─── Validation actions ───────────────────────────────────────────────────

  @Post('dashboard/validation/approve')
  async approveProduct(@Res() res: Response, @Body() body: any) {
    await this.prisma.product.update({
      where: { id: body.productId },
      data: { validationStatus: 'approved' }
    });
    return redirectWithFlash(res, '/dashboard/validation', {
      type: 'success',
      message: 'Produit approuvé.',
    });
  }

  @Post('dashboard/validation/reject')
  async rejectProduct(@Res() res: Response, @Body() body: any) {
    await this.prisma.product.update({
      where: { id: body.productId },
      data: { 
        validationStatus: 'rejected',
        rejectionReason: body.reason
      }
    });
    return redirectWithFlash(res, '/dashboard/validation', {
      type: 'success',
      message: 'Produit rejeté.',
    });
  }

  // ─── Permission-specific API (Used by Axios on permissions page) ───────────

  @Get('dashboard/permissions/role/:roleId')
  async getRolePermissions(@Param('roleId') roleId: string) {
    const role = await this.prisma.role.findUnique({
      where: { id: parseInt(roleId) },
      include: { permissions: true }
    });
    return role?.permissions.map(p => p.id) || [];
  }

  @Post('dashboard/permissions/sync')
  async syncRolePermissions(@Body() body: any) {
    const { roleId, permissionIds } = body;
    // NestJS does many-to-many through Prisma by updating the relations
    await this.prisma.role.update({
      where: { id: parseInt(roleId) },
      data: {
        permissions: {
          set: (permissionIds as number[]).map(id => ({ id }))
        }
      }
    });
    return { success: true };
  }

  // ─── Seller pages (Prefix: /seller) ───────────────────────────────────────

  @Get('seller/products')
  async sellerProducts(@Res() res: Response, @Req() req: any) {
    const sellerId = req.user?.id;
    const products = await this.prisma.product.findMany({
      where: { sellerId },
      include: { category: true, brand: true, medias: true },
      orderBy: { id: 'desc' },
    });
    const brands = await this.prisma.brand.findMany();
    const categories = await this.prisma.category.findMany({ where: { parentId: null } });
    return this.inertia.render('seller/products/index', {
      products,
      categories,
      brands,
      sellerPendingValidation:
        req.user?.role === 'seller' && req.user?.isValidated === false,
    });
  }

  @Post('seller/products/create')
  @UseInterceptors(
    FileFieldsInterceptor(
      [
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
      ],
      multerOptions,
    ),
  )
  async sellerCreateProduct(@Res() res: Response, @Req() req: any, @UploadedFiles() files: { [key: string]: Express.Multer.File[] }) {
    try {
      const sellerId = req.user?.id;
      if (!sellerId) {
        return res.redirect(302, '/auth/login');
      }
      if (req.user?.role === 'seller' && req.user?.isValidated === false) {
        return this.inertia.render(
          'seller/products/index',
          {
            ...(await this.sellerProductsIndexPayload(sellerId)),
            error:
              'Votre compte vendeur doit être validé par un administrateur avant d’ajouter des produits.',
            sellerPendingValidation: true,
          },
          '/seller/products',
        );
      }

      // Récupérer les fichiers parsés par multer
      const formData = req.body;
      
      const product = await this.prisma.product.create({
        data: {
          name: formData.name,
          description: formData.description,
          price: parseFloat(formData.price) || 0,
          categoryId: parseInt(formData.categoryId),
          brandId: formData.brandId ? parseInt(formData.brandId) : null,
          state: formData.state || 'new',
          cta: formData.cta || 'none',
          sellerId: sellerId,
          slug: formData.name.toLowerCase().replace(/ /g, '-') + '-' + Date.now(),
          validationStatus: 'pending',
        }
      });

      // Traiter les fichiers s'il y en a
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
            await this.prisma.media.create({
              data: {
                productId: product.id,
                url: `/uploads/products/${file.filename}`,
                type: 'image',
              },
            });
          }
        }
      }

      return this.inertia.render(
        'seller/products/index',
        {
          ...(await this.sellerProductsIndexPayload(sellerId)),
          success: 'Produit créé avec succès',
          sellerPendingValidation:
            req.user?.role === 'seller' && req.user?.isValidated === false,
        },
        '/seller/products',
      );
    } catch (error) {
      const sid = req.user?.id;
      const payload = sid
        ? await this.sellerProductsIndexPayload(sid)
        : { products: [], categories: [], brands: [] };
      return this.inertia.render(
        'seller/products/index',
        {
          ...payload,
          error:
            'Impossible de créer le produit. Vérifiez les champs et réessayez.',
          sellerPendingValidation:
            req.user?.role === 'seller' && req.user?.isValidated === false,
        },
        '/seller/products',
      );
    }
  }

  @Post('seller/products/edit')
  async sellerEditProduct(@Res() res: Response, @Req() req: any, @Body() body: any) {
    try {
      const sellerId = req.user?.id;
      if (!sellerId) {
        return res.redirect(302, '/auth/login');
      }
      if (req.user?.role === 'seller' && req.user?.isValidated === false) {
        return this.inertia.render(
          'seller/products/index',
          {
            ...(await this.sellerProductsIndexPayload(sellerId)),
            error:
              'Votre compte vendeur doit être validé avant de modifier des produits.',
            sellerPendingValidation: true,
          },
          '/seller/products',
        );
      }

      await this.prisma.product.update({
        where: { id: parseInt(body.id) },
        data: {
          name: body.name,
          description: body.description,
          price: parseFloat(body.price),
          categoryId: parseInt(body.categoryId),
          brandId: body.brandId ? parseInt(body.brandId) : null,
          state: body.state,
          cta: body.cta,
        }
      });

      return this.inertia.render(
        'seller/products/index',
        {
          ...(await this.sellerProductsIndexPayload(sellerId)),
          success: 'Produit modifié avec succès',
          sellerPendingValidation:
            req.user?.role === 'seller' && req.user?.isValidated === false,
        },
        '/seller/products',
      );
    } catch (error) {
      const sid = req.user?.id;
      const payload = sid
        ? await this.sellerProductsIndexPayload(sid)
        : { products: [], categories: [], brands: [] };
      return this.inertia.render(
        'seller/products/index',
        {
          ...payload,
          error: 'Impossible de modifier le produit. Réessayez.',
          sellerPendingValidation:
            req.user?.role === 'seller' && req.user?.isValidated === false,
        },
        '/seller/products',
      );
    }
  }

  @Delete('seller/products/delete/:id')
  async sellerDeleteProduct(@Res() res: Response, @Req() req: any, @Param('id') id: string) {
    try {
      const sellerId = req.user?.id;
      if (!sellerId) {
        return res.redirect(302, '/auth/login');
      }
      if (req.user?.role === 'seller' && req.user?.isValidated === false) {
        return this.inertia.render(
          'seller/products/index',
          {
            ...(await this.sellerProductsIndexPayload(sellerId)),
            error:
              'Votre compte vendeur doit être validé avant de supprimer des produits.',
            sellerPendingValidation: true,
          },
          '/seller/products',
        );
      }

      await this.prisma.product.delete({
        where: { id: parseInt(id) }
      });

      return this.inertia.render(
        'seller/products/index',
        {
          ...(await this.sellerProductsIndexPayload(sellerId)),
          success: 'Produit supprimé avec succès',
          sellerPendingValidation:
            req.user?.role === 'seller' && req.user?.isValidated === false,
        },
        '/seller/products',
      );
    } catch (error) {
      const sid = req.user?.id;
      const payload = sid
        ? await this.sellerProductsIndexPayload(sid)
        : { products: [], categories: [], brands: [] };
      return this.inertia.render(
        'seller/products/index',
        {
          ...payload,
          error: 'Impossible de supprimer le produit.',
          sellerPendingValidation:
            req.user?.role === 'seller' && req.user?.isValidated === false,
        },
        '/seller/products',
      );
    }
  }

  @Get('seller/orders')
  async sellerOrders(@Res() res: Response, @Req() req: any) {
    const sellerId = req.user?.id;
    const orders = await this.prisma.order.findMany({ 
      where: { product: { sellerId } },
      include: { product: true, customer: true } 
    });
    return this.inertia.render('seller/orders/index', { orders });
  }

  @Get('seller/categories')
  async sellerCategories(@Res() res: Response) {
    const categories = await this.prisma.category.findMany({ where: { parentId: null }, include: { subCategories: true } });
    return this.inertia.render('seller/categories/index', { categories });
  }

  @Get('seller/brands')
  async sellerBrands(@Res() res: Response) {
    const brands = await this.prisma.brand.findMany({ include: { category: true } });
    const categories = await this.prisma.category.findMany({ where: { parentId: null } });
    return this.inertia.render('seller/brands/index', { brands, categories });
  }

  // ─── Customer pages (Protected client routes) ─────────────────────────────

  /** Cookie HttpOnly : pas de `req.cookies` sans cookie-parser — même parsing que InertiaMiddleware */
  private getAccessTokenFromRequest(req: any): string | null {
    const cookieHeader = req.headers?.cookie;
    if (!cookieHeader) return null;
    const cookies = Object.fromEntries(
      cookieHeader.split('; ').map((c: string) => {
        const parts = c.split('=');
        return [parts[0], decodeURIComponent(parts.slice(1).join('='))];
      }),
    );
    return cookies['access_token'] ?? null;
  }

  private mapOrderStatusForCustomer(raw: string): string {
    const m: Record<string, string> = {
      pending: 'En cours',
      processing: 'En cours',
      confirmed: 'Confirmée',
      shipped: 'En cours',
      delivered: 'Livrée',
      cancelled: 'Annulée',
    };
    return m[raw] ?? raw;
  }

  @Get('orders')
  async customerOrdersDirect(@Req() req: any, @Res() res: Response) {
    const token = this.getAccessTokenFromRequest(req);
    let orders: any[] = [];
    if (token) {
      const auth = await this.authService.getUserWithPermissions(token);
      const userId = auth?.user?.id;
      if (userId) {
        const rows = await this.prisma.order.findMany({
          where: { userId },
          include: {
            product: {
              include: {
                seller: {
                  select: {
                    id: true,
                    fullName: true,
                    email: true,
                    phone: true,
                  },
                },
                medias: { take: 1 },
              },
            },
          },
          orderBy: { createdAt: 'desc' },
        });
        orders = rows.map((o) => ({
          id: o.id,
          customerName: o.customerName,
          city: o.city,
          phoneNumber: o.phoneNumber,
          status: this.mapOrderStatusForCustomer(o.status),
          quantity: o.quantity,
          createdAt: o.createdAt.toISOString(),
          product: {
            id: o.product.id,
            name: o.product.name,
            price: Number(o.product.price),
            slug: o.product.slug,
            image: o.product.medias?.[0]?.url,
            seller: o.product.seller
              ? {
                  id: o.product.seller.id,
                  fullName: o.product.seller.fullName,
                  email: o.product.seller.email,
                  phone: o.product.seller.phone,
                }
              : undefined,
          },
        }));
      }
    }
    return this.inertia.render('customer/orders', { orders });
  }

  @Get('comments')
  async customerCommentsDirect(@Req() req: any, @Res() res: Response) {
    const token = this.getAccessTokenFromRequest(req);
    let comments: any[] = [];
    if (token) {
      const auth = await this.authService.getUserWithPermissions(token);
      const userId = auth?.user?.id;
      if (userId) {
        const rows = await this.prisma.comment.findMany({
          where: { userId },
          include: {
            product: {
              include: { medias: { take: 1 } },
            },
          },
          orderBy: { createdAt: 'desc' },
        });
        comments = rows.map((c) => ({
          id: c.id,
          comment: c.comment,
          isActive: c.isActive,
          createdAt: c.createdAt.toISOString(),
          product: {
            id: c.product.id,
            name: c.product.name,
            slug: c.product.slug,
            image: c.product.medias?.[0]?.url,
          },
        }));
      }
    }
    return this.inertia.render('customer/comments', { comments });
  }

  // ─── API v1 routes used by the Pinia store ────────────────────────────────

  @Get('api/v1/products')
  async products() {
    return this.productsService.findAll();
  }

  @Get('api/v1/products-web')
  async productsWeb() {
    return this.productsService.findAll();
  }

  @Get('api/v1/product/:id')
  async productOne(@Param('id') id: string) {
    return this.productsService.findOne(+id);
  }

  @Get('api/v1/categories')
  async categoriesApi() {
    return this.categoriesService.findAll();
  }

  @Get('api/v1/promotions')
  async promotionsApi() {
    try {
      const promotions = await this.prisma.promotion.findMany({
        include: { 
          product: {
            include: {
              category: true,
              brand: true,
              medias: true
            }
          } 
        }
      });
      
      return promotions;
    } catch (error) {
      throw error;
    }
  }

  // ─── Promotions CRUD ─────────────────────────────────────────────────────

  @Post('/dashboard/promotions/create')
  @UseInterceptors(FileInterceptor('image', multerImageOptions('promotions')))
  async createPromotion(@Res() res: Response, @Body() body: any, @UploadedFile() file: Express.Multer.File) {
    const productId = body.productId;
    if (!productId) {
      return redirectWithFlash(res, '/dashboard/promotions', { type: 'error', message: 'Le produit est obligatoire' });
    }
    const { promoLabel, discountPercent, promoStartDate, promoEndDate } = body;
    let imageUrl = '/uploads/promotions/default-promotion.jpg';
    if (file && file.filename) {
      imageUrl = `/uploads/promotions/${file.filename}`;
    }
    try {
      await this.prisma.promotion.create({
        data: {
          productId: parseInt(productId),
          promoLabel: promoLabel || 'Promotion',
          discountPercent: parseFloat(discountPercent) || 0,
          url: imageUrl,
          promoStartDate: promoStartDate ? new Date(promoStartDate) : new Date(),
          promoEndDate: promoEndDate ? new Date(promoEndDate) : new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
        }
      });
      return redirectWithFlash(res, '/dashboard/promotions', { type: 'success', title: 'Promotion créée', message: 'La promotion a été créée avec succès' });
    } catch (error) {
      return redirectWithFlash(res, '/dashboard/promotions', { type: 'error', message: error.message || 'Erreur lors de la création' });
    }
  }

  @Post('/dashboard/promotions/edit/:id')
  @UseInterceptors(FileInterceptor('image', multerImageOptions('promotions')))
  async updatePromotion(@Res() res: Response, @Param('id') id: string, @Body() body: any, @UploadedFile() file: Express.Multer.File) {
    const existingPromotion = await this.prisma.promotion.findUnique({ where: { id: parseInt(id) } });
    if (!existingPromotion) {
      return redirectWithFlash(res, '/dashboard/promotions', { type: 'error', message: 'Promotion non trouvée' });
    }
    const { productId, promoLabel, discountPercent, promoStartDate, promoEndDate } = body;
    let imageUrl = existingPromotion.url;
    if (file && file.filename) {
      imageUrl = `/uploads/promotions/${file.filename}`;
    }
    try {
      await this.prisma.promotion.update({
        where: { id: parseInt(id) },
        data: {
          productId: productId ? parseInt(productId) : existingPromotion.productId,
          promoLabel,
          discountPercent: parseFloat(discountPercent) || existingPromotion.discountPercent,
          url: imageUrl,
          promoStartDate: promoStartDate ? new Date(promoStartDate) : existingPromotion.promoStartDate,
          promoEndDate: promoEndDate ? new Date(promoEndDate) : existingPromotion.promoEndDate,
        }
      });
      return redirectWithFlash(res, '/dashboard/promotions', { type: 'success', title: 'Promotion modifiée', message: 'La promotion a été modifiée avec succès' });
    } catch (error) {
      return redirectWithFlash(res, '/dashboard/promotions', { type: 'error', message: error.message || 'Erreur lors de la modification' });
    }
  }

  @Delete('/dashboard/promotions/delete/:id')
  async deletePromotion(@Res() res: Response, @Param('id') id: string) {
    try {
      await this.prisma.promotion.delete({ where: { id: parseInt(id) } });
      return redirectWithFlash(res, '/dashboard/promotions', { type: 'success', title: 'Promotion supprimée', message: 'La promotion a été supprimée avec succès' });
    } catch (error) {
      return redirectWithFlash(res, '/dashboard/promotions', { type: 'error', message: error.message || 'Erreur lors de la suppression' });
    }
  }

  @Get('api/v1/banners')
  async bannersApi() {
    return this.prisma.banner.findMany();
  }

  @Get('api/v1/brands')
  async brandsApi() {
    return this.prisma.brand.findMany();
  }

  @Get('api/v1/brand/spec')
  async brandsSpecApi(@Query('categoryId') categoryId: string) {
    if (!categoryId) return [];
    return this.prisma.brand.findMany({
      where: { categoryId: +categoryId },
    });
  }

  @Get('api/v1/brands/partners')
  async partnersApi() {
    return this.prisma.partner.findMany();
  }

  @Get('api/v1/comments')
  async commentsApi(@Query('product_id') productId: string) {
    if (!productId) return [];
    return this.prisma.comment.findMany({
      where: { productId: +productId, isActive: true },
      include: { author: true, replies: true },
    });
  }

  /** Espace vendeur : même entrée que après inscription (évite une page de test vide / incohérente). */
  @Get('/seller')
  async sellerRootRedirect(@Res() res: Response) {
    return res.redirect(302, '/seller/products');
  }
}