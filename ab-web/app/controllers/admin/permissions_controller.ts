import type { HttpContext } from '@adonisjs/core/http'
import Role from '#models/role'
import Permission from '#models/permission'

export default class PermissionsController {
  /**
   * Afficher la page de gestion des permissions
   */
  async index({ inertia }: HttpContext) {
    const roles = await Role.query().orderBy('name', 'asc')
    const permissions = await Permission.query().orderBy('group', 'asc').orderBy('name', 'asc')

    // On groupe les permissions par 'group' pour l'affichage
    const groupedPermissions = permissions.reduce((acc: any, permission) => {
      if (!acc[permission.group]) {
        acc[permission.group] = []
      }
      acc[permission.group].push(permission)
      return acc
    }, {})

    return inertia.render('admin/permissions/index', {
      roles,
      groupedPermissions,
    })
  }

  /**
   * Récupérer les permissions d'un rôle
   */
  async getRolePermissions({ params, response }: HttpContext) {
    const role = await Role.findOrFail(params.id)
    await role.load('permissions')
    return response.ok(role.permissions.map((p) => p.id))
  }

  /**
   * Synchroniser les permissions d'un rôle
   */
  async sync({ request, response }: HttpContext) {
    const { roleId, permissionIds } = request.only(['roleId', 'permissionIds'])
    const role = await Role.findOrFail(roleId)
    
    await role.related('permissions').sync(permissionIds)
    
    return response.ok({ message: 'Permissions mises à jour avec succès' })
  }
}
