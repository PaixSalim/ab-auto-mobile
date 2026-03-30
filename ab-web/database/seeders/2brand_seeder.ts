import { BaseSeeder } from '@adonisjs/lucid/seeders'
import Brand from '#models/brand'

export default class extends BaseSeeder {
  async run() {
    const urlBase = 'https://auto-cdn.uvatis.com/brands/'
    const catUrlBase = 'https://auto-cdn.uvatis.com/cat/'
    await Brand.createMany([
      { name: 'Tout', url: `${urlBase}tous-logo.png` },
      { name: 'Audi', url: `${urlBase}audi.png` },
      { name: 'BMW', url: `${urlBase}bmw.png` },
      { name: 'Chevrolet', url: `${urlBase}chevrolet.png` },
      { name: 'Dodge', url: `${urlBase}dodge.png` },
      { name: 'Ferrari', url: `${urlBase}ferrari.png` },
      { name: 'Ford', url: `${urlBase}ford.png` },
      { name: 'Honda', url: `${urlBase}honda.png` },
      { name: 'Hyundai', url: `${urlBase}hyundai.png` },
      { name: 'Jaguar', url: `${urlBase}jaguar.png` },
      { name: 'Jeep', url: `${urlBase}jeep.png` },
      { name: 'Kia', url: `${urlBase}kia.png` },
      { name: 'Lexus', url: `${urlBase}lexus.png` },
      { name: 'Mazda', url: `${urlBase}mazda.png` },
      { name: 'Mercedes', url: `${urlBase}mercedes.png` },
      { name: 'Nissan', url: `${urlBase}nissan.png` },
      { name: 'Peugeot', url: `${urlBase}peugeot.png` },
      { name: 'Porsche', url: `${urlBase}porsche.png` },
      { name: 'Subaru', url: `${urlBase}subaru.png` },
      { name: 'Tesla', url: `${urlBase}tesla.png` },

      { name: 'Toyota', url: `${urlBase}toyota.png` },
      { name: 'Outillage', url: `${urlBase}outillage.png` },
      { name: 'BYD', url: `${urlBase}byd.png` },
      { name: 'Changan', url: `${urlBase}changan.png` },
      { name: 'Chery', url: `${urlBase}chery.png` },
      { name: 'Geely', url: `${urlBase}geely.png` },
      { name: 'GMC', url: `${urlBase}gmc.png` },
      { name: 'Haval', url: `${urlBase}haval.png` },
      { name: 'Itaoua', url: `${urlBase}itaoua.png` },
      { name: 'Jac-motors', url: `${urlBase}jac-motors.png` },
      { name: 'Jetour', url: `${urlBase}jetour.png` },
      { name: 'JMC', url: `${urlBase}jmc.png` },
      { name: 'Mitsubishi', url: `${urlBase}mitsubishi.png` },
      { name: 'Scion', url: `${urlBase}scion.png` },

      // categories same brands
      { name: 'Casque moto', url: `${catUrlBase}casque_moto.jp` },
      { name: 'formation auto', url: `${catUrlBase}formation.jpeg` },
      { name: 'Transitaire', url: `${catUrlBase}transitaire.jpeg` },
      { name: 'Groupe électrogène', url: `${catUrlBase}groupe.png` },
    ])
  }
}
