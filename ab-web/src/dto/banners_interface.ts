export interface BannerInterface {
  id: number
  title: string
  description: string
  image: string
  imageUrl?: string
  link?: string
  isActive: boolean
  order: number
  createdAt: string
  updatedAt: string
}
