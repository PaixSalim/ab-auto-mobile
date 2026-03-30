export class CreateCommentDto {
  productId: number;
  userId?: number;
  user: string;
  comment: string;
  ip?: string;
}

export class UpdateCommentDto {
  comment?: string;
  isActive?: boolean;
}

export class ToggleCommentStatusDto {
  status: boolean;
}
