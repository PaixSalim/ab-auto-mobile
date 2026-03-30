export interface CommentRequest {
  productId: number
  comment: string
  isActive: boolean
  user: string
  ip: string
}
export interface CommentResponse {
  id: number
  productId: number
  comment: string
  isActive: boolean
  user: string
  ip: string
}

export interface CommentUpdateRequest {
  id: number
  comment: string
  isActive: boolean
  user: string
}
