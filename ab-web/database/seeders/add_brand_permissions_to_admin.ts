import { BaseSeeder } from '@adonisjs/lucid/seeders'
import Permission from '#models/permission'
import Role from '#models/role'

export default class extends BaseSeeder {
  async run() {
    try {
      // Récupérer le rôle admin
      const adminRole = await Role.query().where('name', 'admin').first()
      
      if (!adminRole) {
        console.log('❌ Rôle admin non trouvé')
        return
      }

      // Récupérer les permissions de marques existantes
      const brandPermissions = await Permission.query().where('group', 'Marques').exec()

      if (brandPermissions.length === 0) {
        console.log('❌ Aucune permission de marque trouvée')
        return
      }

      // Associer les permissions des marques au rôle admin
      await adminRole.related('permissions').attach(
        brandPermissions.map(p => p.id)
      )

      console.log(`✅ ${brandPermissions.length} permissions de marques assignées au rôle admin`)
      console.log('Permissions assignées:', brandPermissions.map(p => p.slug))

    } catch (error) {
      console.error('❌ Erreur lors de l\'assignation des permissions de marques:', error)
    }
  }
}
