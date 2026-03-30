export interface CategoryDto {
  id: number
  name: string
  url?: string
  parentId?: number
  subCategories?: CategoryDto[]
  products?: {
    id: number
    name: string
    price: number
  }[]
}
