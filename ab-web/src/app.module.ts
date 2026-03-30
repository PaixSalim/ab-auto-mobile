import { Module, NestModule, MiddlewareConsumer, ValidationPipe } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './auth/auth.module';
import { PrismaModule } from './prisma/prisma.module';
import { ProductsModule } from './products/products.module';
import { MediaModule } from './media/media.module';
import { CategoriesModule } from './categories/categories.module';
import { BrandsModule } from './brands/brands.module';
import { BannersModule } from './banners/banners.module';
import { OrdersModule } from './orders/orders.module';
import { CommentsModule } from './comments/comments.module';
import { AdminModule } from './admin/admin.module';
import { ProductValidationModule } from './admin/product-validation/product-validation.module';
import { AdminSellersModule } from './admin/sellers/admin-sellers.module';
import { AdminCommentsModule } from './admin/comments/admin-comments.module';
import { AdminPermissionsModule } from './admin/permissions/admin-permissions.module';
import { SellerModule } from './seller/seller.module';
import { CustomerModule } from './customer/customer.module';
import { ApiModule } from './api/api.module';
import { ChatbotModule } from './chatbot/chatbot.module';
import { PromotionsModule } from './promotions/promotions.module';
import { InertiaModule } from './common/inertia/inertia.module';
import { InertiaMiddleware } from './common/inertia/inertia.middleware';
import { CommonModule } from './common/common.module';
import { UsersModule } from './users/users.module';
import { AuthMiddleware } from './auth/auth.middleware';
import { JwtService } from '@nestjs/jwt';
import { MultipartExceptionFilter } from './common/filters/multipart-exception.filter';
import { APP_FILTER } from '@nestjs/core';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PrismaModule,
    AuthModule,
    ProductsModule,
    CategoriesModule,
    BrandsModule,
    BannersModule,
    MediaModule,
    InertiaModule,
    CommonModule,
    OrdersModule,
    CommentsModule,
    UsersModule,
    SellerModule,
    AdminModule,
    ProductValidationModule,
    AdminSellersModule,
    AdminCommentsModule,
    AdminPermissionsModule,
    CustomerModule,
    ApiModule,
    ChatbotModule,
    PromotionsModule,
  ],
  controllers: [AppController],
  providers: [
    AppService, 
    JwtService,
    {
      provide: APP_FILTER,
      useClass: MultipartExceptionFilter,
    },
  ],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer
      .apply(InertiaMiddleware)
      .forRoutes('*');
    
    consumer
      .apply(AuthMiddleware)
      .forRoutes('*');
  }

  async onModuleInit() {
    // Configurer le ValidationPipe globalement
    const validationPipe = new ValidationPipe({
      whitelist: true, // Supprime les propriétés non définies dans le DTO
      forbidNonWhitelisted: true, // Rejette les requêtes avec des propriétés non définies
      transform: true, // Transforme automatiquement les types
      transformOptions: {
        enableImplicitConversion: true, // Conversion implicite des types
      },
    });

    // Vous pouvez aussi l'appliquer globalement via APP_PIPE dans main.ts si nécessaire
  }
}
