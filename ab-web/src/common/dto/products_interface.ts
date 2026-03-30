export enum CTAType {
  NONE = 'none',
  BUY_NOW = 'buy_now',
  ADD_TO_CART = 'add_to_cart',
  CONTACT = 'contact',
  CUSTOMIZE = 'customize'
}

export enum ProductState {
  NEW = 'new',
  USED = 'used',
  RECONDITIONED = 'reconditionned'
}

export interface GetProductDto {
  id: number
  name: string
  description: string
  price: number
  categoryId: number
  brandId?: number
  state: ProductState
  cta: CTAType
  video?: string
  features: string[]
  medias?: MediaDto[]
  category?: CategoryDto
  brand?: BrandDto
  seller?: UserDto
  validationStatus?: string
  createdAt: string
  updatedAt: string
}

export interface MediaDto {
  id: number
  url: string
  type: string
  productId: number
}

export interface CategoryDto {
  id: number
  name: string
  url?: string
  parentId?: number
  subCategories?: CategoryDto[]
}

export interface BrandDto {
  id: number
  name: string
  url?: string
  categoryId?: number
  category?: CategoryDto
  _count?: {
    products: number
  }
}

export interface UserDto {
  id: number
  fullName: string
  email: string
  companyName?: string
  city?: string
  neighborhood?: string
  registrationNumber?: string
  isValidated?: boolean
  roles?: string[]
  createdAt: string
}
