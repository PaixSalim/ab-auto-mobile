import { BrandsDto } from '#dto/brands_interface'
import { CategoryDto } from '#dto/category_dto'

export enum MediaType {
  IMAGE = 'image',
  VIDEO = 'video',
}
export interface MediaDto {
  id: number
  productId: number
  url: string
  type: MediaType
}

export enum ProductState {
  NEW = 'new',
  OLD = 'old',
}

export enum ValidationStatus {
  PENDING = 'pending',
  APPROVED = 'approved',
  REJECTED = 'rejected',
}

export enum CTAType {
  NONE = '',
  RDV = 'Prendre un rendez-vous',
  BOOK = 'Réserver une place',
  ASK = 'Demander un devis',
}

export interface ProductRequest {
  name: string
  categoryId: number
  brandId: number
  state: ProductState
  description: string
  price: number
  features?: any
  video?: string
}

export interface ProductDto {
  id: number
  name: string
  slug: string
  warranty: string
  state: ProductState
  description: string
  price: number
  category: string
  brand: string
  brandImage?: string
  features: string[]
  medias: MediaDto[]
}

export interface GetProductDto {
  id: number
  name: string
  slug: string
  cta: CTAType
  warranty: string
  state: ProductState
  description: string
  price: number
  promo_price: number
  discount: number
  category: CategoryDto
  features: string[]
  brand: BrandsDto
  medias: MediaDto[]
  seller?: {
    id: number
    fullName: string | null
    email: string
    phone: string | null
    city?: string | null
  }
  validationStatus?: string
  rejectionReason?: string | null
}

export interface ProductType {
  id: number
  name: string
  slug: string
  warranty: string
  state: ProductState
  description: string
  price: number
  discount: number
  features: string[]
  medias: MediaDto[]
  seller?: {
    id: number
    fullName: string | null
    email: string
    phone: string | null
    city?: string | null
  }
}
