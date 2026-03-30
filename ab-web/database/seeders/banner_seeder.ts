import { BaseSeeder } from '@adonisjs/lucid/seeders'
import Banner from '#models/banner'
export default class extends BaseSeeder {
  async run() {
    const base = 'https://auto-cdn.uvatis.com/banners/'
    const banners = [
      {
        title: 'Promotion sur les pneus',
        description: "Jusqu'à -30% sur une sélection de pneus Michelin et Continental",
        link: 'Découvrir',
        image: `${base}banner_ab_auto_1.png`,
      },
      {
        title: 'Nouveaux produits Bosch',
        description: 'Découvrez notre nouvelle gamme de batteries et alternateurs',
        link: 'Voir les produits',
        image: `${base}banner_ab_auto_2.png`,
      },
      {
        title: "Préparez votre voiture pour l'hiver",
        description: "Tout l'équipement nécessaire pour affronter la saison froide",
        link: 'Se préparer',
        image: `${base}banner_ab_auto_3.png`,
      },
      {
        title: "Préparez votre voiture pour l'hiver",
        description: "Tout l'équipement nécessaire pour affronter la saison froide",
        link: 'Se préparer',
        image: `${base}banner_ab_auto_4.png`,
      },
      {
        title: "Préparez votre voiture pour l'hiver",
        description: "Tout l'équipement nécessaire pour affronter la saison froide",
        link: 'Se préparer',
        image: `${base}banner_ab_auto_5.png`,
      },
    ]
    await Banner.createMany(banners)
  }
}
