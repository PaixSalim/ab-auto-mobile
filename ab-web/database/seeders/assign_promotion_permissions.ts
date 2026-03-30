import { BaseSeeder } from '@adonisjs/lucid/seeders'
import Role from '#models/role'
import Permission from '#models/permission'

export default class extends BaseSeeder {
  async run() {
    // Récupérer les rôles admin et superadmin
    const adminRole = await Role.findBy('slug', 'admin')
    const superAdminRole = await Role.findBy('slug', 'superadmin')
    
    if (!adminRole || !superAdminRole) {
      console.log('❌ Rôles admin ou superadmin non trouvés')
      return
    }
    
    // Récupérer les permissions de promotions
    const promotionPermissions = await Permission.query()
      .where('slug', 'like', 'promotions%')
      .orWhere('slug', 'like', '%promotion%')
    
    if (promotionPermissions.length === 0) {
      console.log('❌ Aucune permission de promotion trouvée')
      return
    }
    
    const promotionPermissionIds = promotionPermissions.map(p => p.id)
    
    // Assigner toutes les permissions de promotions au superadmin
    await superAdminRole.related('permissions').sync(promotionPermissionIds)
    console.log(`✅ ${promotionPermissionIds.length} permissions de promotions assignées au superadmin`)
    
    // Assigner les permissions de base à l'admin
    const adminPromoPermissions = promotionPermissions.filter(p => 
      ['view_promotions', 'manage_promotions', 'create_promotions', 'edit_promotions', 'delete_promotions'].includes(p.slug)
    )
    
    const adminPermissionIds = adminPromoPermissions.map(p => p.id)
    await adminRole.related('permissions').sync(adminPermissionIds)
    console.log(`✅ ${adminPermissionIds.length} permissions de promotions assignées à l'admin`)
    
    console.log('✅ Permissions de promotions assignées avec succès')
  }
}
