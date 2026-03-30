import { IsString, IsNotEmpty, IsOptional, IsNumber, IsEnum, IsArray, IsDecimal } from 'class-validator';
import { ProductState } from '../products_interface';

export class CreateProductDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsString()
  @IsOptional()
  cta?: string;

  @IsNumber()
  @IsNotEmpty()
  categoryId: number;

  @IsNumber()
  @IsOptional()
  brandId?: number;

  @IsEnum(ProductState)
  state: ProductState;

  @IsString()
  @IsNotEmpty()
  description: string;

  @IsNumber()
  price: number;

  @IsOptional()
  features?: any;

  @IsString()
  @IsOptional()
  warranty?: string;
}

export class UpdateProductDto extends CreateProductDto {
  @IsNumber()
  id: number;
}
