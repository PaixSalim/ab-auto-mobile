export interface BrandsDto {
  id: number
  name: string
  url?: string
  categoryId?: number
  category?: {
    id: number
    name: string
  }
  _count?: {
    products: number
  }
}

export interface CategoryDto {
  id: number
  name: string
  url?: string
  parentId?: number
  subCategories?: CategoryDto[]
}
