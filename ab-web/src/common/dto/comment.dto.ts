import { IsString, IsNotEmpty, IsNumber, IsBoolean, IsOptional, MaxLength, IsArray, MinLength } from 'class-validator';

export class CreateCommentDto {
  @IsNumber()
  @IsNotEmpty({ message: 'L\'ID du produit est requis' })
  productId: number;

  @IsString()
  @IsNotEmpty({ message: 'Le commentaire est requis' })
  @MaxLength(500, { message: 'Le commentaire ne peut pas dépasser 500 caractères' })
  comment: string;

  @IsString()
  @IsNotEmpty({ message: 'Le nom de l\'utilisateur est requis' })
  @MinLength(2, { message: 'Le nom doit contenir au moins 2 caractères' })
  user: string;

  @IsNumber()
  @IsOptional()
  userId?: number;
}

export class GetCommentsDto {
  @IsNumber()
  @IsNotEmpty({ message: 'L\'ID du produit est requis' })
  productId: number;
}

export class ToggleCommentStatusDto {
  @IsNumber()
  @IsNotEmpty({ message: 'L\'ID du commentaire est requis' })
  commentId: number;

  @IsBoolean()
  @IsNotEmpty({ message: 'Le statut est requis' })
  status: boolean;
}

export class DeleteCommentDto {
  @IsNumber()
  @IsNotEmpty({ message: 'L\'ID du commentaire est requis' })
  commentId: number;
}

export class UpdateCommentDto {
  @IsNumber()
  @IsNotEmpty({ message: 'L\'ID du commentaire est requis' })
  id: number;

  @IsString()
  @IsOptional()
  @MaxLength(500, { message: 'Le commentaire ne peut pas dépasser 500 caractères' })
  comment?: string;

  @IsString()
  @IsOptional()
  @MinLength(2, { message: 'Le nom doit contenir au moins 2 caractères' })
  user?: string;

  @IsBoolean()
  @IsOptional()
  isActive?: boolean;
}

export class ApproveMultipleCommentsDto {
  @IsArray()
  @IsNotEmpty({ message: 'La liste d\'IDs de commentaires est requise' })
  commentIds: number[];
}

export class DisapproveMultipleCommentsDto {
  @IsArray()
  @IsNotEmpty({ message: 'La liste d\'IDs de commentaires est requise' })
  commentIds: number[];
}
