export interface SellerOrderType {
  id: number
  status: string
  createdAt: Date
  quantity: number
  customerName: string
  phoneNumber: string
  city: string
  product: {
    id: number
    name: string
    price: number
    medias?: { url: string }[]
  }
  user?: {
    fullname: string
    email: string
    phone?: string
  }
  address?: string
}
