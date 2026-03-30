import { ProductType } from '#dto/products_interface'

export interface GetPromotedProductsDto {
  id: number
  name: string
  slug: string
  url: string
  category: string
  originalPrice: number
  discountPercent: number
  promoPrice: number
}

export interface CreatePromotionDto {
  productId: number
  promoLabel: string
  discountPercent: number
  promoStartDate: string
  promoEndDate: string
}

export interface EditPromotionDto {
  id: number
  productId: number
  promoLabel: string
  discountPercent: number
  promoStartDate: string
  promoEndDate: string
}
export interface AdminGetPromotionDto {
  id: number
  promoLabel: string
  url: string
  discountPercent: number
  promoStartDate: string
  promoEndDate: string
  product: ProductType
}
