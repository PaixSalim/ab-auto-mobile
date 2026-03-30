import { IsString, IsNotEmpty, IsNumber, IsOptional, MinLength, MaxLength } from 'class-validator';

export class CreateOrderDto {
  @IsString()
  @IsNotEmpty({ message: 'Le nom du client est requis' })
  @MinLength(3, { message: 'Le nom doit contenir au moins 3 caractères' })
  @MaxLength(50, { message: 'Le nom ne peut pas dépasser 50 caractères' })
  customerName: string;

  @IsString()
  @IsNotEmpty({ message: 'La ville est requise' })
  @MinLength(3, { message: 'La ville doit contenir au moins 3 caractères' })
  @MaxLength(50, { message: 'La ville ne peut pas dépasser 50 caractères' })
  city: string;

  @IsString()
  @IsNotEmpty({ message: 'Le numéro de téléphone est requis' })
  @MinLength(8, { message: 'Le téléphone doit contenir au moins 8 caractères' })
  @MaxLength(15, { message: 'Le téléphone ne peut pas dépasser 15 caractères' })
  phoneNumber: string;

  @IsNumber()
  @IsNotEmpty({ message: 'L\'ID du produit est requis' })
  productId: number;

  @IsNumber()
  @IsNotEmpty({ message: 'La quantité est requise' })
  quantity: number;

  @IsNumber()
  @IsOptional()
  userId?: number;
}

export class GetOrderDto {
  @IsNumber()
  @IsNotEmpty({ message: 'L\'ID de la commande est requis' })
  orderId: number;
}

export class UpdateOrderDto {
  @IsNumber()
  @IsNotEmpty({ message: 'L\'ID de la commande est requis' })
  id: number;

  @IsString()
  @IsOptional()
  @MinLength(3, { message: 'Le nom doit contenir au moins 3 caractères' })
  @MaxLength(50, { message: 'Le nom ne peut pas dépasser 50 caractères' })
  customerName?: string;

  @IsString()
  @IsOptional()
  @MinLength(3, { message: 'La ville doit contenir au moins 3 caractères' })
  @MaxLength(50, { message: 'La ville ne peut pas dépasser 50 caractères' })
  city?: string;

  @IsString()
  @IsOptional()
  @MinLength(8, { message: 'Le téléphone doit contenir au moins 8 caractères' })
  @MaxLength(15, { message: 'Le téléphone ne peut pas dépasser 15 caractères' })
  phoneNumber?: string;

  @IsNumber()
  @IsOptional()
  productId?: number;

  @IsNumber()
  @IsOptional()
  quantity?: number;

  @IsNumber()
  @IsOptional()
  userId?: number;
}

export class DeleteOrderDto {
  @IsNumber()
  @IsNotEmpty({ message: 'L\'ID de la commande est requis' })
  id: number;
}
