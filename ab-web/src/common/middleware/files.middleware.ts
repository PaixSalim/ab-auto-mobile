import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import multer from 'multer';
import { createImageDiskStorage, imageFileFilter, IMAGE_MAX_FILE_SIZE } from '../configs/upload-storage';

@Injectable()
export class FilesMiddleware implements NestMiddleware {
  private upload: multer.Multer;

  constructor() {
    this.upload = multer({
      storage: createImageDiskStorage('products'),
      fileFilter: imageFileFilter,
      limits: { fileSize: IMAGE_MAX_FILE_SIZE },
    });
  }

  use(req: Request, res: Response, next: NextFunction) {
    // Gérer les fichiers envoyés avec images[index]
    const fields: { [key: string]: number } = {};
    
    // Chercher tous les champs images[index] dans la requête
    Object.keys(req.body || {}).forEach(key => {
      if (key.startsWith('images[') && key.endsWith(']')) {
        const match = key.match(/images\[(\d+)\]/);
        if (match) {
          fields['images'] = 10; // Maximum 10 fichiers
        }
      }
    });

    // Si on trouve des champs images[index], utiliser any() pour capturer tous les fichiers
    if (Object.keys(fields).length > 0) {
      this.upload.any()(req, res, next);
    } else {
      next();
    }
  }
}
