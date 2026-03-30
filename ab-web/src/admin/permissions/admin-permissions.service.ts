import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class AdminPermissionsService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Récupérer tous les rôles
   */
  async getAllRoles() {
    try {
      const roles = await this.prisma.role.findMany({
        include: {
          _count: {
            select: { 
              users: true,
              permissions: true
            }
          }
        },
        orderBy: { name: 'asc' }
      });

      return roles;
    } catch (error) {
      throw new Error('Erreur lors de la récupération des rôles');
    }
  }

  /**
   * Récupérer toutes les permissions
   */
  async getAllPermissions() {
    try {
      const permissions = await this.prisma.permission.findMany({
        include: {
          _count: {
            select: { roles: true }
          }
        },
        orderBy: [
          { group: 'asc' },
          { name: 'asc' }
        ]
      });

      return permissions;
    } catch (error) {
      throw new Error('Erreur lors de la récupération des permissions');
    }
  }

  /**
   * Récupérer les permissions groupées par catégorie
   */
  async getGroupedPermissions() {
    try {
      const permissions = await this.prisma.permission.findMany({
        orderBy: [
          { group: 'asc' },
          { name: 'asc' }
        ]
      });

      const groupedPermissions = permissions.reduce((acc, permission) => {
        const group = permission.group || 'Divers';
        if (!acc[group]) {
          acc[group] = [];
        }
        acc[group].push(permission);
        return acc;
      }, {} as Record<string, any[]>);

      return groupedPermissions;
    } catch (error) {
      throw new Error('Erreur lors de la récupération des permissions groupées');
    }
  }

  /**
   * Récupérer les permissions d'un rôle spécifique
   */
  async getRolePermissions(roleId: number) {
    try {
      const role = await this.prisma.role.findUnique({
        where: { id: roleId },
        include: {
          permissions: {
            select: { id: true }
          }
        }
      });

      if (!role) {
        throw new Error('Rôle introuvable');
      }

      return role.permissions.map(p => p.id);
    } catch (error) {
      throw new Error('Erreur lors de la récupération des permissions du rôle: ' + error.message);
    }
  }

  /**
   * Synchroniser les permissions d'un rôle
   */
  async syncRolePermissions(roleId: number, permissionIds: number[]) {
    try {
      // Vérifier si le rôle existe
      const role = await this.prisma.role.findUnique({
        where: { id: roleId }
      });

      if (!role) {
        throw new Error('Rôle introuvable');
      }

      // Vérifier si toutes les permissions existent
      if (permissionIds.length > 0) {
        const permissionsCount = await this.prisma.permission.count({
          where: {
            id: { in: permissionIds }
          }
        });

        if (permissionsCount !== permissionIds.length) {
          throw new Error('Une ou plusieurs permissions sont introuvables');
        }
      }

      // Synchroniser les permissions
      await this.prisma.role.update({
        where: { id: roleId },
        data: {
          permissions: {
            set: permissionIds.map(id => ({ id }))
          }
        }
      });

      return { success: true, message: 'Permissions mises à jour avec succès' };
    } catch (error) {
      throw new Error('Erreur lors de la synchronisation des permissions: ' + error.message);
    }
  }

  /**
   * Créer un nouveau rôle
   */
  async createRole(createRoleDto: { name: string; slug: string }) {
    try {
      // Vérifier si le slug existe déjà
      const existingRole = await this.prisma.role.findUnique({
        where: { slug: createRoleDto.slug }
      });

      if (existingRole) {
        throw new Error('Un rôle avec ce slug existe déjà');
      }

      const role = await this.prisma.role.create({
        data: {
          name: createRoleDto.name,
          slug: createRoleDto.slug,
        },
        include: {
          _count: {
            select: { 
              users: true,
              permissions: true
            }
          }
        }
      });

      return role;
    } catch (error) {
      throw new Error('Erreur lors de la création du rôle: ' + error.message);
    }
  }

  /**
   * Mettre à jour un rôle
   */
  async updateRole(roleId: number, updateRoleDto: { name: string; slug: string }) {
    try {
      // Vérifier si le rôle existe
      const existingRole = await this.prisma.role.findUnique({
        where: { id: roleId }
      });

      if (!existingRole) {
        throw new Error('Rôle introuvable');
      }

      // Vérifier si le slug est déjà utilisé par un autre rôle
      if (updateRoleDto.slug !== existingRole.slug) {
        const slugExists = await this.prisma.role.findUnique({
          where: { slug: updateRoleDto.slug }
        });

        if (slugExists) {
          throw new Error('Un rôle avec ce slug existe déjà');
        }
      }

      const updatedRole = await this.prisma.role.update({
        where: { id: roleId },
        data: {
          name: updateRoleDto.name,
          slug: updateRoleDto.slug,
        },
        include: {
          _count: {
            select: { 
              users: true,
              permissions: true
            }
          }
        }
      });

      return updatedRole;
    } catch (error) {
      throw new Error('Erreur lors de la mise à jour du rôle: ' + error.message);
    }
  }

  /**
   * Supprimer un rôle
   */
  async deleteRole(roleId: number) {
    try {
      // Vérifier si le rôle existe
      const role = await this.prisma.role.findUnique({
        where: { id: roleId },
        include: {
          _count: {
            select: { 
              users: true,
              permissions: true
            }
          }
        }
      });

      if (!role) {
        throw new Error('Rôle introuvable');
      }

      // Vérifier si le rôle a des utilisateurs
      if (role._count.users > 0) {
        throw new Error('Impossible de supprimer un rôle avec des utilisateurs assignés');
      }

      await this.prisma.role.delete({
        where: { id: roleId }
      });

      return { success: true, message: 'Rôle supprimé avec succès' };
    } catch (error) {
      throw new Error('Erreur lors de la suppression du rôle: ' + error.message);
    }
  }

  /**
   * Créer une nouvelle permission
   */
  async createPermission(createPermissionDto: { name: string; slug: string; group: string }) {
    try {
      // Vérifier si le slug existe déjà
      const existingPermission = await this.prisma.permission.findUnique({
        where: { slug: createPermissionDto.slug }
      });

      if (existingPermission) {
        throw new Error('Une permission avec ce slug existe déjà');
      }

      const permission = await this.prisma.permission.create({
        data: {
          name: createPermissionDto.name,
          slug: createPermissionDto.slug,
          group: createPermissionDto.group,
        },
        include: {
          _count: {
            select: { roles: true }
          }
        }
      });

      return permission;
    } catch (error) {
      throw new Error('Erreur lors de la création de la permission: ' + error.message);
    }
  }

  /**
   * Mettre à jour une permission
   */
  async updatePermission(permissionId: number, updatePermissionDto: { name: string; slug: string; group: string }) {
    try {
      // Vérifier si la permission existe
      const existingPermission = await this.prisma.permission.findUnique({
        where: { id: permissionId }
      });

      if (!existingPermission) {
        throw new Error('Permission introuvable');
      }

      // Vérifier si le slug est déjà utilisé par une autre permission
      if (updatePermissionDto.slug !== existingPermission.slug) {
        const slugExists = await this.prisma.permission.findUnique({
          where: { slug: updatePermissionDto.slug }
        });

        if (slugExists) {
          throw new Error('Une permission avec ce slug existe déjà');
        }
      }

      const updatedPermission = await this.prisma.permission.update({
        where: { id: permissionId },
        data: {
          name: updatePermissionDto.name,
          slug: updatePermissionDto.slug,
          group: updatePermissionDto.group,
        },
        include: {
          _count: {
            select: { roles: true }
          }
        }
      });

      return updatedPermission;
    } catch (error) {
      throw new Error('Erreur lors de la mise à jour de la permission: ' + error.message);
    }
  }

  /**
   * Supprimer une permission
   */
  async deletePermission(permissionId: number) {
    try {
      // Vérifier si la permission existe
      const permission = await this.prisma.permission.findUnique({
        where: { id: permissionId },
        include: {
          _count: {
            select: { roles: true }
          }
        }
      });

      if (!permission) {
        throw new Error('Permission introuvable');
      }

      // Vérifier si la permission est utilisée par des rôles
      if (permission._count.roles > 0) {
        throw new Error('Impossible de supprimer une permission utilisée par des rôles');
      }

      await this.prisma.permission.delete({
        where: { id: permissionId }
      });

      return { success: true, message: 'Permission supprimée avec succès' };
    } catch (error) {
      throw new Error('Erreur lors de la suppression de la permission: ' + error.message);
    }
  }

  /**
   * Obtenir les statistiques des permissions et rôles
   */
  async getPermissionsStats() {
    try {
      const [
        totalRoles,
        totalPermissions,
        rolesWithUsers,
        permissionsWithRoles
      ] = await Promise.all([
        this.prisma.role.count(),
        this.prisma.permission.count(),
        this.prisma.role.count({
          where: {
            users: {
              some: {}
            }
          }
        }),
        this.prisma.permission.count({
          where: {
            roles: {
              some: {}
            }
          }
        })
      ]);

      return {
        totalRoles,
        totalPermissions,
        rolesWithUsers,
        permissionsWithRoles
      };
    } catch (error) {
      throw new Error('Erreur lors de la récupération des statistiques');
    }
  }
}
