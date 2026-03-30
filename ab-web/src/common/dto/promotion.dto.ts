import { IsString, IsNotEmpty, IsNumber, IsOptional, MinLength, MaxLength, IsDateString } from 'class-validator';

export class CreatePromotionDto {
  @IsNumber()
  @IsNotEmpty({ message: 'L\'ID du produit est requis' })
  productId: number;

  @IsNumber()
  @IsNotEmpty({ message: 'Le pourcentage de réduction est requis' })
  discountPercent: number;

  @IsDateString()
  @IsNotEmpty({ message: 'La date de début est requise' })
  promoStartDate: string;

  @IsDateString()
  @IsNotEmpty({ message: 'La date de fin est requise' })
  promoEndDate: string;

  @IsString()
  @IsOptional()
  @MaxLength(255, { message: 'La description ne peut pas dépasser 255 caractères' })
  description?: string;
}

export class UpdatePromotionDto {
  @IsNumber()
  @IsNotEmpty({ message: 'L\'ID de la promotion est requis' })
  id: number;

  @IsNumber()
  @IsOptional()
  productId?: number;

  @IsNumber()
  @IsOptional()
  discountPercent?: number;

  @IsDateString()
  @IsOptional()
  promoStartDate?: string;

  @IsDateString()
  @IsOptional()
  promoEndDate?: string;

  @IsString()
  @IsOptional()
  @MaxLength(255, { message: 'La description ne peut pas dépasser 255 caractères' })
  description?: string;
}

export class DeletePromotionDto {
  @IsNumber()
  @IsNotEmpty({ message: 'L\'ID de la promotion est requis' })
  id: number;
}
