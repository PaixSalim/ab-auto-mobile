import { BaseSeeder } from '@adonisjs/lucid/seeders'
import Partner from '#models/partner'

export default class extends BaseSeeder {
  async run() {
    const urlBase = 'https://auto-cdn.uvatis.com/brands/'
    const partners = [
      {
        image: `${urlBase}itaoua.png`,
        label: 'ITAOUA',
      },
      {
        image: `${urlBase}jetour.png`,
        label: 'Jetour',
      },
      {
        image: `${urlBase}changan.png`,
        label: 'Changan',
      },
      {
        image: `${urlBase}geely.png`,
        label: 'Geely',
      },
      {
        image: `${urlBase}cfao.png`,
        label: 'CFAO',
      },
    ]
    await Partner.createMany(partners)
  }
}
