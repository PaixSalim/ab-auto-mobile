import { IsString, IsNotEmpty, IsNumber, IsOptional, MinLength, MaxLength, IsArray, Matches } from 'class-validator';

export class CreateRoleDto {
  @IsString()
  @IsNotEmpty({ message: 'Le nom du rôle est requis' })
  @MinLength(2, { message: 'Le nom doit contenir au moins 2 caractères' })
  @MaxLength(50, { message: 'Le nom ne peut pas dépasser 50 caractères' })
  name: string;

  @IsString()
  @IsNotEmpty({ message: 'Le slug est requis' })
  @MinLength(2, { message: 'Le slug doit contenir au moins 2 caractères' })
  @MaxLength(50, { message: 'Le slug ne peut pas dépasser 50 caractères' })
  @Matches(/^[a-zA-Z0-9_-]+$/, { message: 'Le slug ne peut contenir que des lettres, chiffres, tirets et underscores' })
  slug: string;
}

export class UpdateRoleDto {
  @IsString()
  @IsOptional()
  @MinLength(2, { message: 'Le nom doit contenir au moins 2 caractères' })
  @MaxLength(50, { message: 'Le nom ne peut pas dépasser 50 caractères' })
  name?: string;

  @IsString()
  @IsOptional()
  @MinLength(2, { message: 'Le slug doit contenir au moins 2 caractères' })
  @MaxLength(50, { message: 'Le slug ne peut pas dépasser 50 caractères' })
  @Matches(/^[a-zA-Z0-9_-]+$/, { message: 'Le slug ne peut contenir que des lettres, chiffres, tirets et underscores' })
  slug?: string;
}

export class CreatePermissionDto {
  @IsString()
  @IsNotEmpty({ message: 'Le nom de la permission est requis' })
  @MinLength(2, { message: 'Le nom doit contenir au moins 2 caractères' })
  @MaxLength(100, { message: 'Le nom ne peut pas dépasser 100 caractères' })
  name: string;

  @IsString()
  @IsNotEmpty({ message: 'Le slug est requis' })
  @MinLength(2, { message: 'Le slug doit contenir au moins 2 caractères' })
  @MaxLength(100, { message: 'Le slug ne peut pas dépasser 100 caractères' })
  @Matches(/^[a-zA-Z0-9_-]+$/, { message: 'Le slug ne peut contenir que des lettres, chiffres, tirets et underscores' })
  slug: string;

  @IsString()
  @IsNotEmpty({ message: 'Le groupe est requis' })
  @MinLength(2, { message: 'Le groupe doit contenir au moins 2 caractères' })
  @MaxLength(50, { message: 'Le groupe ne peut pas dépasser 50 caractères' })
  group: string;
}

export class UpdatePermissionDto {
  @IsString()
  @IsOptional()
  @MinLength(2, { message: 'Le nom doit contenir au moins 2 caractères' })
  @MaxLength(100, { message: 'Le nom ne peut pas dépasser 100 caractères' })
  name?: string;

  @IsString()
  @IsOptional()
  @MinLength(2, { message: 'Le slug doit contenir au moins 2 caractères' })
  @MaxLength(100, { message: 'Le slug ne peut pas dépasser 100 caractères' })
  @Matches(/^[a-zA-Z0-9_-]+$/, { message: 'Le slug ne peut contenir que des lettres, chiffres, tirets et underscores' })
  slug?: string;

  @IsString()
  @IsOptional()
  @MinLength(2, { message: 'Le groupe doit contenir au moins 2 caractères' })
  @MaxLength(50, { message: 'Le groupe ne peut pas dépasser 50 caractères' })
  group?: string;
}

export class SyncRolePermissionsDto {
  @IsNumber()
  @IsNotEmpty({ message: 'L\'ID du rôle est requis' })
  roleId: number;

  @IsArray()
  @IsNotEmpty({ message: 'La liste d\'IDs de permissions est requise' })
  permissionIds: number[];
}

export class GetRolePermissionsDto {
  @IsNumber()
  @IsNotEmpty({ message: 'L\'ID du rôle est requis' })
  roleId: number;
}

export class DeleteRoleDto {
  @IsNumber()
  @IsNotEmpty({ message: 'L\'ID du rôle est requis' })
  id: number;
}

export class DeletePermissionDto {
  @IsNumber()
  @IsNotEmpty({ message: 'L\'ID de la permission est requis' })
  id: number;
}
