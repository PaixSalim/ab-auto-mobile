import { mkdirSync } from 'fs';
import { join, extname } from 'path';
import { diskStorage } from 'multer';
import { v4 as uuidv4 } from 'uuid';

/** Dossiers sous `<projet>/uploads/` — servis via `app.useStaticAssets(.../uploads)` */
export const UPLOAD_SUBDIRS = [
  'products',
  'categories',
  'brands',
  'banners',
  'promotions',
  'partners',
] as const;

export type UploadSubdir = (typeof UPLOAD_SUBDIRS)[number];

export const UPLOADS_ROOT = join(process.cwd(), 'uploads');

/** Limite alignée avec le front (voir `inertia/utils/imageUpload.ts`) */
export const IMAGE_MAX_FILE_SIZE = 10 * 1024 * 1024;

export function ensureUploadDir(subdir: string): string {
  const dir = join(UPLOADS_ROOT, subdir);
  mkdirSync(dir, { recursive: true });
  return dir;
}

const IMAGE_EXT = /\.(jpe?g|png|gif|webp)$/i;

export function imageFileFilter(
  _req: unknown,
  file: Express.Multer.File,
  cb: (error: Error | null, acceptFile?: boolean) => void,
) {
  const okMime = /\/(jpe?g|png|gif|webp)$/i.test(file.mimetype || '');
  const okExt = IMAGE_EXT.test(file.originalname || '');
  if (okMime || okExt) {
    cb(null, true);
  } else {
    cb(new Error('Type de fichier non supporté (jpg, png, gif, webp)'));
  }
}

export function createImageDiskStorage(subdir: string) {
  return diskStorage({
    destination: (_req, _file, cb) => {
      try {
        cb(null, ensureUploadDir(subdir));
      } catch (e) {
        cb(e as Error, '');
      }
    },
    filename: (_req, file, cb) => {
      const ext = extname(file.originalname || '').toLowerCase();
      cb(null, `${uuidv4()}${ext || '.jpg'}`);
    },
  });
}

/** Options Multer pour un seul dossier d’images (FileInterceptor / FileFieldsInterceptor). */
export function multerImageOptions(subdir: string) {
  return {
    storage: createImageDiskStorage(subdir),
    fileFilter: imageFileFilter,
    limits: { fileSize: IMAGE_MAX_FILE_SIZE },
  };
}
