import { BaseSeeder } from '@adonisjs/lucid/seeders'
import Category from '#models/category'

export default class extends BaseSeeder {
  async run() {
    const base = 'https://auto-cdn.uvatis.com/cat/'
    await Category.createMany([
      { name: 'Pièces auto', url: `${base}auto.jpg` },
      { name: 'Pièces électriques', url: `${base}piece_electrique.jpg` },
      { name: 'Accessoires auto', url: `${base}accessoires.png` },
      { name: 'Appareils de diagnostic automobile', url: `${base}appareill_de_diagnostique.jpg` },
      { name: 'Automobile', url: `${base}auto.png` },
      { name: 'Outillage', url: `${base}outillage_.png` },
      { name: 'Groupe électrogène', url: `${base}groupe.png` },
      { name: 'Vêtements', url: `${base}vetement.png` },

      { name: 'Transitaire', url: `${base}transitaire.jpeg` },
      { name: 'Casque moto', url: `${base}casque_de_moto.jpg` },
      { name: 'Formation auto', url: `${base}formation_auto.jpg` },
    ])
  }
}
