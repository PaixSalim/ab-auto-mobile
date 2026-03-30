import { multerImageOptions } from './upload-storage';

/** Upload produits : `<projet>/uploads/products`, URL publique `/uploads/products/...` */
export const multerOptions = multerImageOptions('products');
