import { BaseSeeder } from '@adonisjs/lucid/seeders'
import Product from '#models/product'
import { ProductState } from '#dto/products_interface'

export default class extends BaseSeeder {
  async run() {
    await Product.createMany([
      // 🔹 Pneus
      {
        name: 'Pneu Michelin 205/55 R16',
        state: ProductState.NEW,
        categoryId: 1, // Pneus
        brandId: 16, // Peugeot
        features: [
          'Matériau de friction de haute qualité pour un freinage efficace',
          'Réduction du bruit et des vibrations',
          'Installation facile et rapide',
          'Durée de vie prolongée',
          'Performances constantes à différentes températures',
        ],
        description: 'Pneu de haute qualité pour une meilleure adhérence et longévité.',
        price: 75000,
      },
      {
        name: 'Pneu Goodyear 195/65 R15',
        state: ProductState.NEW,
        categoryId: 1,
        brandId: 19, // Toyota
        features: [
          'Matériau de friction de haute qualité pour un freinage efficace',
          'Réduction du bruit et des vibrations',
          'Installation facile et rapide',
          'Durée de vie prolongée',
          'Performances constantes à différentes températures',
        ],
        description: 'Pneu robuste pour une conduite en toute sécurité.',
        price: 68000,
      },

      // 🔹 Huiles et liquides
      {
        name: 'Huile moteur 5W30 Castrol',
        state: ProductState.NEW,
        categoryId: 2,
        brandId: 14, // Mercedes
        features: [
          'Matériau de friction de haute qualité pour un freinage efficace',
          'Réduction du bruit et des vibrations',
          'Installation facile et rapide',
          'Durée de vie prolongée',
          'Performances constantes à différentes températures',
        ],
        description: 'Huile moteur synthétique adaptée aux véhicules modernes.',
        price: 25000,
      },
      {
        name: 'Liquide de frein DOT 4 Motul',
        state: ProductState.NEW,
        categoryId: 2,
        brandId: 12, // Lexus
        features: [
          'Matériau de friction de haute qualité pour un freinage efficace',
          'Réduction du bruit et des vibrations',
          'Installation facile et rapide',
          'Durée de vie prolongée',
          'Performances constantes à différentes températures',
        ],
        description: 'Liquide de frein haute performance pour une sécurité optimale.',
        price: 12000,
      },

      // 🔹 Freinage
      {
        name: 'Plaquettes de frein Bosch',
        state: ProductState.NEW,
        categoryId: 3, // Freinage
        brandId: 19, // Toyota
        features: [
          'Matériau de friction de haute qualité pour un freinage efficace',
          'Réduction du bruit et des vibrations',
          'Installation facile et rapide',
          'Durée de vie prolongée',
          'Performances constantes à différentes températures',
        ],
        description: 'Plaquettes de frein de haute performance pour une sécurité maximale.',
        price: 45000,
      },
      {
        name: 'Disques de frein Brembo',
        state: ProductState.OLD,
        categoryId: 3,
        features: [
          'Matériau de friction de haute qualité pour un freinage efficace',
          'Réduction du bruit et des vibrations',
          'Installation facile et rapide',
          'Durée de vie prolongée',
          'Performances constantes à différentes températures',
        ],
        brandId: 5, // Ferrari
        description: 'Disques de frein haute performance pour une réponse immédiate.',
        price: 98000,
      },

      // 🔹 Batteries
      {
        name: 'Batterie Varta 12V 74Ah',
        state: ProductState.NEW,
        categoryId: 4,
        features: [
          'Matériau de friction de haute qualité pour un freinage efficace',
          'Réduction du bruit et des vibrations',
          'Installation facile et rapide',
          'Durée de vie prolongée',
          'Performances constantes à différentes températures',
        ],
        brandId: 15, // Nissan
        description: 'Batterie fiable et durable pour voitures et utilitaires.',
        price: 120000,
      },
      {
        name: 'Batterie Bosch 60Ah',
        state: ProductState.NEW,
        categoryId: 4,
        features: [
          'Matériau de friction de haute qualité pour un freinage efficace',
          'Réduction du bruit et des vibrations',
          'Installation facile et rapide',
          'Durée de vie prolongée',
          'Performances constantes à différentes températures',
        ],
        brandId: 9, // Jaguar
        description: 'Batterie performante et résistante aux températures extrêmes.',
        price: 95000,
      },

      // 🔹 Filtration
      {
        name: 'Filtre à huile Mann-Filter',
        state: ProductState.NEW,
        categoryId: 5,
        features: [
          'Matériau de friction de haute qualité pour un freinage efficace',
          'Réduction du bruit et des vibrations',
          'Installation facile et rapide',
          'Durée de vie prolongée',
          'Performances constantes à différentes températures',
        ],
        brandId: 7, // Honda
        description: 'Filtre à huile de qualité pour une meilleure protection moteur.',
        price: 12000,
      },
      {
        name: 'Filtre à air K&N',
        state: ProductState.OLD,
        categoryId: 5,
        features: [
          'Matériau de friction de haute qualité pour un freinage efficace',
          'Réduction du bruit et des vibrations',
          'Installation facile et rapide',
          'Durée de vie prolongée',
          'Performances constantes à différentes températures',
        ],
        brandId: 3, // Chevrolet
        description: 'Optimise la performance du moteur avec un meilleur flux d’air.',
        price: 18000,
      },
      {
        name: 'Filtre à air K&N Copie',
        state: ProductState.OLD,
        categoryId: 5,
        features: [
          'Matériau de friction de haute qualité pour un freinage efficace',
          'Réduction du bruit et des vibrations',
          'Installation facile et rapide',
          'Durée de vie prolongée',
          'Performances constantes à différentes températures',
        ],
        brandId: 3, // Chevrolet
        description: 'Optimise la performance du moteur avec un meilleur flux d’air.',
        price: 1000,
      },

      // 🔹 Éclairage
      {
        name: 'Ampoule LED H7 Philips',
        state: ProductState.NEW,
        categoryId: 6,
        features: [
          'Matériau de friction de haute qualité pour un freinage efficace',
          'Réduction du bruit et des vibrations',
          'Installation facile et rapide',
          'Durée de vie prolongée',
          'Performances constantes à différentes températures',
        ],
        brandId: 20, // Tesla
        description: 'Éclairage puissant et économique pour une meilleure visibilité.',
        price: 18000,
      },
      {
        name: 'Phares avant Xénon',
        state: ProductState.NEW,
        categoryId: 6,
        features: [
          'Matériau de friction de haute qualité pour un freinage efficace',
          'Réduction du bruit et des vibrations',
          'Installation facile et rapide',
          'Durée de vie prolongée',
          'Performances constantes à différentes températures',
        ],
        brandId: 6, // Ford
        description: 'Phares Xénon ultra-lumineux pour une conduite de nuit en toute sécurité.',
        price: 75000,
      },

      // 🔹 Accessoires
      {
        name: 'Tapis de sol en caoutchouc',
        state: ProductState.OLD,
        categoryId: 5,
        features: [
          'Matériau de friction de haute qualité pour un freinage efficace',
          'Réduction du bruit et des vibrations',
          'Installation facile et rapide',
          'Durée de vie prolongée',
          'Performances constantes à différentes températures',
        ],
        brandId: 10, // Jeep
        description: 'Tapis de sol résistant et antidérapant pour voiture.',
        price: 22000,
      },
      {
        name: 'Housse de siège universelle',
        state: ProductState.NEW,
        categoryId: 4,
        features: [
          'Matériau de friction de haute qualité pour un freinage efficace',
          'Réduction du bruit et des vibrations',
          'Installation facile et rapide',
          'Durée de vie prolongée',
          'Performances constantes à différentes températures',
        ],
        brandId: 4, // Dodge
        description: 'Housse de siège résistante et facile à installer.',
        price: 30000,
      },

      // 🔹 Outillage
      {
        name: 'Clé dynamométrique Facom',
        state: ProductState.OLD,
        categoryId: 6,
        features: [
          'Matériau de friction de haute qualité pour un freinage efficace',
          'Réduction du bruit et des vibrations',
          'Installation facile et rapide',
          'Durée de vie prolongée',
          'Performances constantes à différentes températures',
        ],
        brandId: 12, // Lexus
        description: 'Clé dynamométrique précise pour les travaux mécaniques.',
        price: 55000,
      },
      {
        name: 'Kit de réparation crevaison Michelin',
        state: ProductState.NEW,
        categoryId: 5,
        features: [
          'Matériau de friction de haute qualité pour un freinage efficace',
          'Réduction du bruit et des vibrations',
          'Installation facile et rapide',
          'Durée de vie prolongée',
          'Performances constantes à différentes températures',
        ],
        brandId: 17, // Porsche
        description: 'Kit pratique pour réparer une crevaison en urgence.',
        price: 35000,
      },
    ])
  }
}
