import { OrderStatus } from '#utils/enum'
import { ProductType } from '#dto/products_interface'

export interface CreateOrderDto {
  customerName: string
  city: string
  phoneNumber: string
  productId: number
  quantity: number
  userId?: number
}

export interface SendingOrderEmailDto {
  phoneNumber: string
  customerName: string
  orderId: number
  city: string
  productName: string
  productPrice: number
  quantity: number
  date: string
}

export interface OrderType {
  id: number
  productId: number
  customerName: string
  city: string
  phoneNumber: string
  quantity: number
  status: OrderStatus
  product: ProductType
  createdAt: Date
}
