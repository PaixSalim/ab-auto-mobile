import { 
  Controller, 
  Get, 
  Post, 
  Put, 
  Delete, 
  Body, 
  Param, 
  Res,
  Req,
  BadRequestException,
  NotFoundException
} from '@nestjs/common';
import { Response } from 'express';
import { AdminPermissionsService } from './admin-permissions.service';
import { InertiaService } from '../../common/inertia/inertia.service';
import { redirectWithFlash } from '../../common/inertia/flash';

@Controller('admin/permissions')
export class AdminPermissionsController {
  constructor(
    private readonly adminPermissionsService: AdminPermissionsService,
    private readonly inertia: InertiaService,
  ) {}

  /**
   * Page principale de gestion des permissions et rôles
   */
  @Get()
  async index(@Res() res: Response, @Req() req: any) {
    try {
      const [roles, groupedPermissions, stats] = await Promise.all([
        this.adminPermissionsService.getAllRoles(),
        this.adminPermissionsService.getGroupedPermissions(),
        this.adminPermissionsService.getPermissionsStats()
      ]);

      return this.inertia.render('admin/permissions/index', {
        roles,
        groupedPermissions,
        stats,
      });
    } catch (error) {
      return this.inertia.render('admin/permissions/index', {
        roles: [],
        groupedPermissions: {},
        stats: {
          totalRoles: 0,
          totalPermissions: 0,
          rolesWithUsers: 0,
          permissionsWithRoles: 0
        },
        error: 'Erreur: ' + error.message,
      });
    }
  }

  /**
   * Récupérer les permissions d'un rôle
   */
  @Get('role/:roleId')
  async getRolePermissions(@Param('roleId') roleId: string) {
    try {
      const permissions = await this.adminPermissionsService.getRolePermissions(parseInt(roleId));
      return {
        success: true,
        permissions,
      };
    } catch (error) {
      return {
        success: false,
        message: 'Erreur lors de la récupération des permissions du rôle: ' + error.message,
      };
    }
  }

  /**
   * Synchroniser les permissions d'un rôle
   */
  @Post('sync')
  async syncRolePermissions(
    @Body() body: { roleId: number; permissionIds: number[] },
    @Res({ passthrough: true }) res: Response
  ) {
    if (!body.roleId) {
      throw new BadRequestException('ID du rôle requis');
    }

    if (!Array.isArray(body.permissionIds)) {
      throw new BadRequestException('Liste d\'IDs de permissions requise');
    }

    try {
      await this.adminPermissionsService.syncRolePermissions(body.roleId, body.permissionIds);
      return redirectWithFlash(res, '/admin/permissions', {
        type: 'success',
        message: 'Permissions du rôle mises à jour.',
      });
    } catch (error) {
      return redirectWithFlash(res, '/admin/permissions', {
        type: 'error',
        message: 'Impossible de synchroniser les permissions.',
      });
    }
  }

  /**
   * Créer un nouveau rôle
   */
  @Post('roles/create')
  async createRole(
    @Body() createRoleDto: { name: string; slug: string },
    @Res({ passthrough: true }) res: Response
  ) {
    // Validation basique
    if (!createRoleDto.name || createRoleDto.name.length < 2) {
      throw new BadRequestException('Le nom du rôle doit contenir au moins 2 caractères');
    }

    if (!createRoleDto.slug || createRoleDto.slug.length < 2) {
      throw new BadRequestException('Le slug doit contenir au moins 2 caractères');
    }

    // Valider le format du slug (lettres, chiffres, tirets, underscores)
    if (!/^[a-zA-Z0-9_-]+$/.test(createRoleDto.slug)) {
      throw new BadRequestException('Le slug ne peut contenir que des lettres, chiffres, tirets et underscores');
    }

    try {
      await this.adminPermissionsService.createRole(createRoleDto);
      return redirectWithFlash(res, '/admin/permissions', {
        type: 'success',
        message: 'Rôle créé.',
      });
    } catch (error) {
      return redirectWithFlash(res, '/admin/permissions', {
        type: 'error',
        message: 'Impossible de créer le rôle.',
      });
    }
  }

  /**
   * Mettre à jour un rôle
   */
  @Put('roles/:id')
  async updateRole(
    @Param('id') id: string,
    @Body() updateRoleDto: { name: string; slug: string },
    @Res({ passthrough: true }) res: Response
  ) {
    // Validation basique
    if (!updateRoleDto.name || updateRoleDto.name.length < 2) {
      throw new BadRequestException('Le nom du rôle doit contenir au moins 2 caractères');
    }

    if (!updateRoleDto.slug || updateRoleDto.slug.length < 2) {
      throw new BadRequestException('Le slug doit contenir au moins 2 caractères');
    }

    // Valider le format du slug
    if (!/^[a-zA-Z0-9_-]+$/.test(updateRoleDto.slug)) {
      throw new BadRequestException('Le slug ne peut contenir que des lettres, chiffres, tirets et underscores');
    }

    try {
      await this.adminPermissionsService.updateRole(parseInt(id), updateRoleDto);
      return redirectWithFlash(res, '/admin/permissions', {
        type: 'success',
        message: 'Rôle mis à jour.',
      });
    } catch (error) {
      return redirectWithFlash(res, '/admin/permissions', {
        type: 'error',
        message: 'Impossible de mettre à jour le rôle.',
      });
    }
  }

  /**
   * Supprimer un rôle
   */
  @Delete('roles/:id')
  async deleteRole(@Param('id') id: string, @Res({ passthrough: true }) res: Response) {
    try {
      await this.adminPermissionsService.deleteRole(parseInt(id));
      return redirectWithFlash(res, '/admin/permissions', {
        type: 'success',
        message: 'Rôle supprimé.',
      });
    } catch (error) {
      return redirectWithFlash(res, '/admin/permissions', {
        type: 'error',
        message: 'Impossible de supprimer le rôle.',
      });
    }
  }

  /**
   * Créer une nouvelle permission
   */
  @Post('permissions/create')
  async createPermission(
    @Body() createPermissionDto: { name: string; slug: string; group: string },
    @Res({ passthrough: true }) res: Response
  ) {
    // Validation basique
    if (!createPermissionDto.name || createPermissionDto.name.length < 2) {
      throw new BadRequestException('Le nom de la permission doit contenir au moins 2 caractères');
    }

    if (!createPermissionDto.slug || createPermissionDto.slug.length < 2) {
      throw new BadRequestException('Le slug doit contenir au moins 2 caractères');
    }

    if (!createPermissionDto.group || createPermissionDto.group.length < 2) {
      throw new BadRequestException('Le groupe doit contenir au moins 2 caractères');
    }

    // Valider le format du slug
    if (!/^[a-zA-Z0-9_-]+$/.test(createPermissionDto.slug)) {
      throw new BadRequestException('Le slug ne peut contenir que des lettres, chiffres, tirets et underscores');
    }

    try {
      await this.adminPermissionsService.createPermission(createPermissionDto);
      return redirectWithFlash(res, '/admin/permissions', {
        type: 'success',
        message: 'Permission créée.',
      });
    } catch (error) {
      return redirectWithFlash(res, '/admin/permissions', {
        type: 'error',
        message: 'Impossible de créer la permission.',
      });
    }
  }

  /**
   * Mettre à jour une permission
   */
  @Put('permissions/:id')
  async updatePermission(
    @Param('id') id: string,
    @Body() updatePermissionDto: { name: string; slug: string; group: string },
    @Res({ passthrough: true }) res: Response
  ) {
    // Validation basique
    if (!updatePermissionDto.name || updatePermissionDto.name.length < 2) {
      throw new BadRequestException('Le nom de la permission doit contenir au moins 2 caractères');
    }

    if (!updatePermissionDto.slug || updatePermissionDto.slug.length < 2) {
      throw new BadRequestException('Le slug doit contenir au moins 2 caractères');
    }

    if (!updatePermissionDto.group || updatePermissionDto.group.length < 2) {
      throw new BadRequestException('Le groupe doit contenir au moins 2 caractères');
    }

    // Valider le format du slug
    if (!/^[a-zA-Z0-9_-]+$/.test(updatePermissionDto.slug)) {
      throw new BadRequestException('Le slug ne peut contenir que des lettres, chiffres, tirets et underscores');
    }

    try {
      await this.adminPermissionsService.updatePermission(parseInt(id), updatePermissionDto);
      return redirectWithFlash(res, '/admin/permissions', {
        type: 'success',
        message: 'Permission mise à jour.',
      });
    } catch (error) {
      return redirectWithFlash(res, '/admin/permissions', {
        type: 'error',
        message: 'Impossible de mettre à jour la permission.',
      });
    }
  }

  /**
   * Supprimer une permission
   */
  @Delete('permissions/:id')
  async deletePermission(@Param('id') id: string, @Res({ passthrough: true }) res: Response) {
    try {
      await this.adminPermissionsService.deletePermission(parseInt(id));
      return redirectWithFlash(res, '/admin/permissions', {
        type: 'success',
        message: 'Permission supprimée.',
      });
    } catch (error) {
      return redirectWithFlash(res, '/admin/permissions', {
        type: 'error',
        message: 'Impossible de supprimer la permission.',
      });
    }
  }

  /**
   * API endpoint pour obtenir les statistiques
   */
  @Get('stats')
  async getStats() {
    try {
      const stats = await this.adminPermissionsService.getPermissionsStats();
      return {
        success: true,
        stats,
      };
    } catch (error) {
      return {
        success: false,
        message: 'Erreur lors de la récupération des statistiques: ' + error.message,
      };
    }
  }

  /**
   * API endpoint pour obtenir tous les rôles
   */
  @Get('roles')
  async getRoles() {
    try {
      const roles = await this.adminPermissionsService.getAllRoles();
      return {
        success: true,
        roles,
      };
    } catch (error) {
      return {
        success: false,
        message: 'Erreur lors de la récupération des rôles: ' + error.message,
      };
    }
  }

  /**
   * API endpoint pour obtenir toutes les permissions
   */
  @Get('permissions')
  async getPermissions() {
    try {
      const permissions = await this.adminPermissionsService.getAllPermissions();
      return {
        success: true,
        permissions,
      };
    } catch (error) {
      return {
        success: false,
        message: 'Erreur lors de la récupération des permissions: ' + error.message,
      };
    }
  }

  /**
   * API endpoint pour obtenir les permissions groupées
   */
  @Get('grouped')
  async getGroupedPermissions() {
    try {
      const groupedPermissions = await this.adminPermissionsService.getGroupedPermissions();
      return {
        success: true,
        groupedPermissions,
      };
    } catch (error) {
      return {
        success: false,
        message: 'Erreur lors de la récupération des permissions groupées: ' + error.message,
      };
    }
  }
}
