import { NestFactory } from '@nestjs/core';
import { NestExpressApplication } from '@nestjs/platform-express';
import { join } from 'path';
import { AppModule } from './app.module';
import * as bodyParser from 'body-parser';
import { UPLOAD_SUBDIRS, ensureUploadDir } from './common/configs/upload-storage';

export async function bootstrap() {
  console.log('=== BOOTSTRAP START ===');
  console.log('NODE_ENV:', process.env.NODE_ENV);
  console.log('PORT:', process.env.PORT);
  console.log('DATABASE_URL exists:', !!process.env.DATABASE_URL);
  console.log('JWT_SECRET exists:', !!process.env.JWT_SECRET);
  console.log('CWD:', process.cwd());
  console.log('__dirname:', __dirname);

  try {
    const app = await NestFactory.create<NestExpressApplication>(AppModule);
    console.log('=== APP CREATED ===');

    for (const d of UPLOAD_SUBDIRS) {
      ensureUploadDir(d);
    }

    app.useStaticAssets(join(process.cwd(), 'public'));
    app.useStaticAssets(join(process.cwd(), 'uploads'), { prefix: '/uploads/' });
    app.setBaseViewsDir(join(process.cwd(), 'views'));
    app.setViewEngine('hbs');

    app.use((req: any, res: any, next: any) => {
      res.charset = 'utf-8';
      next();
    });

    app.use(bodyParser.json({ type: 'application/json' }));
    app.use(bodyParser.urlencoded({ extended: true, type: 'application/x-www-form-urlencoded' }));

    const port = process.env.PORT || 3333;
    await app.listen(port);
    console.log(`Application is running on: http://localhost:${port}`);

    return app;

  } catch (error) {
    console.error('=== BOOTSTRAP ERROR ===');
    console.error(error.message);
    console.error(error.stack);
    process.exit(1);
  }
}