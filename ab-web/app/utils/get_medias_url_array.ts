import { MediaDto } from '#dto/products_interface'

export function getMediaUrlsFor(productId: number, medias: MediaDto[]) {
  return medias.filter((m) => m.productId === productId).map((m) => m.url)
}
