import { IsString, IsNotEmpty, IsNumber, IsOptional, MinLength, MaxLength } from 'class-validator';

export class CreateCategoryDto {
  @IsString()
  @IsNotEmpty({ message: 'Le nom de la catégorie est requis' })
  @MinLength(2, { message: 'Le nom doit contenir au moins 2 caractères' })
  @MaxLength(100, { message: 'Le nom ne peut pas dépasser 100 caractères' })
  name: string;

  @IsString()
  @IsOptional()
  @MaxLength(255, { message: 'L\'URL ne peut pas dépasser 255 caractères' })
  url?: string;

  @IsNumber()
  @IsOptional()
  parentId?: number;
}

export class UpdateCategoryDto {
  @IsNumber()
  @IsNotEmpty({ message: 'L\'ID de la catégorie est requis' })
  id: number;

  @IsString()
  @IsOptional()
  @MinLength(2, { message: 'Le nom doit contenir au moins 2 caractères' })
  @MaxLength(100, { message: 'Le nom ne peut pas dépasser 100 caractères' })
  name?: string;

  @IsString()
  @IsOptional()
  @MaxLength(255, { message: 'L\'URL ne peut pas dépasser 255 caractères' })
  url?: string;

  @IsNumber()
  @IsOptional()
  parentId?: number;
}

export class DeleteCategoryDto {
  @IsNumber()
  @IsNotEmpty({ message: 'L\'ID de la catégorie est requis' })
  id: number;
}

export class CreateBrandDto {
  @IsString()
  @IsNotEmpty({ message: 'Le nom de la marque est requis' })
  @MinLength(2, { message: 'Le nom doit contenir au moins 2 caractères' })
  @MaxLength(100, { message: 'Le nom ne peut pas dépasser 100 caractères' })
  name: string;

  @IsString()
  @IsOptional()
  @MaxLength(255, { message: 'L\'URL ne peut pas dépasser 255 caractères' })
  url?: string;

  @IsNumber()
  @IsOptional()
  categoryId?: number;
}

export class UpdateBrandDto {
  @IsNumber()
  @IsNotEmpty({ message: 'L\'ID de la marque est requis' })
  id: number;

  @IsString()
  @IsOptional()
  @MinLength(2, { message: 'Le nom doit contenir au moins 2 caractères' })
  @MaxLength(100, { message: 'Le nom ne peut pas dépasser 100 caractères' })
  name?: string;

  @IsString()
  @IsOptional()
  @MaxLength(255, { message: 'L\'URL ne peut pas dépasser 255 caractères' })
  url?: string;

  @IsNumber()
  @IsOptional()
  categoryId?: number;
}

export class DeleteBrandDto {
  @IsNumber()
  @IsNotEmpty({ message: 'L\'ID de la marque est requis' })
  id: number;
}
