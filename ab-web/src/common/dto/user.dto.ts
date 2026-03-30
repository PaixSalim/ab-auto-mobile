import { IsString, IsNotEmpty, IsEmail, MinLength, MaxLength, IsOptional, IsBoolean } from 'class-validator';

export class RegisterUserDto {
  @IsString()
  @IsNotEmpty()
  @MinLength(2, { message: 'Le nom doit contenir au moins 2 caractères' })
  @MaxLength(25, { message: 'Le nom ne peut pas dépasser 25 caractères' })
  fullName: string;

  @IsEmail({}, { message: 'Email invalide' })
  @IsNotEmpty({ message: 'L\'email est requis' })
  email: string;

  @IsString()
  @IsNotEmpty()
  @MinLength(6, { message: 'Le mot de passe doit contenir au moins 6 caractères' })
  password: string;

  @IsString()
  @IsOptional()
  @MinLength(8, { message: 'Le téléphone doit contenir au moins 8 caractères' })
  @MaxLength(15, { message: 'Le téléphone ne peut pas dépasser 15 caractères' })
  phone?: string;

  @IsString()
  @IsOptional()
  @MinLength(2, { message: 'La ville doit contenir au moins 2 caractères' })
  @MaxLength(50, { message: 'La ville ne peut pas dépasser 50 caractères' })
  city?: string;

  @IsString()
  @IsOptional()
  @MinLength(2, { message: 'Le pays doit contenir au moins 2 caractères' })
  country?: string;

  @IsString()
  @IsOptional()
  @MinLength(3, { message: 'Le nom de l\'entreprise doit contenir au moins 3 caractères' })
  companyName?: string;

  @IsString()
  @IsOptional()
  @MinLength(3, { message: 'Le quartier doit contenir au moins 3 caractères' })
  neighborhood?: string;

  @IsString()
  @IsOptional()
  @MaxLength(20, { message: 'Le numéro d\'enregistrement ne peut pas dépasser 20 caractères' })
  registrationNumber?: string;

  @IsBoolean()
  @IsOptional()
  isValidated?: boolean;
}

export class LoginUserDto {
  @IsEmail({}, { message: 'Email invalide' })
  @IsNotEmpty({ message: 'L\'email est requis' })
  email: string;

  @IsString()
  @IsNotEmpty({ message: 'Le mot de passe est requis' })
  password: string;
}

export class UpdateUserDto {
  @IsString()
  @IsOptional()
  @MinLength(2, { message: 'Le nom doit contenir au moins 2 caractères' })
  @MaxLength(25, { message: 'Le nom ne peut pas dépasser 25 caractères' })
  fullName?: string;

  @IsEmail({}, { message: 'Email invalide' })
  @IsOptional()
  email?: string;

  @IsString()
  @IsOptional()
  @MinLength(8, { message: 'Le téléphone doit contenir au moins 8 caractères' })
  @MaxLength(15, { message: 'Le téléphone ne peut pas dépasser 15 caractères' })
  phone?: string;

  @IsString()
  @IsOptional()
  @MinLength(2, { message: 'La ville doit contenir au moins 2 caractères' })
  @MaxLength(50, { message: 'La ville ne peut pas dépasser 50 caractères' })
  city?: string;

  @IsString()
  @IsOptional()
  @MinLength(2, { message: 'Le pays doit contenir au moins 2 caractères' })
  country?: string;

  @IsString()
  @IsOptional()
  @MinLength(3, { message: 'Le nom de l\'entreprise doit contenir au moins 3 caractères' })
  companyName?: string;

  @IsString()
  @IsOptional()
  @MinLength(3, { message: 'Le quartier doit contenir au moins 3 caractères' })
  neighborhood?: string;

  @IsString()
  @IsOptional()
  @MaxLength(20, { message: 'Le numéro d\'enregistrement ne peut pas dépasser 20 caractères' })
  registrationNumber?: string;

  @IsString()
  @IsOptional()
  @MinLength(6, { message: 'Le mot de passe doit contenir au moins 6 caractères' })
  password?: string;

  @IsBoolean()
  @IsOptional()
  isValidated?: boolean;
}

export class CreateSellerDto {
  @IsString()
  @IsNotEmpty()
  @MinLength(3, { message: 'Le nom complet doit contenir au moins 3 caractères' })
  fullName: string;

  @IsEmail({}, { message: 'Email invalide' })
  @IsNotEmpty({ message: 'L\'email est requis' })
  email: string;

  @IsString()
  @IsNotEmpty()
  @MinLength(8, { message: 'Le mot de passe doit contenir au moins 8 caractères' })
  password: string;

  @IsString()
  @IsOptional()
  @MinLength(8, { message: 'Le téléphone doit contenir au moins 8 caractères' })
  phone?: string;
}

export class UpdateSellerDto {
  @IsString()
  @IsNotEmpty()
  @MinLength(3, { message: 'Le nom complet doit contenir au moins 3 caractères' })
  fullName: string;

  @IsEmail({}, { message: 'Email invalide' })
  @IsNotEmpty({ message: 'L\'email est requis' })
  email: string;

  @IsString()
  @IsOptional()
  @MinLength(8, { message: 'Le téléphone doit contenir au moins 8 caractères' })
  phone?: string;

  @IsString()
  @IsOptional()
  @MinLength(8, { message: 'Le mot de passe doit contenir au moins 8 caractères' })
  password?: string;
}

export class CreateCustomerDto {
  @IsString()
  @IsNotEmpty()
  @MinLength(3, { message: 'Le nom complet doit contenir au moins 3 caractères' })
  fullName: string;

  @IsEmail({}, { message: 'Email invalide' })
  @IsNotEmpty({ message: 'L\'email est requis' })
  email: string;

  @IsString()
  @IsOptional()
  @MinLength(8, { message: 'Le téléphone doit contenir au moins 8 caractères' })
  phone?: string;

  @IsString()
  @IsOptional()
  @MinLength(6, { message: 'Le mot de passe doit contenir au moins 6 caractères' })
  password?: string;
}

export class UpdateCustomerDto {
  @IsString()
  @IsOptional()
  @MinLength(3, { message: 'Le nom complet doit contenir au moins 3 caractères' })
  fullName?: string;

  @IsEmail({}, { message: 'Email invalide' })
  @IsOptional()
  email?: string;

  @IsString()
  @IsOptional()
  @MinLength(8, { message: 'Le téléphone doit contenir au moins 8 caractères' })
  phone?: string;

  @IsString()
  @IsOptional()
  @MinLength(6, { message: 'Le mot de passe doit contenir au moins 6 caractères' })
  password?: string;
}
